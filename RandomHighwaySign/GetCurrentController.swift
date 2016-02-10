//
//  GetCurrentController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 5/10/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import AlamofireImage
import SwiftyJSON
import FontAwesomeIconFactory
import GooglePlacesAutocomplete

class GetCurrentController: UITableViewController, CLLocationManagerDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var randomButton: UIBarButtonItem!
    
    //Url for Sign Query
    let locationManager = CLLocationManager()
    
    var randomSign:Sign!
    
    var currentPage = 1;
    var totalPages = 1;
    var modal : UIViewController!
    var isLoading = false
    
    var signs : Array<Sign> = [Sign]()

    var latitude: Double!
    var longitude: Double!
    
    var noResultsToDisplay = false
    var noLocation = false
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: valueForApiKey(keyName:  "PLACES"),
        placeType: .Cities
    )
    
    var loadingIndicatorView:LoadingIndicatorView!

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.delegate = self
        
        let fact = NIKFontAwesomeIconFactory.barButtonItemIconFactory()
        fact.colors = [self.view.tintColor]
        randomButton.title = ""
        randomButton.image = fact.createImageForIcon(.Random)
        

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        loadingIndicatorView = LoadingIndicatorView(frame:CGRectMake(0, 0, 80, 80))
        loadingIndicatorView.center = self.tableView.center
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 5000 //5km movement before updating
        locationManager.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Loading New Signs")
        self.refreshControl?.addTarget(self, action:"refresh", forControlEvents: UIControlEvents.ValueChanged)
    
        self.tableView.addSubview(refreshControl!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCurrentLocation", name: NSUserDefaultsDidChangeNotification, object: nil)

    
    }
    
    
    

    @IBAction func searchClicked(sender: AnyObject) {
        presentViewController(gpaViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //Hide empty rows
        self.tableView.tableFooterView  =  UIView(frame: CGRectZero)
        gpaViewController.placeDelegate = self
        self.navigationController?.toolbarHidden = true;
    }
    
    func refresh(){
        locationManager.startUpdatingLocation()
        self.view.addSubview(loadingIndicatorView)
        loadingIndicatorView.showActivity()
        self.refreshControl?.endRefreshing()
    }
    
    func reloadCurrentLocation(){
        if (latitude != nil && longitude != nil){
            self.currentPage = 1
            self.totalPages = 1
            self.signs = [Sign]()
            makeRequest()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if (noResultsToDisplay || noLocation){
            return 1
        }
        else{
            return self.signs.count
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("OpenDetail", sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (noResultsToDisplay){
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Results"
            return cell
        }else if (noLocation){
            let cell = UITableViewCell()
            cell.textLabel?.text = "Cannot Determine Location"
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("SignCell", forIndexPath: indexPath) as! ResultTableViewCell

            let sign = self.signs[indexPath.row]
        
            cell.assignSign(sign)
            
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = self.signs.count
            if (!self.isLoading &&  self.currentPage < self.totalPages && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
            {
                self.currentPage++
                self.makeRequest()
            }
            return cell
        }

    }


    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let newLoc : CLLocation = locations[locations.count - 1] as CLLocation
        {
            noLocation = false
            locationManager.stopUpdatingLocation()
             CLGeocoder().reverseGeocodeLocation(newLoc){
                (placemarks, error) in
            
                if ((error) != nil){
                    self.title = "Signs Near Current Location"
                    return
                }

                if (placemarks?.count > 0){
                    self.title = "Signs Near \(placemarks?[0].locality ?? "") \(placemarks?[0].administrativeArea ?? "")"
                }else{
                    self.title = "Signs Near Current Location"
                }
                
            }

            self.latitude = newLoc.coordinate.latitude
            self.longitude = newLoc.coordinate.longitude
            makeRequest()
        }
    }
    
    func makeRequest(){
        isLoading = true
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let radius = userDefaults.integerForKey("search_radius")
        
        if (self.currentPage > 1){
            let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            pagingSpinner.startAnimating()
            pagingSpinner.color = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            pagingSpinner.hidesWhenStopped = true
            tableView.tableFooterView = pagingSpinner
        }
        
        Alamofire.request(RandomRequestRouter.Geo(latitude:self.latitude,longitude:self.longitude,radius:radius,page:currentPage))
            .responseObject{(response: Response<SignCollectionResult, NSError>)in
                if response.result.error == nil{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                        self.currentPage = response.result.value!.currentPage;
                        self.totalPages = response.result.value!.totalPages;
                    
                        
                        for s in response.result.value!.signs{
                            self.signs.append(s)
                        }
                    
                        self.noResultsToDisplay = self.signs.count == 0
                        
                        dispatch_async(dispatch_get_main_queue()){
                            self.tableView.reloadData()
                            self.loadingIndicatorView.removeFromSuperview()
                            self.loadingIndicatorView.hideActivity()
                            self.isLoading = false
                        }
                        
                    }

                }
        }
    }
    

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
            self.view.addSubview(loadingIndicatorView)
            loadingIndicatorView.showActivity()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.loadingIndicatorView.removeFromSuperview()
        loadingIndicatorView.hideActivity()
        locationManager.stopUpdatingLocation()
        noLocation = true
        self.tableView.reloadData()
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "OpenDetail"){
                if let signViewController = segue.destinationViewController as? SignImageViewController{
                let indexPath = tableView.indexPathForSelectedRow
                if let tableCell = tableView.cellForRowAtIndexPath(indexPath!) as? ResultTableViewCell{
                     signViewController.sign = tableCell.sign
                }
                
                }
        }
    }
}

extension GetCurrentController : GooglePlacesAutocompleteDelegate{
    func placeSelected(place: Place) {
        place.getDetails(){
            (result:PlaceDetails) in
            self.latitude = result.latitude
            self.longitude = result.longitude
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: self.latitude, longitude: self.longitude)){
                (placemarks, error) in
                
                if ((error) != nil){
                    self.title = "Signs Near Current Location"
                    return
                }
                
                if (placemarks?.count > 0){
                    self.title = "Signs Near \(placemarks?[0].locality ?? "") \(placemarks?[0].administrativeArea ?? "")"
                }else{
                    self.title = "Signs Near Current Location"
                }
                
            }
            
            self.currentPage = 1
            self.totalPages = 1
            self.signs = [Sign]()
            self.dismissViewControllerAnimated(true, completion: nil)
            self.makeRequest()
        }
    }
    
    func placesFound(places: [Place]) {
        
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}


class ResultTableViewCell : UITableViewCell{
    var request: Alamofire.Request?
    var sign: Sign?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func assignSign(sign : Sign){
        self.sign = sign
        self.thumbnailImageView!.image = nil
        self.request?.cancel()
        
        self.titleLabel?.text = sign.title
        self.descLabel?.text = sign.imageDescription
        self.descLabel?.sizeToFit()
        
        self.request = Alamofire.request(.GET, sign.thumbnail).responseImage {
            response in
                self.thumbnailImageView!.image = response.result.value
        }
        
    }

}


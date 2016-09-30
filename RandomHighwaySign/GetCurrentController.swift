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

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GetCurrentController: UITableViewController, CLLocationManagerDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var currentLocationButton: UIBarButtonItem!
    
    //Url for Sign Query
    let locationManager = CLLocationManager()
    
    var randomSign:Sign!
    
    var currentPage = 1;
    var totalPages = 1;
    var isLoading = false
    
    var signs : Array<Sign> = [Sign]()

    var latitude: Double!
    var longitude: Double!
    
    var noResultsToDisplay = false
    var noLocation = false
    
    var browseItems = [Browse]();
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: valueForApiKey(keyName:  "PLACES"),
        placeType: .cities
    )
    
    var loadingIndicatorView:LoadingIndicatorView!

    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.delegate = self
        
        let fact = NIKFontAwesomeIconFactory.barButtonItem()
        fact.colors = [self.view.tintColor]
        currentLocationButton.title = ""
        currentLocationButton.image = fact.createImage(for: .bullseye)
        

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        var toolbarItems:Array<UIBarButtonItem> = []
        
        let leftFlex:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        let browseButton:UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(browse))
        browseButton.image = fact.createImage(for: .navicon)
        
        let randomButton:UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(showRandom))
        randomButton.image = fact.createImage(for: .random)
        toolbarItems.append(browseButton)
        toolbarItems.append(leftFlex)
        toolbarItems.append(randomButton)
        self.setToolbarItems(toolbarItems, animated: false)
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        
        loadingIndicatorView = LoadingIndicatorView(frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 80, height: 80)))
        

        loadingIndicatorView.center = self.tableView.center
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 5000 //5km movement before updating
        locationManager.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Loading New Signs")
        self.refreshControl?.addTarget(self, action:#selector(GetCurrentController.refresh), for: UIControlEvents.valueChanged)
    
        self.tableView.addSubview(refreshControl!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GetCurrentController.reloadCurrentLocation), name: UserDefaults.didChangeNotification, object: nil)

    
    }
    
    func showRandom(sender:UIBarButtonItem){
        performSegue(withIdentifier: "randomSign", sender: self)
    }
    
    func browse(sender:UIBarButtonItem){
        
        
        Browse.GetSubdivisions(completion: {
            result in
            
            self.browseItems = result
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "browse", sender: sender)
            }
        
        })
        

    
    }
    
    @IBAction func getCurrentLocationClicked(sender:AnyObject){
        refresh()
    }
    

    @IBAction func searchClicked(sender: AnyObject) {
        present(gpaViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //Hide empty rows
        self.tableView.tableFooterView  =  UIView(frame: CGRect.zero)
        gpaViewController.placeDelegate = self
    }
    
    func refresh(){
        self.currentPage = 1
        self.totalPages = 1
        self.signs = [Sign]()
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
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if (noResultsToDisplay || noLocation){
            return 1
        }
        else{
            return self.signs.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OpenDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (noResultsToDisplay){
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Results"
            return cell
        }else if (noLocation){
            let cell = UITableViewCell()
            cell.textLabel?.text = "Cannot Determine Location"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignCell", for: indexPath) as! ResultTableViewCell

            let sign = self.signs[(indexPath as NSIndexPath).row]
        
            cell.assignSign(sign)
            
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = self.signs.count
            if (!self.isLoading &&  self.currentPage < self.totalPages && ((indexPath as NSIndexPath).row >= (rowsLoaded - rowsToLoadFromBottom)))
            {
                self.currentPage += 1
                self.makeRequest()
            }
            return cell
        }

    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
        let userDefaults = UserDefaults.standard
        let radius = userDefaults.integer(forKey: "search_radius")
        
        if (self.currentPage > 1){
            let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            pagingSpinner.startAnimating()
            pagingSpinner.color = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            pagingSpinner.hidesWhenStopped = true
            tableView.tableFooterView = pagingSpinner
        }
        
        Alamofire.request(RandomRequestRouter.geo(latitude:self.latitude,longitude:self.longitude,radius:radius,page:currentPage))
            .responseObject{(response: DataResponse<SignCollectionResult>)in
                if response.result.error == nil{
                    DispatchQueue.global(qos: .background).async{
                        self.currentPage = response.result.value!.currentPage;
                        self.totalPages = response.result.value!.totalPages;
                    
                        
                        for s in response.result.value!.signs{
                            self.signs.append(s)
                        }
                    
                        self.noResultsToDisplay = self.signs.count == 0
                        
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                            self.loadingIndicatorView.removeFromSuperview()
                            self.loadingIndicatorView.hideActivity()
                            self.isLoading = false
                        }
                        
                    }

                }
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            self.view.addSubview(loadingIndicatorView)
            loadingIndicatorView.showActivity()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.loadingIndicatorView.removeFromSuperview()
        loadingIndicatorView.hideActivity()
        locationManager.stopUpdatingLocation()
        noLocation = true
        self.tableView.reloadData()
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "OpenDetail"){
                if let signViewController = segue.destination as? SignImageViewController{
                let indexPath = tableView.indexPathForSelectedRow
                if let tableCell = tableView.cellForRow(at: indexPath!) as? ResultTableViewCell{
                     signViewController.sign = tableCell.sign
                }
                
                }
        }
        else if (segue.identifier == "browse"){
            
             if let browseCountry = segue.destination as? BrowseCountryTableView{
                browseCountry.browse = self.browseItems
             }
        }

    }
}

extension GetCurrentController : GooglePlacesAutocompleteDelegate{
    func placeSelected(_ place: Place) {
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
            self.dismiss(animated: true, completion: nil)
            self.makeRequest()
        }
    }
    
    func placesFound(_ places: [Place]) {
        
    }
    
    func placeViewClosed() {
        dismiss(animated: true, completion: nil)
    }
    

}


class ResultTableViewCell : UITableViewCell{
    var request: Alamofire.Request?
    var sign: Sign?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func assignSign(_ sign : Sign){
        self.sign = sign
        self.thumbnailImageView!.image = nil
        self.request?.cancel()
        
        self.titleLabel?.text = sign.title
        self.descLabel?.text = sign.imageDescription
        self.descLabel?.sizeToFit()
        
        self.request = Alamofire.request(sign.thumbnail).responseImage {
            response in
                self.thumbnailImageView!.image = response.result.value
        }
        
    }

}


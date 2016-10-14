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
    
    var nextPage:String?
    var isLoading = false{
        didSet{
            if (self.isLoading){
                self.view.addSubview(loadingIndicatorView)
                loadingIndicatorView.showActivity()
                
            }else{
                self.loadingIndicatorView.removeFromSuperview()
                self.loadingIndicatorView.hideActivity()
            }
        }
    }
    
    var signs : [Sign] = [Sign](){
        didSet{
            tableView.reloadData()
        }
    }

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
        
        self.tableView.register(UINib(nibName: "SignTableViewCell", bundle: nil), forCellReuseIdentifier: "SignCell")

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        var toolbarItems:Array<UIBarButtonItem> = []
        
        let leftFlex:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        let browseButton:UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(browse))
        browseButton.image = fact.createImage(for: .navicon)
        
        let recentButton:UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(recent))
        recentButton.image = fact.createImage(for: .history)
        
        
        let randomButton:UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(showRandom))
        randomButton.image = fact.createImage(for: .random)
        toolbarItems.append(browseButton)
        toolbarItems.append(recentButton)
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
    
    func recent(sender:UIBarButtonItem){
        self.isLoading = true

        self.performSegue(withIdentifier: "recent", sender: sender)
        
    }
    
    
    func browse(sender:UIBarButtonItem){
        
        self.isLoading = true
        
        Browse.GetCountrySubdivisions(completion: {
            result in
            
            self.isLoading = false
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
        self.nextPage = nil
        self.signs = [Sign]()
        locationManager.startUpdatingLocation()
        self.isLoading = true
        self.refreshControl?.endRefreshing()
    }
    
    func reloadCurrentLocation(){
        if (latitude != nil && longitude != nil){
            self.nextPage = nil
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
            if (!self.isLoading &&  self.nextPage != nil && ((indexPath as NSIndexPath).row >= (rowsLoaded - rowsToLoadFromBottom)))
            {
                self.getNextPage()
            }
            return cell
        }

    }

    func getNextPage(){
        if self.nextPage == nil{
            return
        }
        
        self.isLoading = true
        Sign.fetchNext(nextUrl: self.nextPage!)
        { (result: [Sign], next: String?) in
            self.signs = self.signs + result
            self.isLoading = false
            self.nextPage = next
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
        
        Sign.fetch(type: RandomRequestRouter.geo(latitude:self.latitude,longitude:self.longitude,radius:radius)) { (result: [Sign], next: String?) in
            self.signs = result
            self.isLoading = false
            self.nextPage = next
        }

    
    }
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            self.isLoading = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.isLoading = false
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
            
            self.nextPage = nil
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




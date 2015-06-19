//
//  GetCurrentController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 5/10/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire;
import SwiftyJSON;

class GetCurrentController: UITableViewController, CLLocationManagerDelegate, UITabBarControllerDelegate {

    //Url for Sign Query
    let locationManager = CLLocationManager()
    
    var currentPage = 0;
    var modal : UIViewController!
    
    var signs : Array<Sign> = [Sign]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.delegate = self

        navigationController?.setNavigationBarHidden(false, animated: true)
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 5000 //5km movement before updating
        locationManager.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Loading New Signs")
        self.refreshControl?.addTarget(self, action:"refresh", forControlEvents: UIControlEvents.ValueChanged)
    
        self.tableView.addSubview(refreshControl!)
    
    }
    
    func refresh(){
        locationManager.startUpdatingLocation()
        self.refreshControl?.endRefreshing()
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
        return self.signs.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("OpenDetail", sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SignCell", forIndexPath: indexPath) as! ResultTableViewCell
        let sign = self.signs[indexPath.row]
        
        cell.assignSign(sign)
        
        return cell
    }


    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if let newLoc : CLLocation = locations[locations.count - 1] as? CLLocation
        {
            locationManager.stopUpdatingLocation()
            makeRequest(newLoc.coordinate.latitude, longitude: newLoc.coordinate.longitude)
        }
    }
    
    func makeRequest(latitude:Double, longitude:Double){
        let radius = 5
        let page = 1
        Alamofire.request(RandomRequestRouter.Geo(latitude:latitude,longitude:longitude,radius:radius,page:page))
            .responseCollection{ (_,_,data:[Sign]?,error) in
                if error == nil{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                        
                        self.signs = data!
                    
                        dispatch_async(dispatch_get_main_queue()){
                            self.tableView.reloadData()
                        }
                    }

                }
        }
    }
    

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func refreshLocation(sender : AnyObject) {
        locationManager.startUpdatingLocation()
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "OpenDetail"){
            if let navController = segue.destinationViewController as? UINavigationController{
                if let signViewController = navController.topViewController as? SignImageViewController{
                var indexPath = tableView.indexPathForSelectedRow()
                if let tableCell = tableView.cellForRowAtIndexPath(indexPath!) as? ResultTableViewCell{
                     signViewController.sign = tableCell.sign
                }
                
                }
            }
        }
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
        
        self.request = Alamofire.request(.GET, sign.thumbnail).responseImage() {
            (request, _, image, error) in
            if error == nil && image != nil {
                self.thumbnailImageView!.image = image
            }
        }
        
    }

}


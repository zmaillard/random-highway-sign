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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationController?.setNavigationBarHidden(false, animated: true)
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 5000 //5km movement before updating
        locationManager.delegate = self
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SignCell", forIndexPath: indexPath) as! ResultTableViewCell
        let sign = self.signs[indexPath.row]
        
        cell.thumbnailImageView!.image = nil
        cell.request?.cancel()
        
        cell.titleLabel?.text = sign.title
        cell.descLabel?.text = sign.imageDescription
        cell.descLabel?.sizeToFit()
        
        cell.request = Alamofire.request(.GET, sign.thumbnail).responseImage() {
            (request, _, image, error) in
            if error == nil && image != nil {
                cell.thumbnailImageView!.image = image
            }
        }
        
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

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

class ResultTableViewCell : UITableViewCell{
    var request: Alamofire.Request?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    

}


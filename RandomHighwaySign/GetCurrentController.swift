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
    let baseUrl = "http://www.sagebrushgis.com/query"
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SignCell", forIndexPath: indexPath) as! UITableViewCell
        
        let sign = self.signs[indexPath.row]
        
        cell.textLabel?.text = sign.title
        cell.detailTextLabel?.text = "\(sign.place), \(sign.state)"
        
        let url = NSURL(string: sign.thumbnail)
        let data = NSData(contentsOfURL: url!)
        
        let image = UIImage(data:data!)
        cell.imageView?.image = image
        
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
        
        Alamofire.request(.GET, baseUrl, parameters: ["type":"geo","lat": latitude, "lon":longitude, "radius":radius, "page":page])
            .responseJSON{ (_,_,data,_) in
                println (data)
                let jsonRes = JSON(data!);
                self.signs = [Sign]()
                
                
                for (index: String, subJson: JSON) in jsonRes["signs"] {
                    self.signs.append(Sign.fromJson(subJson))
                }
                
                self.tableView.reloadData()
                
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController.title == "RandomTab"){
            self.modal = storyboard!.instantiateViewControllerWithIdentifier("randomSignNav") as! UIViewController
            self.presentViewController(modal, animated: true, completion:nil)
            return true
        }
        return false
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func refreshLocation(sender : AnyObject) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func closeRandomSignView(segue: UIStoryboardSegue){
        self.tabBarController!.selectedIndex = 0;
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


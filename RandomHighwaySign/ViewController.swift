//
//  ViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/19/15.

import AVFoundation
import UIKit
import Alamofire
import SwiftyJSON
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var detailsButton: UIBarButtonItem!
    

    @IBOutlet var signImage: SignImage!
    var sign : Sign?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        randomSignRequest()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomSignRequest(){
        //spinner.hidden = false
        //spinner.startAnimating()
        Alamofire.request(RandomRequestRouter.Single())
            .responseCollection{(_,_,data:[Sign]?,_)in
                self.sign = data![0]
                self.navItem.title = self.sign!.title
                self.signImage.loadSign(self.sign!)
        }
    }




    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenDetail"{
            if let signDetailsViewController = segue.destinationViewController.topViewController as? SignDetailsViewController{
                signDetailsViewController.sign = self.sign
            }
        }
    }
    
    
    @IBAction func getDetailsTapped(sender : AnyObject) {
        self.randomSignRequest()
    }
    
    @IBAction func loadDetailsPage(segue : UIStoryboardSegue){
        
    }
    
    @IBAction func backToMainController (segue : UIStoryboardSegue){
        
    }
    
}
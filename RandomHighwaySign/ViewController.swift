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
import FontAwesomeIconFactory

class ViewController: UIViewController {

    @IBOutlet weak var navItem: UIBarButtonItem!
    @IBOutlet weak var detailsButton: UIBarButtonItem!
    @IBOutlet var signImage: SignImage!
    
    var sign : Sign?
    
    var loadImageDelegate : LoadImageDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        var fact = NIKFontAwesomeIconFactory.barButtonItemIconFactory()
        fact.colors = [self.view.tintColor]
        navItem.title = ""
        navItem.image = fact.createImageForIcon(.Refresh)
        
        detailsButton.title = ""
        detailsButton.image = fact.createImageForIcon(.InfoCircle)
        
        randomSignRequest()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = false
        
        if loadImageDelegate != nil{
            loadImageDelegate.loadImageInto(self)
        }
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
                self.title = self.sign!.title
                self.signImage.loadSign(self.sign!)
        }
    }




    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenRandomDetail"{
            if let signDetailsViewController = segue.destinationViewController as? SignDetailsViewController{
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
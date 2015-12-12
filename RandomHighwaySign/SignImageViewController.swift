//
//  SignImageViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/18/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory

class SignImageViewController: UIViewController {
    var sign:Sign?
    
    @IBOutlet weak var detailsButton: UIBarButtonItem!
    @IBOutlet var signImage: SignImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fact = NIKFontAwesomeIconFactory.barButtonItemIconFactory()
        fact.colors = [self.view.tintColor]
        detailsButton.title = ""
        detailsButton.image = fact.createImageForIcon(.InfoCircle)
        
        signImage.loadSign(sign!)
        self.title = self.sign!.title
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonClicked(sender : AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signIdentify"{
            
            if let identifyView = segue.destinationViewController as? SignDetailsViewController{
                identifyView.sign = self.sign
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

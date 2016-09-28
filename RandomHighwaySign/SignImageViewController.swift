//
//  SignImageViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/18/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory

class SignImageViewController: UIViewController, ImageLoadingDelegate {
    var sign:Sign?
    
    @IBOutlet weak var detailsButton: UIBarButtonItem!
    @IBOutlet var signImage: SignImage!
    
    var loadingIndicatorView:LoadingIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fact = NIKFontAwesomeIconFactory.barButtonItemIconFactory()
        fact.colors = [self.view.tintColor]
        detailsButton.title = ""
        detailsButton.image = fact.createImageForIcon(.InfoCircle)
        
        loadingIndicatorView = LoadingIndicatorView(frame:CGRectMake(0, 0, 80, 80))
        loadingIndicatorView.center = self.view.center
        
        self.signImage.status = self
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = false
    
        loadSign()
    }

    func loadSign(){
        self.view.addSubview(loadingIndicatorView)
        self.loadingIndicatorView.showActivity()

        self.title = self.sign!.title
        self.signImage.loadSign(self.sign!)
        
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
    
    func OnImageLoaded() {
        self.loadingIndicatorView.removeFromSuperview()
        self.loadingIndicatorView.hideActivity()
    }

}

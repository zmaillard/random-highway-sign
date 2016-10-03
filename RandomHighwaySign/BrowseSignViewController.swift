//
//  BrowseSignViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 10/2/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory

class BrowseSignViewController: UIViewController {

    var sign:Sign?
    

    @IBOutlet weak var detailsButton: UIBarButtonItem!

    @IBOutlet var signImage: SignImage!
    
    var loadingIndicatorView:LoadingIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fact = NIKFontAwesomeIconFactory.barButtonItem()
        fact.colors = [self.view.tintColor]
        detailsButton.title = ""
        detailsButton.image = fact.createImage(for: .infoCircle)
        
        loadingIndicatorView = LoadingIndicatorView(frame:CGRect(x: 0, y: 0, width: 80, height: 80))
        loadingIndicatorView.center = self.view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
        
        loadSign()
    }
    
    func loadSign(){
        self.view.addSubview(loadingIndicatorView)
        self.loadingIndicatorView.showActivity()
        
        self.title = self.sign!.title
        self.signImage.loadSign(self.sign!)
        
        
        self.loadingIndicatorView.removeFromSuperview()
        self.loadingIndicatorView.hideActivity()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonClicked(_ sender : AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBrowseSignDetails"{
            
            if let identifyView = segue.destination as? SignDetailsViewController{
                identifyView.sign = self.sign
            }
        }
    }

}

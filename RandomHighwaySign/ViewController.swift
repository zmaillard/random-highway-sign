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
    
    var loadingIndicatorView:LoadingIndicatorView!
    var sign : Sign?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fact = NIKFontAwesomeIconFactory.barButtonItem()
        fact.colors = [self.view.tintColor]
        navItem.title = ""
        navItem.image = fact.createImage(for: .refresh)
        
        detailsButton.title = ""
        detailsButton.image = fact.createImage(for: .infoCircle)
        
        loadingIndicatorView = LoadingIndicatorView(frame:CGRect(x: 0, y: 0, width: 80, height: 80))
        loadingIndicatorView.center = self.view.center
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
        
        randomSignRequest()

        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomSignRequest(){
        self.view.addSubview(loadingIndicatorView)
        self.loadingIndicatorView.showActivity()
        DispatchQueue.global(qos: .background).async{
            Sign.getRandom() {
                (sign:Sign) in
                self.sign = sign
                self.title = sign.title
                self.signImage.loadSign(self.sign!)
            }
            
            DispatchQueue.main.async(execute: {
                self.loadingIndicatorView.removeFromSuperview()
                self.loadingIndicatorView.hideActivity()
            })
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenRandomDetail"{
            navigationItem.title = nil
            if let signDetailsViewController = segue.destination as? SignDetailsViewController{
                signDetailsViewController.sign = self.sign
            }
        }
    }
    
    
    @IBAction func getDetailsTapped(_ sender : AnyObject) {
        self.randomSignRequest()
    }

    
}

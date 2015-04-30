//
//  ViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/19/15.

import AVFoundation;
import UIKit
import Alamofire;
import SwiftyJSON;

class ViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        randomSignRequest();
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomSignRequest(){
        spinner.hidden = false
        spinner.startAnimating()
        Alamofire.request(.GET, Config.RandomSignEndpoint)
            .responseJSON{(_,_,data,_)in
                let jsonRes = JSON(data!);
                if let imageUrl = jsonRes["signs"][0]["largeimage"].string{
                    self.setImageData(imageUrl);
                }
                
                if let signName = jsonRes["signs"][0]["title"].string{
                    self.titleLabel.text = signName;
                }
                
        }
    }
    

    func setImageData(imageUrl:String){
        let url = NSURL(string: imageUrl)
        let data = NSData(contentsOfURL: url!)
        
        let image = UIImage(data:data!)
        imageView.image = image
        spinner.stopAnimating()
        spinner.hidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "OpenDetail"){
            if let signDetailsViewController = segue.destinationViewController as? SignDetailsViewController{
                signDetailsViewController.signTitle = titleLabel.text
            }
        }
    }
    
    @IBAction func getNewTapped(sender : AnyObject) {
        self.randomSignRequest()
    }
    
    @IBAction func loadDetailsPage(segue : UIStoryboardSegue){
        
    }
    
    @IBAction func backToMainController (segue : UIStoryboardSegue){
        
    }
    
}
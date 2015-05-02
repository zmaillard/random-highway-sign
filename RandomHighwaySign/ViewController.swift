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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var sign : Sign!;
    
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
                self.sign = Sign();
                let jsonRes = JSON(data!);
                if let imageUrl = jsonRes["signs"][0]["largeimage"].string{
                    self.sign.imagePath = imageUrl
                    self.setImageData(imageUrl)
                }
                
                if let signName = jsonRes["signs"][0]["title"].string{
                    self.sign.title = signName
                    self.titleLabel.text = signName;
                }

                if let latitude = jsonRes["signs"][0]["latitude"].double{
                    self.sign.latitude = latitude
                }

                if let longitude = jsonRes["signs"][0]["longitude"].double{
                    self.sign.longitude = longitude
                }

                if let description = jsonRes["signs"][0]["description"].string{
                    self.sign.description = description
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
        if segue.identifier == "OpenDetail"{
            println("segue.destinationViewController is \(segue.destinationViewController)")
            if let signDetailsViewController = segue.destinationViewController.topViewController as? SignDetailsViewController{
                signDetailsViewController.sign = self.sign
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
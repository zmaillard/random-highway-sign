//
//  ViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/19/15.

import UIKit
import Alamofire;
import SwiftyJSON;

class ViewController: UIViewController {
    
    @IBOutlet weak var mainImage: UIImageView!
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
        Alamofire.request(.GET, "http://www.sagebrushgis.com/random/?format=json")
            .responseJSON{(_,_,data,_)in
                let jsonRes = JSON(data!);
                if let imageUrl = jsonRes["signs"][0]["largeimage"].string{
                    self.setImageData(imageUrl);
                }
                
        }
    }
    
    func setImageData(imageUrl:String){
        let url = NSURL(string: imageUrl);
        let data = NSData(contentsOfURL: url!);
        mainImage.image = UIImage(data:data!);
    }

}
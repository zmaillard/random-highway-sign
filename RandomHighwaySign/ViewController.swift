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
        let url = NSURL(string: "http://highwaysign.s3.amazonaws.com/2238726485/2238726485_m.jpg");
        let data = NSData(contentsOfURL: url!);
        mainImage.image = UIImage(data:data!);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomSignRequest(){
        Alamofire.request(.GET, "http://www.sagebrushgis.com/random/?format=json")
            .responseJSON{(_,_,JSON,_)in
                    println(JSON["signs"]);
                
        }
    }

}
//
//  SignImageViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/18/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit

class SignImageViewController: UIViewController {
    var sign:Sign?
    
    @IBOutlet var signImage: SignImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signImage.loadSign(sign!)
        self.title = self.sign!.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

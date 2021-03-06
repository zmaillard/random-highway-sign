//
//  LoadingIndicatorView.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 7/13/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit

class LoadingIndicatorView: UIView {
    
    var activityIndicator: UIActivityIndicatorView!
    var loadingView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadingView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.backgroundColor = UIColorFromHex(0x444444,alpha:0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView()
        var frame = activityIndicator.frame;
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        loadingView.addSubview(activityIndicator)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    
    func showActivity(){
        self.addSubview(loadingView)
        activityIndicator.startAnimating()
    }
    
    func hideActivity(){
        self.loadingView.removeFromSuperview()
        self.activityIndicator.stopAnimating()
    }
    
    //https://github.com/erangaeb/dev-notes/blob/master/swift/ViewControllerUtils.swift
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

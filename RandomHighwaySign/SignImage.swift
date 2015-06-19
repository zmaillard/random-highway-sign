//
//  SignImage.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/18/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit

class SignImage: UIView, UIScrollViewDelegate {

    let scrollView:UIScrollView =  UIScrollView()
    let imageView:UIImageView =  UIImageView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    @IBOutlet var view: UIView!
    
    var sign : Sign?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed("SignImage", owner: self, options: nil)
        self.addSubview(self.view);    // adding the top level view to the view hierarchy
    }
    
    func loadSign(sign:Sign){
        setupImage()
        setImageData(sign.largeImage)
        self.sign = sign
    }
    
    func setImageData(imageUrl:String){
        let url = NSURL(string: imageUrl)
        let data = NSData(contentsOfURL: url!)
        
        let image = UIImage(data:data!)
        imageView.image = image
        imageView.frame = self.centerFrameFromImage(image)
        
        centerScrollViewContents()
        
        spinner.stopAnimating()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    
    func scrollViewDoubleTapped(recognizer : UITapGestureRecognizer){
        let pointInView = recognizer.locationInView(imageView)
        
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min (newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectZoomTo = CGRectMake(x, y, w, h)
        scrollView.zoomToRect(rectZoomTo, animated: true)
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    
    func centerFrameFromImage(image: UIImage?) -> CGRect {
        if image == nil {
            return CGRectZero
        }
        
        let scaleFactor = scrollView.frame.size.width / image!.size.width
        let newHeight = image!.size.height * scaleFactor
        
        var newImageSize = CGSize(width: scrollView.frame.size.width, height: newHeight)
        
        newImageSize.height = min(scrollView.frame.size.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: scrollView.frame.size.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame
    }
    
    func setupImage(){
        spinner.center = CGPoint(x: view.center.x, y: view.center.y - view.bounds.origin.y / 2.0)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(scrollView)
        
        imageView.contentMode = .ScaleAspectFit
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollView.addSubview(imageView)
        
        var doubleTapRecognizer = UITapGestureRecognizer(target:self, action:"scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        //scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Set contraints
        let bindings = ["scrollView": scrollView, "view": view, "imageView": imageView]
        
        let scrollH:[AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: bindings)
        
        view.addConstraints(scrollH)
        
        let scrollV:[AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: bindings)
        
        view.addConstraints(scrollV)
        
        let containerEqualH:[AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView(==view)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: bindings)
        
        view.addConstraints(containerEqualH)
        
        let containerEqualV:[AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView(==view)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: bindings)
        
        view.addConstraints(containerEqualV)
        
    }

}

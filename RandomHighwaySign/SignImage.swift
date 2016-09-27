//
//  SignImage.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/18/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import Alamofire

class SignImage: UIView, UIScrollViewDelegate {

    let scrollView:UIScrollView =  UIScrollView()
    let imageView:UIImageView =  UIImageView()

    @IBOutlet var view: UIView!
    
    var sign : Sign?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("SignImage", owner: self, options: nil)
        self.addSubview(self.view);    // adding the top level view to the view hierarchy
    }
    
    func loadSign(_ sign:Sign){
        setupImage()
        setImageData(sign.largeImage)
        self.sign = sign
    }
    
    func setImageData(_ imageUrl:String){
        Alamofire.request(.GET, imageUrl).response() {
            (_, _, data, _) in
            
            let image = UIImage(data:data! as! Data)
            self.imageView.image = image
            self.imageView.frame = self.centerFrameFromImage(image)
            
            self.centerScrollViewContents()
        }
    
    
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
    
    
    func scrollViewDoubleTapped(_ recognizer : UITapGestureRecognizer){
        let pointInView = recognizer.location(in: imageView)
        
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min (newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectZoomTo = CGRect(x: x, y: y, width: w, height: h)
        scrollView.zoom(to: rectZoomTo, animated: true)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    
    func centerFrameFromImage(_ image: UIImage?) -> CGRect {
        if image == nil {
            return CGRect.zero
        }
        
        let scaleFactor = scrollView.frame.size.width / image!.size.width
        let newHeight = image!.size.height * scaleFactor
        
        var newImageSize = CGSize(width: scrollView.frame.size.width, height: newHeight)
        
        newImageSize.height = min(scrollView.frame.size.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: scrollView.frame.size.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame
    }
    
    func setupImage(){
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target:self, action:#selector(SignImage.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        //scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Set contraints
        let bindings = ["scrollView": scrollView, "view": view, "imageView": imageView]
        
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView(==view)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView(==view)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        
    }

}

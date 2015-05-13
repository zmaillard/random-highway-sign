//
//  ViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/19/15.

import AVFoundation;
import UIKit
import Alamofire;
import SwiftyJSON;

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var detailsButton: UIBarButtonItem!
    
    var sign : Sign!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        randomSignRequest()
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomSignRequest(){
        //spinner.hidden = false
        //spinner.startAnimating()
        Alamofire.request(.GET, Config.RandomSignEndpoint)
            .responseJSON{(_,_,data,_)in
                let jsonRes = JSON(data!);
                self.sign = Sign.fromJson(jsonRes["signs"][0]);
                self.setImageData(self.sign.largeImage)
                self.navItem.title = self.sign.title
        }
    }


    func setImageData(imageUrl:String){
        let url = NSURL(string: imageUrl)
        let data = NSData(contentsOfURL: url!)
        
        let image = UIImage(data:data!)
        imageView.image = image
        //imageView.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: image!.size)
        
        //scrollView.addSubview(imageView)
        //scrollView.contentSize = image!.size
        
        var doubleTapRecognizer = UITapGestureRecognizer(target:self, action:"scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        // Set the translatesAutoresizingMaskIntoConstraints to NO so that the views autoresizing mask is not translated into auto layout constraints.
        //imageView.setTranslatesAutoresizingMaskIntoConstraints(false);
        //scrollView.setTranslatesAutoresizingMaskIntoConstraints(false);
        
        // Set up the minimum & maximum zoom scales
        // configure image and scroll view for scrolling to extents of actual image
        let widthScale = scrollView.frame.size.width / image!.size.width;
        let heightScale = scrollView.frame.size.height / image!.size.height;
        self.scrollView.minimumZoomScale = max(widthScale, heightScale);
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.scrollView.delegate = self
        centerScrollViewContents()
        
        spinner.stopAnimating()
        spinner.hidden = true
    }

    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        }else{
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height{
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        }else{
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenDetail"{
            if let signDetailsViewController = segue.destinationViewController.topViewController as? SignDetailsViewController{
                signDetailsViewController.sign = self.sign
            }
        }
    }
    
    
    @IBAction func getDetailsTapped(sender : AnyObject) {
        self.randomSignRequest()
    }
    
    @IBAction func loadDetailsPage(segue : UIStoryboardSegue){
        
    }
    
    @IBAction func backToMainController (segue : UIStoryboardSegue){
        
    }
    
}
//
//  SignListViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 10/6/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import UIKit

class SignListViewController: UITableViewController {
    var loadingIndicatorView:LoadingIndicatorView!
    var nextPage:String? = nil

    var urlRequestDelegate:UrlRequestDelegate? = nil;
    
    var isLoading = false{
        didSet{
            if (self.isLoading){
                self.view.addSubview(loadingIndicatorView)
                loadingIndicatorView.showActivity()
                
            }else{
                self.loadingIndicatorView.removeFromSuperview()
                self.loadingIndicatorView.hideActivity()
            }
        }
    }
    
    var signs : [Sign] = [Sign](){
        didSet{
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicatorView = LoadingIndicatorView(frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 80, height: 80)))
        
        
        loadingIndicatorView.center = self.tableView.center
        makeRequest()
    }
    

    
    func getNextPage(){
        if self.nextPage == nil{
            return
        }
        
        self.isLoading = true
        Sign.fetchNext(nextUrl: self.nextPage!)
        { (result: [Sign], next: String?) in
            self.signs = self.signs + result
            self.isLoading = false
            self.nextPage = next
        }
    }
    
    
    
    func makeRequest(){
        
        if let urlReq = urlRequestDelegate?.setUrlRequestType(), let isValid = urlRequestDelegate?.isValidRequest{
            
            if !isValid{
                return
            }
            
            isLoading = true
            
            Sign.fetch(type: urlReq){
                (result: [Sign], next: String?) in
                self.signs = result
                self.isLoading = false
                self.nextPage = next
            }
        }
        
        
    }
}

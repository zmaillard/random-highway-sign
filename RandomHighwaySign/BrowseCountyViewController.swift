//
//  BrowseCountyViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 10/1/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import UIKit

protocol UrlRequestDelegate {
    func setUrlRequestType() -> RandomRequestRouter
    var isValidRequest: Bool { get }
}

class BrowseCountyViewController: UITableViewController, UrlRequestDelegate {
    
    var isValidRequest: Bool {
        return state != nil && county != nil
    }


    var loadingIndicatorView:LoadingIndicatorView!
    var nextPage:String? = nil
    var state:String? = nil
    var county:String? = nil
    
    
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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        loadingIndicatorView = LoadingIndicatorView(frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 80, height: 80)))
        
        
        loadingIndicatorView.center = self.tableView.center
        makeRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "countySignDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.signs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignCell", for: indexPath) as! ResultTableViewCell
        
        let sign = self.signs[(indexPath as NSIndexPath).row]
        
        cell.assignSign(sign)
        
        let rowsToLoadFromBottom = 5;
        let rowsLoaded = self.signs.count
        if (!self.isLoading &&  self.nextPage != nil && ((indexPath as NSIndexPath).row >= (rowsLoaded - rowsToLoadFromBottom)))
        {
            self.getNextPage()
        }
        
        return cell
    }
    
    
    func getNextPage(){
        if self.nextPage == nil{
            return
        }
        
        self.isLoading = true
        Sign.fetchNext(nextUrl: self.nextPage!)
        { (result: [Sign], next: String?) in
            DispatchQueue.global(qos: .background).async{
                self.signs = self.signs + result
                self.nextPage = next
            }
            self.isLoading = false
        }

    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "countySignDetail"){
            if let signViewController = segue.destination as? BrowseSignViewController{
                let indexPath = tableView.indexPathForSelectedRow
                if let tableCell = tableView.cellForRow(at: indexPath!) as? ResultTableViewCell{
                    signViewController.sign = tableCell.sign
                }
                
            }
        }
    }
    
    func setUrlRequestType() -> RandomRequestRouter{
        return RandomRequestRouter.county(state:self.state!,county:self.county!)
    }
    
    func makeRequest(){
        
        if !isValidRequest{
            return
        }

        
        isLoading = true
                
        Sign.fetch(type: setUrlRequestType()){
            (result: [Sign], next: String?) in
            DispatchQueue.global(qos: .background).async{
                self.signs = result
                self.nextPage = next
            }
            self.isLoading = false
        }

        
    }
    
    
}

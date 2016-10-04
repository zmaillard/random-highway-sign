//
//  BrowseCountyViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 10/1/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import UIKit

class BrowseCountyViewController: UITableViewController {

    var currentPage = 1;
    var totalPages = 1;
    var isLoading = false
    
    var signs : Array<Sign> = [Sign]()
    
    var loadingIndicatorView:LoadingIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        loadingIndicatorView = LoadingIndicatorView(frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 80, height: 80)))
        
        
        loadingIndicatorView.center = self.tableView.center
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
        
        /*
        let rowsToLoadFromBottom = 5;
        let rowsLoaded = self.signs.count
        if (!self.isLoading &&  self.currentPage < self.totalPages && ((indexPath as NSIndexPath).row >= (rowsLoaded - rowsToLoadFromBottom)))
        {
            self.currentPage += 1
            self.makeRequest()
        }
        */
        return cell
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
    
    /*
    func makeRequest(){
        isLoading = true
        let userDefaults = UserDefaults.standard
        let radius = userDefaults.integer(forKey: "search_radius")
        
        if (self.currentPage > 1){
            let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            pagingSpinner.startAnimating()
            pagingSpinner.color = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            pagingSpinner.hidesWhenStopped = true
            tableView.tableFooterView = pagingSpinner
        }
        
        let _ = Alamofire.request(RandomRequestRouter.geo(latitude:self.latitude,longitude:self.longitude,radius:radius,page:currentPage))
            .responseObject{(response: DataResponse<SignCollectionResult>)in
                if response.result.error == nil{
                    DispatchQueue.global(qos: .background).async{
                        self.currentPage = response.result.value!.currentPage;
                        self.totalPages = response.result.value!.totalPages;
                        
                        
                        for s in response.result.value!.signs{
                            self.signs.append(s)
                        }
                        
                        self.noResultsToDisplay = self.signs.count == 0
                        
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                            self.loadingIndicatorView.removeFromSuperview()
                            self.loadingIndicatorView.hideActivity()
                            self.isLoading = false
                        }
                        
                    }
                    
                }
        }
    }*/
    
}

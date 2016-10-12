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

class BrowseCountyViewController: SignListViewController, UrlRequestDelegate {
    
    var isValidRequest: Bool {
        return state != nil && county != nil
    }


    var state:String? = nil
    var county:String? = nil
    


    override func viewDidLoad() {
        
        self.urlRequestDelegate = self
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.tableView.register(UINib(nibName: "SignTableViewCell", bundle: nil), forCellReuseIdentifier: "SignCell")
        
        super.viewDidLoad()
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
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "countySignDetail"){
            if let signViewController = segue.destination as? SignImageViewController{
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
    
    
}

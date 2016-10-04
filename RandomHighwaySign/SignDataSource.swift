//
//  SignDataSource.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 10/3/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import UIKit

class LocationService : NSObject{
    
}

class SignDataSource: NSObject, UITableViewDataSource {
    private let tableView:UITableView
    private let signAdapter:SignTableAdapter
    
    init (tableView: UITableView, signAdapter: SignTableAdapter){
        self.tableView = tableView
        self.signAdapter = signAdapter
        
        super.init()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (noResultsToDisplay){
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Results"
            return cell
        }else if (noLocation){
            let cell = UITableViewCell()
            cell.textLabel?.text = "Cannot Determine Location"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignCell", for: indexPath) as! ResultTableViewCell
            
            let sign = self.signs[(indexPath as NSIndexPath).row]
            
            cell.assignSign(sign)
            
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = self.signs.count
            if (!self.isLoading &&  self.nextPage != nil && ((indexPath as NSIndexPath).row >= (rowsLoaded - rowsToLoadFromBottom)))
            {
                self.makeRequest()
            }
            return cell
        }
        
    }
    
}



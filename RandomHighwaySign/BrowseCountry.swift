//
//  BrowseCountry.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 9/28/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class BrowseCountryTableView : UITableViewController{

    var browse:[Browse]?
    var currentItem:SubdivisionType = .country
    var nextBrowseItems:[Browse]?
    var parentBrowse:Browse?
    var selectedBrowse:Browse?
    var signs:[Sign] = [Sign]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (currentItem == .country){
            self.title = "Choose Country"
        }else if (currentItem == .state){
            self.title = "Choose State"
        }else{
            self.title = "Choose All"
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (self.browse == nil){
            return 0;
        }else{
            return self.browse!.count            
        }


    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        self.selectedBrowse = self.browse?[(indexPath as NSIndexPath).row]
        
        //Cannot go deeper than county
        if (self.currentItem != .county){
            
            var next:SubdivisionType
            if (self.currentItem == .country){
                next = .state
            }
            else{
                next = .county
            }
            
            
            self.selectedBrowse?.GetSubdivisions(byType:next, completion: {
                result in
                
                self.nextBrowseItems = result
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showNextPage", sender: self)
                }
                
            })
            
            
        }else{
            var url = RandomRequestRouter.county(state:(self.parentBrowse?.Slug)!,county:(self.selectedBrowse?.Slug)!,page:1);
            
            let _ = Alamofire.request(url)
                .responseObject{(response: DataResponse<SignCollectionResult>)in
                    if response.result.error == nil{
                            //self.currentPage = response.result.value!.currentPage;
                            //self.totalPages = response.result.value!.totalPages;
                            
                            
                            for s in response.result.value!.signs{
                                self.signs.append(s)
                            }
                        
                        
                    }
            }
            
            self.performSegue(withIdentifier: "showCountySigns", sender: self)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
            let browse = self.browse?[(indexPath as NSIndexPath).row]
        
            cell.textLabel?.text = browse?.Name
            return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showNextPage"){
            if let browseCountry = segue.destination as? BrowseCountryTableView{
                browseCountry.parentBrowse = self.selectedBrowse
                browseCountry.browse = nextBrowseItems
                if (self.currentItem == .country){
                    browseCountry.currentItem = .state
                }else if (self.currentItem == .state){
                    browseCountry.currentItem = .county
                }
            }
        }else if (segue.identifier == "showCountySigns"){
            if let browseCounty = segue.destination as? BrowseCountyViewController{
                browseCounty.signs = signs
            }
        }
    }

    
}

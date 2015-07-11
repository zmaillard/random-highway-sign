//
//  SearchResultsDelegate.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 7/9/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import Foundation

protocol SearchResultsDelegate{
    func locationChosen(latitude:Double, longitude:Double);
}
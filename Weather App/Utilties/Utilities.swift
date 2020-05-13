//
//  Utilities.swift
//  Weather App
//
//  Created by Himanshu Joshi on 26/08/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit

import UIKit
import Alamofire
import SwiftyJSON

//Variables

let AQI_URL = "http://api.airpollutionapi.com/1.0/aqi"
let AQI_KEY = "jth8ci36qp6bfu0s4bn25fka94"

var aqiDataJSONArray = [JSON]()

var cityNameArray = [String]()
var tempArrayCelcius = [Int]()
var descriptionArray = [String]()
var aqiArray = [Int]()

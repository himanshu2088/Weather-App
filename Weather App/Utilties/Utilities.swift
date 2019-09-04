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
let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
let APP_ID = "d53a6641c9026a72811d14870db7768d"

var weatherDataJSONArray = [JSON]()

var cityDataArray = [String]()
var tempDataArrayCelcius = [Int]()
var photoDataArray = [UIImage]()
var statusDataArray = [String]()

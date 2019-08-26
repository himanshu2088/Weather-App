//
//  WeatherCell.swift
//  Weather App
//
//  Created by Himanshu Joshi on 26/08/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
   
    func configureCell(weather: Weather) {
        self.cityLabel.text = weather.weatherCity
        self.tempLabel.text = weather.weatherTemp
    }
    
}

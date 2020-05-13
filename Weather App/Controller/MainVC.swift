//
//  ViewController.swift
//  Weather App
//
//  Created by Himanshu Joshi on 26/08/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire
import SVProgressHUD

class MainVC: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
//
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        tableView.reloadData()
        
        tableView.rowHeight = 125
        
        tableView.register(UINib(nibName: "WeatherCell", bundle: nil), forCellReuseIdentifier: "weatherCell")
    }
    
    func userEnteredANewCityName(lat: Double, long: Double, city: String) {
        let params : [String : Any] = ["lat" : lat, "lon" : long, "APPID" : AQI_KEY]
        getAQIData(url: AQI_URL, parameters: params, city: city)
    }
    
    func getAQIData(url: String, parameters: [String: Any], city: String) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let aqiJSON : JSON = JSON(response.result.value!)
                let error = aqiJSON["cod"].intValue
                print(aqiJSON)
                
                if error == 404 {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "Entered city not found. Please write appropriate name.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    aqiDataJSONArray.append(aqiJSON)
                    self.tableView.reloadData()
                    self.classifyData(json: aqiDataJSONArray, city: city)
                }
            }
                
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func classifyData(json: [JSON], city: String) {
        
        aqiDataJSONArray.removeAll()
        for data in json {
            let aqi = data["data"]["value"].intValue
            let temp = data["data"]["temp"].intValue
            let desc = data["data"]["text"].stringValue
            
            if cityNameArray.contains(city) {
                break
            }
            else {
                cityNameArray.append(city)
                aqiArray.append(aqi)
                tempArrayCelcius.append(temp)
                descriptionArray.append(desc)
            }
            
        }
        tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            self.locationManager.stopUpdatingLocation()
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            
            let params2 : [String : Any] = ["lat" : latitude, "lon" : longitude, "APPID" : AQI_KEY]
            
            getAQIData(url: AQI_URL, parameters: params2, city: "Cupertino")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCity" {
            let destinationVC = segue.destination as! SearchCityVC
            destinationVC.delegate = self
        }
    }
    
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        SVProgressHUD.dismiss()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as? WeatherCell else { return UITableViewCell() }
        cell.airQualityIndex.text = "Air Quality Index is " + "\(aqiArray[indexPath.row])"
        cell.cityLabel.text = cityNameArray[indexPath.row]
        cell.statusLabel.text = descriptionArray[indexPath.row]
        cell.tempLabel.text = "\(tempArrayCelcius[indexPath.row])" + "℃"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNameArray.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cityNameArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

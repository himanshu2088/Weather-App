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
        
        let backgroundImage = UIImage(named: "background1")
        let imageView = UIImageView(image: backgroundImage)
        tableView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFill
        
        tableView.rowHeight = 100
        
        tableView.register(UINib(nibName: "WeatherCell", bundle: nil), forCellReuseIdentifier: "weatherCell")
    }
    
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                let weatherJSON : JSON = JSON(response.result.value!)
                let error = weatherJSON["cod"].intValue
                
                if error == 404 {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "Entered city not found. Please write appropriate name.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    weatherDataJSONArray.append(weatherJSON)
                    self.tableView.reloadData()
                    self.classifyData(json: weatherDataJSONArray)
                }
            }
                
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func classifyData(json: [JSON]) {
        
        weatherDataJSONArray.removeAll()
        for data in json {
            let temperature = data["main"]["temp"].intValue - 273
            let city = data["name"].stringValue
            let status = data["weather"][0]["main"].stringValue
            cityDataArray.append(city)
            tempDataArrayCelcius.append(temperature)
            statusDataArray.append(status)
            if let imageName = UIImage(named: status) {
                photoDataArray.append(imageName)
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
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
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
        cell.cityLabel.text = cityDataArray[indexPath.row]
        cell.statusLabel.text = statusDataArray[indexPath.row]
        cell.tempLabel.text = "\(tempDataArrayCelcius[indexPath.row])"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityDataArray.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cityDataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

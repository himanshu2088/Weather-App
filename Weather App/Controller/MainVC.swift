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
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class MainVC: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    //Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    //Variables
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        fetch()
        tableView.reloadData()
        userEnteredANewCityName(city: "Delhi")
        
        tableView.register(UINib(nibName: "WeatherCell", bundle: nil), forCellReuseIdentifier: "weatherCell")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
            userEnteredANewCityName(city: locationString)
            save()
            fetch()
        }
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
                
                weatherDataJSONArray.append(weatherJSON)
                self.tableView.reloadData()
                self.classifyData(json: weatherDataJSONArray)
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
            cityDataArray.append(city)
            tempDataArray.append("\(temperature)")
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
    
    //Core Data Methods
    
    func save() {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let weather = Weather(context: managedContext)
        
        for data in cityDataArray {
            weather.weatherCity = data
        }
        for data1 in tempDataArray {
            weather.weatherTemp = data1
        }
        
        do {
            try managedContext.save()
            print("Successfully saved data")
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
        }
        
    }

    func remove(atIndexPath indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(weatherDataArray[indexPath.row])
        do {
            try managedContext.save()
            print("Successfully removed goal")
        } catch {
            debugPrint("Could not remove goal \(error.localizedDescription)")
        }
    }
    
    func fetch() {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        do {
            weatherDataArray = try managedContext.fetch(fetchRequest) as! [Weather]
            print("Successfully fetched Data")
        } catch {
            debugPrint("Could not fetch \(error.localizedDescription)")
        }
    }
    
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as? WeatherCell else { return UITableViewCell() }
        let weather = weatherDataArray[indexPath.row]
        cell.configureCell(weather: weather)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            self.remove(atIndexPath: indexPath)
            self.fetch()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        return [deleteAction]
    }
    
}

//
//  SearchCityVC.swift
//  Weather App
//
//  Created by Himanshu Joshi on 27/08/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import MapKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(lat: Double, long: Double, city: String)
}

class SearchCityVC: UIViewController, UISearchBarDelegate {
    
    var delegate: ChangeCityDelegate?
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    let tableView: UITableView = UITableView()

    //Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.separatorStyle = .none
        setupTableViewCitySelectVC()
        searchCompleter.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupTableViewCitySelectVC() {
        tableView.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.height - 50)
        tableView.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "cityCell")
        tableView.rowHeight = 45.0
        tableView.allowsSelection = true
        self.view.addSubview(tableView)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }

}

extension SearchCityVC: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }

}

extension SearchCityVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle

        return cell
    }
}

extension SearchCityVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let locationString = searchResults[indexPath.row].title
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationString) { (placemarks, error) in
            if let error = error {
                print("Error converting coordinates from search bar text \(error)")
            }
            let center = placemarks?.first?.location?.coordinate
            let latitude = center?.latitude
            let longitude = center?.longitude
            self.delegate?.userEnteredANewCityName(lat: latitude!, long: longitude!, city: locationString)
        }
            self.dismiss(animated: true, completion: nil)
            SVProgressHUD.show()
    }
}

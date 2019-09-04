//
//  SearchCityVC.swift
//  Weather App
//
//  Created by Himanshu Joshi on 27/08/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

class SearchCityVC: UIViewController, UISearchBarDelegate {
    
    var delegate: ChangeCityDelegate?

    //Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
            delegate?.userEnteredANewCityName(city: locationString)
            self.dismiss(animated: true, completion: nil)
            SVProgressHUD.show()
        }
    }

}

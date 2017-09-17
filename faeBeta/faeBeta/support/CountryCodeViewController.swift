//
//  CountryCodeViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

struct CountryCodeStruct {
    var countryName: String!
    var phoneCode: String!
    
    init(json: JSON) {
        countryName = json["countryName"].stringValue
        phoneCode = json["phoneCode"].stringValue
    }
}

protocol CountryCodeDelegate: class {
    func sendSelectedCountry(country: CountryCodeStruct)
}

class CountryCodeViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    var schbarCountryCode: UISearchBar!
    var tblCountryCode: UITableView!
    var arrCountries = [CountryCodeStruct]()
    var filteredCountries = [CountryCodeStruct]()
    weak var delegate: CountryCodeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadSearchBar()
        loadTable()
        getPhoneCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func getPhoneCode() {
        let path = Bundle.main.path(forResource: "CountryCode", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        let json = JSON(data: jsonData! as Data)["data"]
        
        for each in json.array! {
            let country = CountryCodeStruct(json: each)
            arrCountries.append(country)
        }
        arrCountries.sort{ $0.countryName < $1.countryName }
        tblCountryCode.reloadData()
    }
    
    fileprivate func loadNavBar() {
        let uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        view.addSubview(uiviewNavBar)
        
        let line = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewNavBar.addSubview(line)
        
        let btnCancel = UIButton(frame: CGRect(x: 0, y: 21, width: 87, height: 43))
        uiviewNavBar.addSubview(btnCancel)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._115115115(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnCancel.addTarget(self, action: #selector(self.actionCancel(_:)), for: .touchUpInside)
        
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth - 145) / 2, y: 28, width: 145, height: 27))
        uiviewNavBar.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblTitle.text = "Countries"
    }
    
    func actionCancel(_ sender: UIButton) {
        schbarCountryCode.resignFirstResponder()
        dismiss(animated: true)
    }

    fileprivate func loadSearchBar() {
        schbarCountryCode = UISearchBar(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 40))
        schbarCountryCode.layer.cornerRadius = 5
        schbarCountryCode.barStyle = .default
        schbarCountryCode.placeholder = "Search"
        schbarCountryCode.delegate = self
        view.addSubview(schbarCountryCode)
    }
    
    fileprivate func loadTable() {
        tblCountryCode = UITableView(frame: CGRect(x: 0, y: 105, width: screenWidth, height: screenHeight - 105), style: .plain)
        view.addSubview(tblCountryCode)
        tblCountryCode.backgroundColor = .white
        tblCountryCode.register(CountryCodeCell.self, forCellReuseIdentifier: "CountryCodeCell")
        tblCountryCode.delegate = self
        tblCountryCode.dataSource = self
        tblCountryCode.showsVerticalScrollIndicator = false
    }
    
    func filter(searchText: String, scope: String = "All") {
        filteredCountries = arrCountries.filter({(($0.countryName).lowercased()).range(of: searchText.lowercased()) != nil})
        tblCountryCode.reloadData()
    }
    
    // FaeSearchBarTestDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter(searchText: searchText)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        schbarCountryCode.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        schbarCountryCode.text = ""
        tblCountryCode.reloadData()
    }
    // End of FaeSearchBarTestDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schbarCountryCode.text != "" ? filteredCountries.count : arrCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeCell", for: indexPath) as! CountryCodeCell
        let country = schbarCountryCode.text != "" ? filteredCountries[indexPath.row] : arrCountries[indexPath.row]
        cell.setValueForCell(country: country)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = schbarCountryCode.text != "" ? filteredCountries[indexPath.row] : arrCountries[indexPath.row]
        delegate?.sendSelectedCountry(country: country)
        schbarCountryCode.resignFirstResponder()
        dismiss(animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schbarCountryCode.resignFirstResponder()
    }
}

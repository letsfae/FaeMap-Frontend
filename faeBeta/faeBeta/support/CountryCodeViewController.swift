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
    var countryName: String
    var phoneCode: String
    var countryCode: String
    
    init(json: JSON) {
        countryName = json["countryName"].stringValue
        countryCode = json["countryCode"].stringValue
        phoneCode = json["phoneCode"].stringValue
    }
}

protocol CountryCodeDelegate: class {
    func sendSelectedCountry(country: CountryCodeStruct)
}

class CountryCodeViewController: UIViewController, FaeSearchBarTestDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    private var schbarCountryCode: FaeSearchBarTest!
    private var tblCountryCode: UITableView!
    private var arrCountries = [CountryCodeStruct]()
    private var filteredCountries = [CountryCodeStruct]()
    weak var delegate: CountryCodeDelegate?
    
    // MARK: - Life cycle
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
    
    private func getPhoneCode() {
        let path = Bundle.main.path(forResource: "CountryCode", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        var json: JSON!
        do {
            json = try JSON(data: jsonData! as Data)["data"]
        } catch {
            print("JSON Error: \(error)")
        }
        for each in json.array! {
            let country = CountryCodeStruct(json: each)
            arrCountries.append(country)
        }
        arrCountries.sort{ $0.countryName < $1.countryName }
        tblCountryCode.reloadData()
    }
    
    private func loadNavBar() {
        let uiviewNavBar = UIView(frame: CGRect(x: 0, y: device_offset_top, width: screenWidth, height: 65))
        view.addSubview(uiviewNavBar)
        
        let line = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewNavBar.addSubview(line)
        
        let btnCancel = UIButton(frame: CGRect(x: 0, y: 21, width: 87, height: 43))
        uiviewNavBar.addSubview(btnCancel)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._115115115(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth - 145) / 2, y: 28, width: 145, height: 27))
        uiviewNavBar.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.text = "Countries"
    }
    
    @objc private func actionCancel(_ sender: UIButton) {
        schbarCountryCode.txtSchField.resignFirstResponder()
        dismiss(animated: true)
    }

    private func loadSearchBar() {
        let uiviewSchbar = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 49))
        view.addSubview(uiviewSchbar)
        
        schbarCountryCode = FaeSearchBarTest(frame: CGRect(x: 5, y: 0, width: screenWidth, height: 48))
        schbarCountryCode.txtSchField.placeholder = "Search"
        schbarCountryCode.delegate = self
        uiviewSchbar.addSubview(schbarCountryCode)
        
        let bottomLine = UIView(frame: CGRect(x: 0, y: 48, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = 1
        bottomLine.layer.borderColor = UIColor._200199204cg()
        uiviewSchbar.addSubview(bottomLine)
    }
    
    private func loadTable() {
        tblCountryCode = UITableView(frame: CGRect(x: 0, y: 114 + device_offset_top, width: screenWidth, height: screenHeight - 114 - device_offset_top), style: .plain)
        view.addSubview(tblCountryCode)
        tblCountryCode.backgroundColor = .white
        tblCountryCode.register(CountryCodeCell.self, forCellReuseIdentifier: "CountryCodeCell")
        tblCountryCode.delegate = self
        tblCountryCode.dataSource = self
        tblCountryCode.showsVerticalScrollIndicator = false
    }
    
    // MARK: - FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
    }
    
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        filteredCountries = arrCountries.filter({(($0.countryName).lowercased()).range(of: searchText.lowercased()) != nil})
        tblCountryCode.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarCountryCode.txtSchField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        schbarCountryCode.txtSchField.text = ""
        tblCountryCode.reloadData()
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schbarCountryCode.txtSchField.text != "" ? filteredCountries.count : arrCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeCell", for: indexPath) as! CountryCodeCell
        let country = schbarCountryCode.txtSchField.text != "" ? filteredCountries[indexPath.row] : arrCountries[indexPath.row]
        cell.setValueForCell(country: country)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = schbarCountryCode.txtSchField.text != "" ? filteredCountries[indexPath.row] : arrCountries[indexPath.row]
        delegate?.sendSelectedCountry(country: country)
        schbarCountryCode.txtSchField.resignFirstResponder()
        dismiss(animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schbarCountryCode.txtSchField.resignFirstResponder()
    }
}

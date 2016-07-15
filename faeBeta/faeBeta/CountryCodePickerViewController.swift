//
//  CountryCodePickerViewController.swift
//  faeBeta
//
//  Created by User on 6/30/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol SetCountryCodeDelegate {
    
    func setCountryCode(code : CountryCode)
    
}

struct CountryCode {
    
    let ct : String
    let cd : String
    
}


class CountryCodePickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var SearchBar : UISearchBar!
    var tableView : UITableView!
    
    var searchActive = false
    
    var countries = [CountryCode]()
    var filteredCountries = [CountryCode]()
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeigh = UIScreen.mainScreen().bounds.height
    
    var countryCodeDelegate : SetCountryCodeDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.countries = createPhontBook()
        loadItem()
        tableView.delegate = self
        tableView.dataSource = self
        SearchBar.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell = UITableViewCell(style: .Value1, reuseIdentifier: "cell")
        var country : CountryCode
        if searchActive {
            country = filteredCountries[indexPath.row]
        } else {
            country = countries[indexPath.row]
        }
        cell.textLabel?.text = country.ct
        cell.detailTextLabel?.text = country.cd
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredCountries.count
        } else {
            return countries.count
        }
    }
    
    func filterContentForSearchText(searchText : String, scope: String = "Title") {
        self.filteredCountries = self.countries.filter({ (country) -> Bool in
            //            let categoryMatch = (scope == "Title")
            let stringMatch = country.ct.rangeOfString(searchText)
            return stringMatch != nil
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCountries = countries.filter({ (text) -> Bool in
            let tmp: NSString = text.ct
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if filteredCountries.count == 0 {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let country : CountryCode
        
        if searchActive {
            country = self.filteredCountries[indexPath.row]
        } else {
            country = self.countries[indexPath.row]
        }
        countryCodeDelegate.setCountryCode(country)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadItem() {
        SearchBar = UISearchBar(frame: CGRect(x: 0, y: 20, width: screenWidth, height: 44))
        self.view.addSubview(SearchBar)
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: screenHeigh - 64), style: .Plain)
        self.view.addSubview(tableView)
    }
    
    
    func createPhontBook() -> [CountryCode] {
        var country = [CountryCode]()
        country += [CountryCode(ct: "Afghanistan", cd: "93")]
        country += [CountryCode(ct: "Albania", cd: "355")]
        country += [CountryCode(ct: "Algeria", cd: "213")]
        country += [CountryCode(ct: "American Samoa", cd: "1-684")]
        country += [CountryCode(ct: "Andorra", cd: "376")]
        country += [CountryCode(ct: "Angola", cd: "244")]
        country += [CountryCode(ct: "Anguilla", cd: "1-264")]
        country += [CountryCode(ct: "Antarctica", cd: "672")]
        country += [CountryCode(ct: "Antigua and Barbuda", cd: "1-268")]
        country += [CountryCode(ct: "Argentina", cd: "54")]
        country += [CountryCode(ct: "Armenia", cd: "374")]
        country += [CountryCode(ct: "Aruba", cd: "297")]
        country += [CountryCode(ct: "Australia", cd: "61")]
        country += [CountryCode(ct: "Austria", cd: "43")]
        country += [CountryCode(ct: "Azerbaijan", cd: "994")]
        country += [CountryCode(ct: "Bahamas", cd: "1-242")]
        country += [CountryCode(ct: "Bahrain", cd: "973")]
        country += [CountryCode(ct: "Bangladesh", cd: "880")]
        country += [CountryCode(ct: "Barbados", cd: "1-246")]
        country += [CountryCode(ct: "Belarus", cd: "375")]
        country += [CountryCode(ct: "Belgium", cd: "32")]
        country += [CountryCode(ct: "Belize", cd: "501")]
        country += [CountryCode(ct: "Benin", cd: "229")]
        country += [CountryCode(ct: "Bermuda", cd: "1-441")]
        country += [CountryCode(ct: "Bhutan", cd: "975")]
        country += [CountryCode(ct: "Bolivia", cd: "591")]
        country += [CountryCode(ct: "Bosnia and Herzegovina", cd: "387")]
        country += [CountryCode(ct: "Botswana", cd: "267")]
        country += [CountryCode(ct: "Brazil", cd: "55")]
        country += [CountryCode(ct: "British Indian Ocean Territory", cd: "387")]
        country += [CountryCode(ct: "British Virgin Islands", cd: "1-284")]
        country += [CountryCode(ct: "Brunei", cd: "673")]
        country += [CountryCode(ct: "Burkina Faso", cd: "226")]
        country += [CountryCode(ct: "Bulgaria", cd: "359")]
        country += [CountryCode(ct: "Burundi", cd: "257")]
        country += [CountryCode(ct: "Cambodia", cd: "855")]
        country += [CountryCode(ct: "Cameroon", cd: "237")]
        country += [CountryCode(ct: "Canada", cd: "1")]
        country += [CountryCode(ct: "Cape Verde", cd: "238")]
        country += [CountryCode(ct: "Cayman Islands", cd: "1-345")]
        country += [CountryCode(ct: "Central African Republic", cd: "236")]
        country += [CountryCode(ct: "Chad", cd: "235")]
        country += [CountryCode(ct: "Chile", cd: "56")]
        country += [CountryCode(ct: "China", cd: "86")]
        country += [CountryCode(ct: "Christmas Island", cd: "61")]
        country += [CountryCode(ct: "Cocos Islands", cd: "61")]
        country += [CountryCode(ct: "Colombia", cd: "57")]
        country += [CountryCode(ct: "Comoros", cd: "269")]
        country += [CountryCode(ct: "Cook Islands", cd: "682")]
        country += [CountryCode(ct: "Costa Rica", cd: "506")]
        country += [CountryCode(ct: "Croatia", cd: "385")]
        country += [CountryCode(ct: "Cuba", cd: "53")]
        country += [CountryCode(ct: "Curacao", cd: "599")]
        country += [CountryCode(ct: "Cyprus", cd: "357")]
        country += [CountryCode(ct: "Czech Republic", cd: "420")]
        country += [CountryCode(ct: "Democratic Republic of the Congo", cd: "243")]
        country += [CountryCode(ct: "Denmark", cd: "45")]
        country += [CountryCode(ct: "Djibouti", cd: "253")]
        country += [CountryCode(ct: "Dominica", cd: "1-767")]
        country += [CountryCode(ct: "Dominican Republic", cd: "1-809")]
        country += [CountryCode(ct: "Dominican Republic", cd: "1-829")]
        country += [CountryCode(ct: "Dominican Republic", cd: "1-849")]
        country += [CountryCode(ct: "East Timor", cd: "670")]
        country += [CountryCode(ct: "Ecuador", cd: "593")]
        country += [CountryCode(ct: "Egypt", cd: "20")]
        country += [CountryCode(ct: "El Salvador", cd: "503")]
        country += [CountryCode(ct: "Equatorial Guinea", cd: "240")]
        country += [CountryCode(ct: "Eritrea", cd: "291")]
        country += [CountryCode(ct: "Estonia", cd: "372")]
        country += [CountryCode(ct: "Ethiopia", cd: "251")]
        country += [CountryCode(ct: "Falkland Islands", cd: "500")]
        country += [CountryCode(ct: "Faroe Islands", cd: "298")]
        country += [CountryCode(ct: "Fiji", cd: "679")]
        country += [CountryCode(ct: "Finland", cd: "358")]
        country += [CountryCode(ct: "France", cd: "33")]
        country += [CountryCode(ct: "French Polynesia", cd: "689")]
        country += [CountryCode(ct: "Gabon", cd: "241")]
        country += [CountryCode(ct: "Gambia", cd: "220")]
        country += [CountryCode(ct: "Georgia", cd: "995")]
        country += [CountryCode(ct: "Germany", cd: "49")]
        country += [CountryCode(ct: "Ghana", cd: "233")]
        country += [CountryCode(ct: "Gibraltar", cd: "350")]
        country += [CountryCode(ct: "Greece", cd: "30")]
        country += [CountryCode(ct: "Greenland", cd: "299")]
        country += [CountryCode(ct: "Grenada", cd: "1-473")]
        country += [CountryCode(ct: "Guam", cd: "1-671")]
        country += [CountryCode(ct: "Guatemala", cd: "502")]
        country += [CountryCode(ct: "Guernsey", cd: "44-1481")]
        country += [CountryCode(ct: "Guinea", cd: "224")]
        country += [CountryCode(ct: "Guinea-Bissau", cd: "245")]
        country += [CountryCode(ct: "Guyana", cd: "592")]
        country += [CountryCode(ct: "Haiti", cd: "509")]
        country += [CountryCode(ct: "Honduras", cd: "504")]
        country += [CountryCode(ct: "Hong Kong", cd: "852")]
        country += [CountryCode(ct: "Hungary", cd: "36")]
        country += [CountryCode(ct: "Iceland", cd: "354")]
        country += [CountryCode(ct: "India", cd: "91")]
        country += [CountryCode(ct: "Indonesia", cd: "62")]
        country += [CountryCode(ct: "Iran", cd: "98")]
        country += [CountryCode(ct: "Iraq", cd: "964")]
        country += [CountryCode(ct: "Ireland", cd: "353")]
        country += [CountryCode(ct: "Isle of Man", cd: "44-1624")]
        country += [CountryCode(ct: "Israel", cd: "972")]
        country += [CountryCode(ct: "Italy", cd: "39")]
        country += [CountryCode(ct: "Ivory Coast", cd: "225")]
        country += [CountryCode(ct: "Jamaica", cd: "1-876")]
        country += [CountryCode(ct: "Japan", cd: "81")]
        country += [CountryCode(ct: "Jersey", cd: "44-1534")]
        country += [CountryCode(ct: "Jordan", cd: "962")]
        country += [CountryCode(ct: "Kazakhstan", cd: "7")]
        country += [CountryCode(ct: "Kenya", cd: "254")]
        country += [CountryCode(ct: "Kiribati", cd: "686")]
        country += [CountryCode(ct: "Kosovo", cd: "383")]
        country += [CountryCode(ct: "Kuwait", cd: "965")]
        country += [CountryCode(ct: "Kyrgyzstan", cd: "996")]
        country += [CountryCode(ct: "Laos", cd: "856")]
        country += [CountryCode(ct: "Latvia", cd: "371")]
        country += [CountryCode(ct: "Lebanon", cd: "961")]
        country += [CountryCode(ct: "Lesotho", cd: "266")]
        country += [CountryCode(ct: "Liberia", cd: "231")]
        country += [CountryCode(ct: "Libya", cd: "218")]
        country += [CountryCode(ct: "Liechtenstein", cd: "423")]
        country += [CountryCode(ct: "Lithuania", cd: "370")]
        country += [CountryCode(ct: "Luxembourg", cd: "352")]
        country += [CountryCode(ct: "Macau", cd: "853")]
        country += [CountryCode(ct: "Macedonia", cd: "389")]
        country += [CountryCode(ct: "Madagascar", cd: "261")]
        country += [CountryCode(ct: "Malawi", cd: "265")]
        country += [CountryCode(ct: "Malaysia", cd: "60")]
        country += [CountryCode(ct: "Maldives", cd: "960")]
        country += [CountryCode(ct: "Mali", cd: "223")]
        country += [CountryCode(ct: "Malta", cd: "356")]
        country += [CountryCode(ct: "Marshall Islands", cd: "692")]
        country += [CountryCode(ct: "Mauritania", cd: "222")]
        country += [CountryCode(ct: "Mauritius", cd: "230")]
        country += [CountryCode(ct: "Mayotte", cd: "262")]
        country += [CountryCode(ct: "Mexico", cd: "52")]
        country += [CountryCode(ct: "Micronesia", cd: "691")]
        country += [CountryCode(ct: "Moldova", cd: "373")]
        country += [CountryCode(ct: "Monaco", cd: "377")]
        country += [CountryCode(ct: "Mongolia", cd: "976")]
        country += [CountryCode(ct: "Montenegro", cd: "382")]
        country += [CountryCode(ct: "Montserrat", cd: "1-664")]
        country += [CountryCode(ct: "Mozambique", cd: "258")]
        country += [CountryCode(ct: "Myanmar", cd: "95")]
        country += [CountryCode(ct: "Namibia", cd: "264")]
        country += [CountryCode(ct: "Nauru", cd: "674")]
        country += [CountryCode(ct: "Nepal", cd: "977")]
        country += [CountryCode(ct: "Netherlands", cd: "31")]
        country += [CountryCode(ct: "Netherlands Antilles", cd: "599")]
        country += [CountryCode(ct: "New Caledonia", cd: "687")]
        country += [CountryCode(ct: "New Zealand", cd: "64")]
        country += [CountryCode(ct: "Nicaragua", cd: "505")]
        country += [CountryCode(ct: "Niger", cd: "227")]
        country += [CountryCode(ct: "Nigeria", cd: "234")]
        country += [CountryCode(ct: "Niue", cd: "683")]
        country += [CountryCode(ct: "North Korea", cd: "850")]
        country += [CountryCode(ct: "Northern Mariana Islands", cd: "1-670")]
        country += [CountryCode(ct: "Norway", cd: "47")]
        country += [CountryCode(ct: "Pakistan", cd: "92")]
        country += [CountryCode(ct: "Palau", cd: "680")]
        country += [CountryCode(ct: "Palestine", cd: "970")]
        country += [CountryCode(ct: "Panama", cd: "507")]
        country += [CountryCode(ct: "Papua New Guinea", cd: "675")]
        country += [CountryCode(ct: "Paraguay", cd: "595")]
        country += [CountryCode(ct: "Peru", cd: "51")]
        country += [CountryCode(ct: "Philippines", cd: "63")]
        country += [CountryCode(ct: "Pitcairn", cd: "64")]
        country += [CountryCode(ct: "Poland", cd: "48")]
        country += [CountryCode(ct: "Portugal", cd: "351")]
        country += [CountryCode(ct: "Puerto Rico", cd: "1-787")]
        country += [CountryCode(ct: "Puerto Rico", cd: "1-939")]
        country += [CountryCode(ct: "Qatar", cd: "974")]
        country += [CountryCode(ct: "Republic of the Congo", cd: "242")]
        country += [CountryCode(ct: "Reunion", cd: "262")]
        country += [CountryCode(ct: "Romania", cd: "40")]
        country += [CountryCode(ct: "Russia", cd: "7")]
        country += [CountryCode(ct: "Rwanda", cd: "250")]
        country += [CountryCode(ct: "Saint Barthelemy", cd: "590")]
        country += [CountryCode(ct: "Saint Helena", cd: "262")]
        country += [CountryCode(ct: "Saint Kitts and Nevis", cd: "1-869")]
        country += [CountryCode(ct: "Saint Lucia", cd: "1-758")]
        country += [CountryCode(ct: "Saint Martin", cd: "590")]
        country += [CountryCode(ct: "Saint Pierre and Miquelon", cd: "508")]
        country += [CountryCode(ct: "Saint Vincent and the Grenadines", cd: "1-784")]
        country += [CountryCode(ct: "Samoa", cd: "685")]
        country += [CountryCode(ct: "San Marino", cd: "378")]
        country += [CountryCode(ct: "Sao Tome and Principe", cd: "239")]
        country += [CountryCode(ct: "Saudi Arabia", cd: "966")]
        country += [CountryCode(ct: "Senegal", cd: "221")]
        country += [CountryCode(ct: "Serbia", cd: "381")]
        country += [CountryCode(ct: "Seychelles", cd: "248")]
        country += [CountryCode(ct: "Sierra Leone", cd: "232")]
        country += [CountryCode(ct: "Singapore", cd: "65")]
        country += [CountryCode(ct: "Sint Maarten", cd: "1-721")]
        country += [CountryCode(ct: "Slovakia", cd: "421")]
        country += [CountryCode(ct: "Slovenia", cd: "386")]
        country += [CountryCode(ct: "Solomon Islands", cd: "677")]
        country += [CountryCode(ct: "Somalia", cd: "252")]
        country += [CountryCode(ct: "South Africa", cd: "27")]
        country += [CountryCode(ct: "South Korea", cd: "82")]
        country += [CountryCode(ct: "South Sudan", cd: "211")]
        country += [CountryCode(ct: "Spain", cd: "34")]
        country += [CountryCode(ct: "Sri Lanka", cd: "94")]
        country += [CountryCode(ct: "Sudan", cd: "249")]
        country += [CountryCode(ct: "Suriname", cd: "597")]
        country += [CountryCode(ct: "Svalbard and Jan Mayen", cd: "47")]
        country += [CountryCode(ct: "Swaziland", cd: "268")]
        country += [CountryCode(ct: "Sweden", cd: "46")]
        country += [CountryCode(ct: "Switzerland", cd: "41")]
        country += [CountryCode(ct: "Syria", cd: "963")]
        country += [CountryCode(ct: "Taiwan", cd: "886")]
        country += [CountryCode(ct: "Tajikistan", cd: "992")]
        country += [CountryCode(ct: "Tanzania", cd: "255")]
        country += [CountryCode(ct: "Thailand", cd: "66")]
        country += [CountryCode(ct: "Togo", cd: "228")]
        country += [CountryCode(ct: "Tokelau", cd: "690")]
        country += [CountryCode(ct: "Tonga", cd: "676")]
        country += [CountryCode(ct: "Trinidad and Tobago", cd: "1-868")]
        country += [CountryCode(ct: "Tunisia", cd: "216")]
        country += [CountryCode(ct: "Turkey", cd: "90")]
        country += [CountryCode(ct: "Turkmenistan", cd: "993")]
        country += [CountryCode(ct: "Turks and Caicos Islands", cd: "1-649")]
        country += [CountryCode(ct: "Tuvalu", cd: "688")]
        country += [CountryCode(ct: "U.S. Virgin Islands", cd: "1-340")]
        country += [CountryCode(ct: "Uganda", cd: "256")]
        country += [CountryCode(ct: "United Arab Emirates", cd: "971")]
        country += [CountryCode(ct: "United Kingdom", cd: "44")]
        country += [CountryCode(ct: "United States", cd: "1")]
        country += [CountryCode(ct: "Uruguay", cd: "598")]
        country += [CountryCode(ct: "Uzbekistan", cd: "998")]
        country += [CountryCode(ct: "Vanuatu", cd: "678")]
        country += [CountryCode(ct: "Vatican", cd: "379")]
        country += [CountryCode(ct: "Venezuela", cd: "58")]
        country += [CountryCode(ct: "Vietnam", cd: "84")]
        country += [CountryCode(ct: "Wallis and Futuna", cd: "681")]
        country += [CountryCode(ct: "Western Sahara", cd: "212")]
        country += [CountryCode(ct: "Yemen", cd: "967")]
        country += [CountryCode(ct: "Zambia", cd: "260")]
        country += [CountryCode(ct: "Zimbabwe", cd: "263")]
        return country
    }
    
}


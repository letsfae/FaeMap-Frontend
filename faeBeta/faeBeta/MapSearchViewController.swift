//
//  MapSearchViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-07-28.
//  Copyright © 2017 fae. All rights reserved.
//

class MapSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate, UIScrollViewDelegate {
    
    var placesDict: [String: Int] = ["Concert Hall": 25, "Arcade": 26, "Museum": 27, "Art Museum": 34, "Science Museum": 86, "Performing Arts Venue": 28, "Indie Theater": 28, "Theater": 28, "Music Venue": 68, "Art Gallery": 34, "Baseball Stadium": 60, "Rock Club": 80, "Bars": 14, "Wine Bar": 2, "Sake Bar": 79, "Dive Bar": 14, "Sports Bar": 14, "Beer Bar": 14, "Gastropub": 14, "Irish Pub": 14, "Hookah Bar": 85, "Whisky Bar": 14, "Cocktail Bar": 14, "Hotel Bar": 14, "Beer Garden": 20, "Speakeasy": 14, "Restaurant": 5, "Italian Restaurant": 3, "French Restaurant": 5, "Korean Restaurant": 5, "Seafood Restaurant": 24, "Middle Eastern Restaurant": 5, "Japanese Restaurant": 10, "Sushi Restaurant": 10, "Southern / Soul Food Restaurant": 5, "Filipino Restaurant": 5, "Kosher Restaurant": 5, "South American Restaurant": 5, "Vegetarian / Vegan Restaurant": 78, "Halal Restaurant": 5, "Caribbean Restaurant": 5, "New American Restaurant": 5, "Peruvian Restaurant": 5, "Cajun / Creole Restaurant": 5, "Asian Restaurant": 5, "Chinese Restaurant": 48, "Falafel Restaurant": 5, "Ethiopian Restaurant": 5, "Latin American Restaurant": 5, "Mexican Restaurant": 5, "Thai Restaurant": 5, "Fast Food": 69, "Mediterranean Restaurant": 5, "Indonesian Restaurant": 5, "Vietnamese Restaurant": 5, "Ramen": 45, "American Restaurant": 5, "Hawaiian Restaurant": 5, "Brewery": 77, "Sandwich Place": 55, "Food Court": 5, "Snack Place": 5, "Burrito Place": 71, "Steakhouse": 36, "Buffet": 5, "Bagel Shop": 12, "Hot Dog Joint": 17, "Ice Cream Shop": 16, "Bakery": 13, "Salad Place": 74, "Coffee Shop": 19, "Donut Shop": 12, "Street Food Gathering": 39, "Food Truck": 39, "Burger Joint": 40, "Fried Chicken Joint": 89, "Frozen Yogurt Shop": 43, "Noodle House": 45, "Breakfast": 51, "Dessert Shop": 53, "Deli / Bodega": 55, "Dinner": 5, "Pizza Place": 57, "Taco Place": 83, "Juice Bar": 67, "BBQ Joint": 64, "Athletics & Sports": 1, "Gyms / Fitness Center": 6, "Gyms": 6, "Climbing Gym": 6, "Cycle Studio": 31, "Pilates Studio": 88, "Gymnastics Gym": 6, "Pool": 11, "Martial Arts Dojo": 72, "Soccer Field": 61, "Playground": 73, "Skate Park": 8, "Theme Park": 18, "Parks": 30, "Scenic Lookout": 32, "Plaza": 76, "Canal": 37, "Trail": 42, "Lake": 84, "Beach": 54, "Garden": 56, "Outdoor Sculpture": 87, "Shopping": 4, "Shoppint Mall": 4, "Bookstore": 9, "Jewelry Store": 15, "Flower Shop": 52, "Women's Store": 91, "Leather Goods Store": 4, "Accessories Store": 4, "Clothing Store": 75, "Gourmet Shop": 5, "Music Store": 68, "Organic Grocery": 7, "Spa": 23, "Beer Store": 20, "Grocery Store": 21, "Pharmacy": 29, "Cosmetics Shop": 46, "Convenience Store": 33, "Candy Store": 35, "Moving Target": 39, "Farmers Market": 7, "Liquor Store": 82, "Pet Store": 38, "Wine Shop": 2, "Furniture / Home Store": 70, "Sporting Goods Shop": 47, "Smoke Shop": 49, "Business Service": 44, "Supermarket": 21, "Massage Studio": 23, "Antique Shop": 33, "Market": 33, "Construction & Landscaping": 65, "Paper / Office Supplies Store": 81, "Arts & Crafts Store": 59, "Photography Studio": 66, "Gift Shop": 63, "Health & Beauty Service": 50, "Hotels": 41, "Metro Station": 90, "Light Rail Station": 90, "Airport": 58, "Rental Car Location": 62, "College Classroom": 22, "College Bookstore": 9, "Building": 65, "Library": 9]
    
    var arrLocList = ["Los Angeles CA, United States", "Long Beach CA, United States", "London ON, Canada", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United Statesssss", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United States", "Long Beach CA, United States", "San Francisco CA, United States"]
    //    var cityList = ["CA, United States", "CA, United States", "CA, United States", ""]
    var arrCurtLocList = ["Use my Current Location", "Use Current Map View"]
    
    var filteredPlaces = [String]()
    var filteredLocations = [String]()
    
    var btnBack: UIButton!
    var uiviewSearch: UIView!
    var uiviewPics: UIView!
    var schPlaceBar: FaeSearchBarTest!
    var schLocationBar: FaeSearchBarTest!
    var btnPlace11: UIButton!
    var btnPlace12: UIButton!
    var btnPlace13: UIButton!
    var btnPlace21: UIButton!
    var btnPlace22: UIButton!
    var btnPlace23: UIButton!
    var lblPlace11: UILabel!
    var lblPlace12: UILabel!
    var lblPlace13: UILabel!
    var lblPlace21: UILabel!
    var lblPlace22: UILabel!
    var lblPlace23: UILabel!
    var cellStatus = 0
    
    // uiviews with shadow under table views
    var uiviewSchResBg: UIView!
    var uiviewSchLocResBg: UIView!
    // table tblSearchRes used for search places & display table "use current location"
    var tblPlacesRes: UITableView!
    // table tblLocationRes used for search locations
    var tblLocationRes: UITableView!
    
    var uiviewNoResults: UIView!
    var lblNoResults: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor(r: 241, g: 241, b: 241, alpha: 100)
        loadSearchBar()
        loadPlaceBtns()
        loadTable()
        loadNoResultsView()
        
        uiviewPics.isHidden = false
        uiviewSchResBg.isHidden = true
        uiviewNoResults.isHidden = true
        uiviewSchLocResBg.isHidden = true
    }
    
    // shows "no results"
    func loadNoResultsView() {
        uiviewNoResults = UIView(frame: CGRect(x: 8, y: 124, width: screenWidth - 16, height: 100))
        uiviewNoResults.backgroundColor = .white
        view.addSubview(uiviewNoResults)
        lblNoResults = UILabel(frame: CGRect(x: 0, y: 0, width: 211, height: 50))
        uiviewNoResults.addSubview(lblNoResults)
        lblNoResults.center = CGPoint(x: screenWidth / 2, y: 50)
        lblNoResults.numberOfLines = 0
        lblNoResults.text = "No Results Found...\nTry a Different Search!"
        lblNoResults.textAlignment = .center
        lblNoResults.textColor = UIColor._115115115()
        lblNoResults.font = UIFont(name: "AvenirNext-Medium", size: 15)
        uiviewNoResults.layer.cornerRadius = 2
        addShadow(uiviewNoResults)
    }
    
    func loadSearchBar() {
        uiviewSearch = UIView()
        view.addSubview(uiviewSearch)
        uiviewSearch.backgroundColor = .white
        view.addConstraintsWithFormat("H:|-8-[v0]-8-|", options: [], views: uiviewSearch)
        view.addConstraintsWithFormat("V:|-23-[v0(96)]", options: [], views: uiviewSearch)
        uiviewSearch.layer.cornerRadius = 2
        addShadow(uiviewSearch)
        
        btnBack = UIButton(frame: CGRect(x: 3, y: 0, width: 34.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        btnBack.addTarget(self, action: #selector(self.backToMap(_:)), for: .touchUpInside)
        uiviewSearch.addSubview(btnBack)
        
        schPlaceBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 0, width: screenWidth - 38, height: 47))
        schPlaceBar.delegate = self
        schPlaceBar.txtSchField.placeholder = "Search Fae Map"
        uiviewSearch.addSubview(schPlaceBar)
        
        schLocationBar = FaeSearchBarTest(frame: CGRect(x: 39, y: 49, width: screenWidth - 38, height: 47))
        schLocationBar.delegate = self
        schLocationBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        schLocationBar.txtSchField.placeholder = "Current Location"
        uiviewSearch.addSubview(schLocationBar)
        
        let uiviewDivLine = UIView(frame: CGRect(x: 39, y: 48, width: screenWidth - 94, height: 1))
        uiviewDivLine.layer.borderWidth = 1
        uiviewDivLine.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
        uiviewSearch.addSubview(uiviewDivLine)
    }
    
    // load six buttons
    func loadPlaceBtns() {
        uiviewPics = UIView(frame: CGRect(x: 8, y: 124, width: screenWidth - 16, height: 214))
        uiviewPics.backgroundColor = .white
        view.addSubview(uiviewPics)
        uiviewPics.layer.cornerRadius = 2
        addShadow(uiviewPics)
        
        // row1 col1
        btnPlace11 = UIButton(frame: CGRect(x: 52, y: 20, width: 58, height: 58))
        btnPlace11.layer.borderColor = UIColor.faeAppLineBetweenCellGrayColor().cgColor
        btnPlace11.layer.borderWidth = 2
        btnPlace11.layer.cornerRadius = 8.0
        btnPlace11.contentMode = .scaleAspectFit
        btnPlace11.layer.masksToBounds = true
        btnPlace11.setImage(UIImage(named: "place_result_5"), for: .normal)
        uiviewPics.addSubview(btnPlace11)
        lblPlace11 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18))
        lblPlace11.text = "Restaurants"
        lblPlace11.textAlignment = .center
        lblPlace11.textColor = UIColor.faeAppDescriptionTextGrayColor()
        lblPlace11.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewPics.addSubview(lblPlace11)
        lblPlace11.center = CGPoint(x: btnPlace11.center.x, y: btnPlace11.center.y + 43)
        
        // row1 col2
        btnPlace12 = UIButton(frame: CGRect(x: (screenWidth - 16) / 2 - 29, y: 20, width: 58, height: 58))
        btnPlace12.setImage(UIImage(named: "place_result_14"), for: .normal)
        btnPlace12.layer.borderColor = UIColor.faeAppLineBetweenCellGrayColor().cgColor
        btnPlace12.layer.borderWidth = 2
        btnPlace12.layer.cornerRadius = 8.0
        btnPlace12.contentMode = .scaleAspectFit
        btnPlace12.layer.masksToBounds = true
        uiviewPics.addSubview(btnPlace12)
        lblPlace12 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18))
        lblPlace12.text = "Bars"
        lblPlace12.textAlignment = .center
        lblPlace12.textColor = UIColor.faeAppDescriptionTextGrayColor()
        lblPlace12.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewPics.addSubview(lblPlace12)
        lblPlace12.center = CGPoint(x: btnPlace12.center.x, y: btnPlace11.center.y + 43)
        
        // row1 col3
        btnPlace13 = UIButton(frame: CGRect(x: screenWidth - 126, y: 20, width: 58, height: 58))
        btnPlace13.layer.borderColor = UIColor.faeAppLineBetweenCellGrayColor().cgColor
        btnPlace13.layer.borderWidth = 2
        btnPlace13.layer.cornerRadius = 8.0
        btnPlace13.contentMode = .scaleAspectFit
        btnPlace13.layer.masksToBounds = true
        btnPlace13.setImage(UIImage(named: "place_result_4"), for: .normal)
        uiviewPics.addSubview(btnPlace13)
        lblPlace13 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18))
        lblPlace13.text = "Shopping"
        lblPlace13.textAlignment = .center
        lblPlace13.textColor = UIColor.faeAppDescriptionTextGrayColor()
        lblPlace13.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewPics.addSubview(lblPlace13)
        lblPlace13.center = CGPoint(x: btnPlace13.center.x, y: btnPlace13.center.y + 43)
        
        // row2 col1
        btnPlace21 = UIButton(frame: CGRect(x: 52, y: 117, width: 58, height: 58))
        btnPlace21.layer.borderColor = UIColor.faeAppLineBetweenCellGrayColor().cgColor
        btnPlace21.layer.borderWidth = 2
        btnPlace21.layer.cornerRadius = 8.0
        btnPlace21.contentMode = .scaleAspectFit
        btnPlace21.layer.masksToBounds = true
        btnPlace21.setImage(UIImage(named: "place_result_19"), for: .normal)
        uiviewPics.addSubview(btnPlace21)
        lblPlace21 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18))
        lblPlace21.text = "Coffee Shop"
        lblPlace21.textAlignment = .center
        lblPlace21.textColor = UIColor.faeAppDescriptionTextGrayColor()
        lblPlace21.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewPics.addSubview(lblPlace21)
        lblPlace21.center = CGPoint(x: btnPlace21.center.x, y: btnPlace21.center.y + 43)
        
        // row2 col2
        btnPlace22 = UIButton(frame: CGRect(x: (screenWidth - 16) / 2 - 29, y: 117, width: 58, height: 58))
        btnPlace22.setImage(UIImage(named: "place_result_30"), for: .normal)
        btnPlace22.layer.borderColor = UIColor.faeAppLineBetweenCellGrayColor().cgColor
        btnPlace22.layer.borderWidth = 2
        btnPlace22.layer.cornerRadius = 8.0
        btnPlace22.contentMode = .scaleAspectFit
        btnPlace22.layer.masksToBounds = true
        uiviewPics.addSubview(btnPlace22)
        lblPlace22 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18))
        lblPlace22.text = "Coffee Shop"
        lblPlace22.textAlignment = .center
        lblPlace22.textColor = UIColor.faeAppDescriptionTextGrayColor()
        lblPlace22.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewPics.addSubview(lblPlace22)
        lblPlace22.center = CGPoint(x: btnPlace22.center.x, y: btnPlace22.center.y + 43)
        
        // row2 col3
        btnPlace23 = UIButton(frame: CGRect(x: screenWidth - 126, y: 117, width: 58, height: 58))
        btnPlace23.layer.borderColor = UIColor.faeAppLineBetweenCellGrayColor().cgColor
        btnPlace23.layer.borderWidth = 2
        btnPlace23.layer.cornerRadius = 8.0
        btnPlace23.contentMode = .scaleAspectFit
        btnPlace23.layer.masksToBounds = true
        btnPlace23.setImage(UIImage(named: "place_result_41"), for: .normal)
        uiviewPics.addSubview(btnPlace23)
        lblPlace23 = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18))
        lblPlace23.text = "Coffee Shop"
        lblPlace23.textAlignment = .center
        lblPlace23.textColor = UIColor.faeAppDescriptionTextGrayColor()
        lblPlace23.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewPics.addSubview(lblPlace23)
        lblPlace23.center = CGPoint(x: btnPlace23.center.x, y: btnPlace23.center.y + 43)
    }
    
    func loadTable() {
        // background view with shadow of table tblPlacesRes
        uiviewSchResBg = UIView(frame: CGRect(x: 8, y: 124, width: screenWidth - 16, height: screenHeight - 139)) // 124 + 15
        view.addSubview(uiviewSchResBg)
        addShadow(uiviewSchResBg)
        
        tblPlacesRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 139))
        tblPlacesRes.dataSource = self
        tblPlacesRes.delegate = self
        uiviewSchResBg.addSubview(tblPlacesRes)
        tblPlacesRes.separatorStyle = .none
        tblPlacesRes.backgroundColor = .white
        tblPlacesRes.layer.masksToBounds = true
        tblPlacesRes.layer.cornerRadius = 2
        tblPlacesRes.register(PlacesListCell.self, forCellReuseIdentifier: "SearchPlaces")
        tblPlacesRes.register(LocationListCell.self, forCellReuseIdentifier: "MyFixedCell")
        
        // background view with shadow of table tblLocationRes
        uiviewSchLocResBg = UIView(frame: CGRect(x: 8, y: 124, width: screenWidth - 16, height: screenHeight - 240)) // 124 + 20 + 2 * 48
        uiviewSchLocResBg.backgroundColor = .clear
        view.addSubview(uiviewSchLocResBg)
        addShadow(uiviewSchLocResBg)
        
        tblLocationRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 240))
        tblLocationRes.dataSource = self
        tblLocationRes.delegate = self
        uiviewSchLocResBg.addSubview(tblLocationRes)
        tblLocationRes.layer.cornerRadius = 2
        tblLocationRes.layer.masksToBounds = true
        tblLocationRes.separatorStyle = .none
        tblLocationRes.backgroundColor = .white
        tblLocationRes.register(LocationListCell.self, forCellReuseIdentifier: "SearchLocation")
    }
    
    // FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        cellStatus = searchBar == schPlaceBar ? 0 : 1
        showOrHideViews(searchText: searchBar.txtSchField.text!)
    }
    
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        if searchBar == schLocationBar {
            cellStatus = 1
            filteredLocations.removeAll()
            for location in arrLocList {
                if location.lowercased().range(of: searchText.lowercased()) != nil {
                    filteredLocations.append(location)
                }
            }
        } else {
            cellStatus = 0
            filteredPlaces.removeAll()
            for (key, _) in placesDict {
                if key.lowercased().range(of: searchText.lowercased()) != nil {
                    filteredPlaces.append(key)
                }
            }
        }
        showOrHideViews(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.becomeFirstResponder()
        searchBarTextDidBeginEditing(searchBar)
        //        searchBar.txtSchField.resignFirstResponder()
    }
    
    // show or hide uiviews/tableViews, change uiviews/tableViews size & origin.y
    func showOrHideViews(searchText: String) {
        // search places
        if cellStatus == 0 {
            uiviewSchLocResBg.isHidden = true
            // for uiviewPics & uiviewSchResBg
            if searchText != "" && filteredPlaces.count != 0 {
                uiviewPics.isHidden = true
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124
                uiviewSchResBg.frame.size.height = min(screenHeight - 139, CGFloat(68 * filteredPlaces.count))
                tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            } else {
                uiviewPics.isHidden = false
                uiviewSchResBg.isHidden = true
                if searchText == "" {
                    uiviewPics.frame.origin.y = 124
                } else {
                    uiviewPics.frame.origin.y = 124 + uiviewNoResults.frame.height + 5
                }
            }
            
            // for uiviewNoResults
            if searchText != "" && filteredPlaces.count == 0 {
                uiviewNoResults.isHidden = false
            } else {
                uiviewNoResults.isHidden = true
            }
            tblPlacesRes.isScrollEnabled = true
        } else {  // search location
            uiviewPics.isHidden = true
            uiviewNoResults.isHidden = true
            uiviewSchResBg.isHidden = false
            uiviewSchResBg.frame.size.height = CGFloat(arrCurtLocList.count * 48)
            tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            
            if searchText == "" || filteredLocations.count == 0 {
                uiviewSchResBg.frame.origin.y = 124
                uiviewSchLocResBg.isHidden = true
            } else {
                uiviewSchLocResBg.isHidden = false
                uiviewSchLocResBg.frame.size.height = min(screenHeight - 240, CGFloat(48 * filteredLocations.count))
                tblLocationRes.frame.size.height = uiviewSchLocResBg.frame.size.height
                uiviewSchResBg.frame.origin.y = 124 + uiviewSchLocResBg.frame.height + 5
            }
            tblPlacesRes.isScrollEnabled = false
            tblLocationRes.reloadData()
        }
        tblPlacesRes.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // search location
        if cellStatus == 1 {
            if tableView == tblLocationRes {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocation", for: indexPath as IndexPath) as! LocationListCell
                cell.lblPlaceName.text = filteredLocations[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == tblLocationRes.numberOfRows(inSection: 0) - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyFixedCell", for: indexPath as IndexPath) as! LocationListCell
                cell.lblPlaceName.text = arrCurtLocList[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == arrCurtLocList.count - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            }
        }
        
        // search places - cellStatus == 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath as IndexPath) as! PlacesListCell
        let text = filteredPlaces[indexPath.row]
        cell.lblUserName.text = text
        cell.lblAddress.text = text
        cell.bottomLine.isHidden = false
        if placesDict[text] != nil {
            cell.imgPic.image = UIImage(named: "place_result_\(placesDict[text]!)")
        }
        if indexPath.row == tblPlacesRes.numberOfRows(inSection: 0) - 1 {
            cell.bottomLine.isHidden = true
        } else {
            cell.bottomLine.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // cellStatus == 0 -> search places
        return cellStatus == 0 ? filteredPlaces.count : (tableView == tblLocationRes ? filteredLocations.count : arrCurtLocList.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellStatus == 0 ? 68 : 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // search location
        if cellStatus == 1 {
            if tableView == tblLocationRes {
                schLocationBar.txtSchField.text = filteredLocations[indexPath.row]
            } else {  // fixed cell - "Use my Current Location", "Use Current Map View"
                schLocationBar.txtSchField.text = indexPath.row == 0 ? "Current Location" : "Current Map View"
                schLocationBar.btnClose.isHidden = false
            }
        }
    }
    
    func addShadow(_ uiview: UIView) {
        uiview.layer.shadowColor = UIColor._898989().cgColor
        uiview.layer.shadowRadius = 2.2
        uiview.layer.shadowOffset = CGSize(width: 0, height: 1)
        uiview.layer.shadowOpacity = 0.6
    }
    
    func backToMap(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schPlaceBar.txtSchField.resignFirstResponder()
        schLocationBar.txtSchField.resignFirstResponder()
    }
}

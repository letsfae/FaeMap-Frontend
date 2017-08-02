//
//  MapSearchViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-07-28.
//  Copyright © 2017 fae. All rights reserved.
//
import SwiftyJSON
import MapKit

protocol MapSearchDelegate: class {
    func jumpToOnePlace(searchText: String, place: PlacePin)
    func jumpToPlaces(searchText: String, places: [PlacePin], selectedLoc: CLLocation)
    func backToMainMapFromMapSearch()
}

class MapSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FaeSearchBarTestDelegate, UIScrollViewDelegate {
    
    var placesDict: [String: Int] = ["Concert Hall": 25, "Arcade": 26, "Museum": 27, "Art Museum": 34, "Science Museum": 86, "Performing Arts Venue": 28, "Indie Theater": 28, "Theater": 28, "Music Venue": 68, "Art Gallery": 34, "Baseball Stadium": 60, "Rock Club": 80, "Bars": 14, "Wine Bar": 2, "Sake Bar": 79, "Dive Bar": 14, "Sports Bar": 14, "Beer Bar": 14, "Gastropub": 14, "Irish Pub": 14, "Hookah Bar": 85, "Whisky Bar": 14, "Cocktail Bar": 14, "Hotel Bar": 14, "Beer Garden": 20, "Speakeasy": 14, "Restaurant": 5, "Italian Restaurant": 3, "French Restaurant": 5, "Korean Restaurant": 5, "Seafood Restaurant": 24, "Middle Eastern Restaurant": 5, "Japanese Restaurant": 10, "Sushi Restaurant": 10, "Southern / Soul Food Restaurant": 5, "Filipino Restaurant": 5, "Kosher Restaurant": 5, "South American Restaurant": 5, "Vegetarian / Vegan Restaurant": 78, "Halal Restaurant": 5, "Caribbean Restaurant": 5, "New American Restaurant": 5, "Peruvian Restaurant": 5, "Cajun / Creole Restaurant": 5, "Asian Restaurant": 5, "Chinese Restaurant": 48, "Falafel Restaurant": 5, "Ethiopian Restaurant": 5, "Latin American Restaurant": 5, "Mexican Restaurant": 5, "Thai Restaurant": 5, "Fast Food": 69, "Mediterranean Restaurant": 5, "Indonesian Restaurant": 5, "Vietnamese Restaurant": 5, "Ramen": 45, "American Restaurant": 5, "Hawaiian Restaurant": 5, "Brewery": 77, "Sandwich Place": 55, "Food Court": 5, "Snack Place": 5, "Burrito Place": 71, "Steakhouse": 36, "Buffet": 5, "Bagel Shop": 12, "Hot Dog Joint": 17, "Ice Cream Shop": 16, "Bakery": 13, "Salad Place": 74, "Coffee Shop": 19, "Donut Shop": 12, "Street Food Gathering": 39, "Food Truck": 39, "Burger Joint": 40, "Fried Chicken Joint": 89, "Frozen Yogurt Shop": 43, "Noodle House": 45, "Breakfast": 51, "Dessert Shop": 53, "Deli / Bodega": 55, "Dinner": 5, "Pizza Place": 57, "Taco Place": 83, "Juice Bar": 67, "BBQ Joint": 64, "Athletics & Sports": 1, "Gyms / Fitness Center": 6, "Gyms": 6, "Climbing Gym": 6, "Cycle Studio": 31, "Pilates Studio": 88, "Gymnastics Gym": 6, "Pool": 11, "Martial Arts Dojo": 72, "Soccer Field": 61, "Playground": 73, "Skate Park": 8, "Theme Park": 18, "Parks": 30, "Scenic Lookout": 32, "Plaza": 76, "Canal": 37, "Trail": 42, "Lake": 84, "Beach": 54, "Garden": 56, "Outdoor Sculpture": 87, "Shopping": 4, "Shoppint Mall": 4, "Bookstore": 9, "Jewelry Store": 15, "Flower Shop": 52, "Women's Store": 91, "Leather Goods Store": 4, "Accessories Store": 4, "Clothing Store": 75, "Gourmet Shop": 5, "Music Store": 68, "Organic Grocery": 7, "Spa": 23, "Beer Store": 20, "Grocery Store": 21, "Pharmacy": 29, "Cosmetics Shop": 46, "Convenience Store": 33, "Candy Store": 35, "Moving Target": 39, "Farmers Market": 7, "Liquor Store": 82, "Pet Store": 38, "Wine Shop": 2, "Furniture / Home Store": 70, "Sporting Goods Shop": 47, "Smoke Shop": 49, "Business Service": 44, "Supermarket": 21, "Massage Studio": 23, "Antique Shop": 33, "Market": 33, "Construction & Landscaping": 65, "Paper / Office Supplies Store": 81, "Arts & Crafts Store": 59, "Photography Studio": 66, "Gift Shop": 63, "Health & Beauty Service": 50, "Hotels": 41, "Metro Station": 90, "Light Rail Station": 90, "Airport": 58, "Rental Car Location": 62, "College Classroom": 22, "College Bookstore": 9, "Building": 65, "Library": 9]
    
    var arrLocList = ["Los Angeles CA, United States", "Long Beach CA, United States", "London ON, Canada", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United Statesssss", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United States", "Long Beach CA, United States", "San Francisco CA, United States"]
    //    var cityList = ["CA, United States", "CA, United States", "CA, United States", ""]
    var arrCurtLocList = ["Use my Current Location", "Use Current Map View"]
    
    weak var delegate: MapSearchDelegate?
    
    var searchedPlaces = [PlacePin]()
    var filteredPlaces = [PlacePin]()
//    var searchedLocations = [String]()   有location数据后使用
    var filteredLocations = [String]()
    var searchedLoc: CLLocation!
    var faeMapView: MKMapView!
    
    var btnBack: UIButton!
    var uiviewSearch: UIView!
    var uiviewPics: UIView!
    var schPlaceBar: FaeSearchBarTest!
    var schLocationBar: FaeSearchBarTest!
    var btnPlaces = [UIButton]()
    var lblPlaces = [UILabel]()
    var imgPlaces: [UIImage] = [#imageLiteral(resourceName: "place_result_5"), #imageLiteral(resourceName: "place_result_14"), #imageLiteral(resourceName: "place_result_4"), #imageLiteral(resourceName: "place_result_19"), #imageLiteral(resourceName: "place_result_30"), #imageLiteral(resourceName: "place_result_41")]
    var arrPlaceNames: [String] = ["Restaurants", "Bars", "Shopping", "Coffee Shop", "Parks", "Hotels"]
    var strSearchedPlace: String!
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
        
        schPlaceBar.txtSchField.becomeFirstResponder()
        searchedLoc = LocManager.shared.curtLoc
        getPlaceInfo()
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
        
        schPlaceBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 0, width: screenWidth - 38, height: 48))
        schPlaceBar.delegate = self
        schPlaceBar.txtSchField.placeholder = "Search Fae Map"
        if strSearchedPlace != "Search Fae Map" {
            schPlaceBar.txtSchField.text = strSearchedPlace
            schPlaceBar.btnClose.isHidden = false
        }
        uiviewSearch.addSubview(schPlaceBar)
        
        schLocationBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 48, width: screenWidth - 38, height: 48))
        schLocationBar.delegate = self
        schLocationBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        schLocationBar.txtSchField.text = "Current Location"
        schLocationBar.txtSchField.returnKeyType = .next
        uiviewSearch.addSubview(schLocationBar)
        
        let uiviewDivLine = UIView(frame: CGRect(x: 39, y: 47.5, width: screenWidth - 94, height: 1))
        uiviewDivLine.layer.borderWidth = 1
        uiviewDivLine.layer.borderColor = UIColor._200199204cg()
        uiviewSearch.addSubview(uiviewDivLine)
    }
    
    // load six buttons
    func loadPlaceBtns() {
        uiviewPics = UIView(frame: CGRect(x: 8, y: 124, width: screenWidth - 16, height: 214))
        uiviewPics.backgroundColor = .white
        view.addSubview(uiviewPics)
        uiviewPics.layer.cornerRadius = 2
        addShadow(uiviewPics)
        
        for _ in 0..<6 {
            btnPlaces.append(UIButton(frame: CGRect(x: 52, y: 20, width: 58, height: 58)))
            lblPlaces.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        
        for i in 0..<6 {
            if i >= 3 {
                btnPlaces[i].frame.origin.y = 117
            }
            if i == 1 || i == 4 {
                btnPlaces[i].frame.origin.x = (screenWidth - 16 - 58) / 2
            } else if i == 2 || i == 5 {
                btnPlaces[i].frame.origin.x = screenWidth - 126
            }
            
            lblPlaces[i].center = CGPoint(x: btnPlaces[i].center.x, y: btnPlaces[i].center.y + 43)
            
            uiviewPics.addSubview(btnPlaces[i])
            uiviewPics.addSubview(lblPlaces[i])
            
            btnPlaces[i].layer.borderColor = UIColor._225225225().cgColor
            btnPlaces[i].layer.borderWidth = 2
            btnPlaces[i].layer.cornerRadius = 8.0
            btnPlaces[i].contentMode = .scaleAspectFit
            btnPlaces[i].layer.masksToBounds = true
            btnPlaces[i].setImage(imgPlaces[i], for: .normal)
            btnPlaces[i].tag = i
            btnPlaces[i].addTarget(self, action: #selector(self.searchByCategories(_:)), for: .touchUpInside)
            
            lblPlaces[i].text = arrPlaceNames[i]
            lblPlaces[i].textAlignment = .center
            lblPlaces[i].textColor = UIColor._138138138()
            lblPlaces[i].font = UIFont(name: "AvenirNext-Medium", size: 13)
        }
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
        if searchBar == schPlaceBar {   // search places
            cellStatus = 0
        } else {   // search locations
            cellStatus = 1
            if searchBar.txtSchField.text == "Current Location" || searchBar.txtSchField.text == "Current Map View" {
                searchBar.txtSchField.placeholder = searchBar.txtSchField.text
                searchBar.txtSchField.text = ""
                searchBar.btnClose.isHidden = true
            }
        }
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
            for searchedPlace in searchedPlaces {
                if searchedPlace.name.lowercased().range(of: searchText.lowercased()) != nil {
                    filteredPlaces.append(searchedPlace)
                }
            }
        }
        showOrHideViews(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.resignFirstResponder()
        
        if searchBar == schPlaceBar {
            delegate?.jumpToPlaces(searchText: searchBar.txtSchField.text!, places: filteredPlaces, selectedLoc: searchedLoc)
            navigationController?.popViewController(animated: false)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.becomeFirstResponder()
    }
    // End of FaeSearchBarTestDelegate
    
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
                cell.lblLocationName.text = filteredLocations[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == tblLocationRes.numberOfRows(inSection: 0) - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyFixedCell", for: indexPath as IndexPath) as! LocationListCell
                cell.lblLocationName.text = arrCurtLocList[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == arrCurtLocList.count - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            }
        }
        
        // search places - cellStatus == 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath as IndexPath) as! PlacesListCell
        let place = filteredPlaces[indexPath.row]
        
        DispatchQueue.global(qos: .userInitiated).async {
            let img = UIImage(named: "place_result_\(place.class_2_icon_id)") ?? #imageLiteral(resourceName: "Awkward")
            DispatchQueue.main.async {
                cell.imgIcon.image = img
            }
        }
        cell.lblPlaceName.text = place.name
        cell.lblAddress.text = place.address1 + ", " + place.address2
        cell.bottomLine.isHidden = false

        if indexPath.row == tblPlacesRes.numberOfRows(inSection: 0) - 1 {
            cell.bottomLine.isHidden = true
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
                schLocationBar.btnClose.isHidden = false
            } else {  // fixed cell - "Use my Current Location", "Use Current Map View"
                schLocationBar.txtSchField.text = indexPath.row == 0 ? "Current Location" : "Current Map View"
                schLocationBar.txtSchField.resignFirstResponder()
                schLocationBar.btnClose.isHidden = true
                
                if indexPath.row == 0 {
                    searchedLoc = LocManager.shared.curtLoc
                } else {
                    let mapCenter_point = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
                    searchedLoc = CLLocation(latitude: faeMapView.convert(mapCenter_point, toCoordinateFrom: nil).latitude,
                                             longitude: faeMapView.convert(mapCenter_point, toCoordinateFrom: nil).longitude)
                }
                getPlaceInfo()
            }
        } else { // search places
            let selectedPlace = filteredPlaces[indexPath.row]
            delegate?.jumpToOnePlace(searchText: selectedPlace.name, place: selectedPlace)
            navigationController?.popViewController(animated: false)
        }
    }
    
    func addShadow(_ uiview: UIView) {
        uiview.layer.shadowColor = UIColor._898989().cgColor
        uiview.layer.shadowRadius = 2.2
        uiview.layer.shadowOffset = CGSize(width: 0, height: 1)
        uiview.layer.shadowOpacity = 0.6
    }
    
    func backToMap(_ sender: UIButton) {
        delegate?.backToMainMapFromMapSearch()
        navigationController?.popViewController(animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schPlaceBar.txtSchField.resignFirstResponder()
        schLocationBar.txtSchField.resignFirstResponder()
    }
    
    func getPlaceInfo() {
        let placesList = FaeMap()
        placesList.whereKey("geo_latitude", value: "\(searchedLoc.coordinate.latitude)")
        placesList.whereKey("geo_longitude", value: "\(searchedLoc.coordinate.longitude)")
        placesList.whereKey("radius", value: "50000")
        placesList.whereKey("type", value: "place")
        placesList.whereKey("max_count", value: "1000")
        placesList.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMapSearchPlaceInfo] status/100 != 2")
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                print("[loadMapSearchPlaceInfo] fail to parse map search place info")
                return
            }
            if placeInfoJsonArray.count <= 0 {
                print("[loadMapSearchPlaceInfo] array is nil")
                return
            }
            
            self.searchedPlaces.removeAll()
            
            for result in placeInfoJsonArray {
                let placeData = PlacePin(json: result)
//                if placeData.class_2_icon_id != 0 {
                    self.searchedPlaces.append(placeData)
//                }
            }
            print(self.searchedPlaces.count)
        }
    }
    
    func searchByCategories(_ sender: UIButton) {
        // tag = 0 - Restaurants - arrPlaceNames[0], 1 - Bars - arrPlaceNames[1],
        // 2 - Shopping - arrPlaceNames[2], 3 - Coffee Shop - arrPlaceNames[3],
        // 4 - Parks - arrPlaceNames[4], 5 - Hotels - arrPlaceNames[5]
        switch sender.tag {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        default:
            break
        }
    }
}

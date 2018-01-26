//
//  MapSearchViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-07-28.
//  Copyright © 2017 fae. All rights reserved.
//
import SwiftyJSON
import MapKit

import GooglePlaces

@objc protocol MapSearchDelegate: class {
    @objc optional func jumpToOnePlace(searchText: String, place: PlacePin)
    @objc optional func jumpToPlaces(searchText: String, places: [PlacePin], selectedLoc: CLLocation)
//    func backToMainMapFromMapSearch()
    @objc optional func jumpToLocation(region: MKCoordinateRegion)
}

class MapSearchViewController: UIViewController, FaeSearchBarTestDelegate {
    
    var categories: [String: Int] = ["Concert Hall": 25, "Arcade": 26, "Museum": 27, "Art Museum": 34, "Science Museum": 86, "Performing Arts Venue": 28, "Indie Theater": 28, "Theater": 28, "Music Venue": 68, "Art Gallery": 34, "Baseball Stadium": 60, "Rock Club": 80, "Bars": 14, "Wine Bar": 2, "Sake Bar": 79, "Dive Bar": 14, "Sports Bar": 14, "Beer Bar": 14, "Gastropub": 14, "Irish Pub": 14, "Hookah Bar": 85, "Whisky Bar": 14, "Cocktail Bar": 14, "Hotel Bar": 14, "Beer Garden": 20, "Speakeasy": 14, "Restaurant": 5, "Italian Restaurant": 3, "French Restaurant": 5, "Korean Restaurant": 5, "Seafood Restaurant": 24, "Middle Eastern Restaurant": 5, "Japanese Restaurant": 10, "Sushi Restaurant": 10, "Southern / Soul Food Restaurant": 5, "Filipino Restaurant": 5, "Kosher Restaurant": 5, "South American Restaurant": 5, "Vegetarian / Vegan Restaurant": 78, "Halal Restaurant": 5, "Caribbean Restaurant": 5, "New American Restaurant": 5, "Peruvian Restaurant": 5, "Cajun / Creole Restaurant": 5, "Asian Restaurant": 5, "Chinese Restaurant": 48, "Falafel Restaurant": 5, "Ethiopian Restaurant": 5, "Latin American Restaurant": 5, "Mexican Restaurant": 5, "Thai Restaurant": 5, "Fast Food": 69, "Mediterranean Restaurant": 5, "Indonesian Restaurant": 5, "Vietnamese Restaurant": 5, "Ramen": 45, "American Restaurant": 5, "Hawaiian Restaurant": 5, "Brewery": 77, "Sandwich Place": 55, "Food Court": 5, "Snack Place": 5, "Burrito Place": 71, "Steakhouse": 36, "Buffet": 5, "Bagel Shop": 12, "Hot Dog Joint": 17, "Ice Cream Shop": 16, "Bakery": 13, "Salad Place": 74, "Coffee Shop": 19, "Donut Shop": 12, "Street Food Gathering": 39, "Food Truck": 39, "Burger Joint": 40, "Fried Chicken Joint": 89, "Frozen Yogurt Shop": 43, "Noodle House": 45, "Breakfast": 51, "Dessert Shop": 53, "Deli / Bodega": 55, "Dinner": 5, "Pizza Place": 57, "Taco Place": 83, "Juice Bar": 67, "BBQ Joint": 64, "Athletics & Sports": 1, "Gyms / Fitness Center": 6, "Gyms": 6, "Climbing Gym": 6, "Cycle Studio": 31, "Pilates Studio": 88, "Gymnastics Gym": 6, "Pool": 11, "Martial Arts Dojo": 72, "Soccer Field": 61, "Playground": 73, "Skate Park": 8, "Theme Park": 18, "Parks": 30, "Scenic Lookout": 32, "Plaza": 76, "Canal": 37, "Trail": 42, "Lake": 84, "Beach": 54, "Garden": 56, "Outdoor Sculpture": 87, "Shopping": 4, "Shoppint Mall": 4, "Bookstore": 9, "Jewelry Store": 15, "Flower Shop": 52, "Women's Store": 91, "Leather Goods Store": 4, "Accessories Store": 4, "Clothing Store": 75, "Gourmet Shop": 5, "Music Store": 68, "Organic Grocery": 7, "Spa": 23, "Beer Store": 20, "Grocery Store": 21, "Pharmacy": 29, "Cosmetics Shop": 46, "Convenience Store": 33, "Candy Store": 35, "Moving Target": 39, "Farmers Market": 7, "Liquor Store": 82, "Pet Store": 38, "Wine Shop": 2, "Furniture / Home Store": 70, "Sporting Goods Shop": 47, "Smoke Shop": 49, "Business Service": 44, "Supermarket": 21, "Massage Studio": 23, "Antique Shop": 33, "Market": 33, "Construction & Landscaping": 65, "Paper / Office Supplies Store": 81, "Arts & Crafts Store": 59, "Photography Studio": 66, "Gift Shop": 63, "Health & Beauty Service": 50, "Hotels": 41, "Metro Station": 90, "Light Rail Station": 90, "Airport": 58, "Rental Car Location": 62, "College Classroom": 22, "College Bookstore": 9, "Building": 65, "Library": 9]
    var filteredCategory = [(key: String, value: Int)]()
    
    var arrLocList: [String] = ["Los Angeles CA, United States", "Long Beach CA, United States", "London ON, Canada", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United Statesssss", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United States", "Long Beach CA, United States", "San Francisco CA, United States"]
    //    var cityList = ["CA, United States", "CA, United States", "CA, United States", ""]
    var arrCurtLocList: [String] = ["Use my Current Location", "Use Current Map View"]
    
    weak var delegate: MapSearchDelegate?
    
    var searchedPlaces = [PlacePin]()
    var filteredPlaces = [PlacePin]()
//    var searchedLocations = [String]()   有location数据后使用
    var filteredLocations = [String]()
    var faeMapView: MKMapView!
    
    var btnBack: UIButton!
    var uiviewSearch: UIView!
    var uiviewPics: UIView!
    var schPlaceBar: FaeSearchBarTest!
    var schLocationBar: FaeSearchBarTest!
    var btnPlaces = [UIButton]()
    var lblPlaces = [UILabel]()
    var imgPlaces: [UIImage] = [#imageLiteral(resourceName: "place_result_5"), #imageLiteral(resourceName: "place_result_14"), #imageLiteral(resourceName: "place_result_4"), #imageLiteral(resourceName: "place_result_19"), #imageLiteral(resourceName: "place_result_30"), #imageLiteral(resourceName: "place_result_41")]
    var arrPlaceNames: [String] = ["Restaurant", "Bars", "Shopping", "Coffee Shop", "Parks", "Hotels"]
    var strSearchedPlace: String! = ""
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
    
    // MapKit address autocompletion
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    // Google address autocompletion
    var googleFilter = GMSAutocompleteFilter()
    var googlePredictions = [GMSAutocompletePrediction]()
    
    var boolFromChat: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor._241241241()
        loadSearchBar()
        loadPlaceBtns()
        loadTable()
        loadNoResultsView()
        
        schPlaceBar.txtSchField.becomeFirstResponder()
        searchCompleter.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /**
        var delay: Double = 0
        for i in 0..<6 {
            UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.btnPlaces[i].frame.size = CGSize(width: 58, height: 58)
                self.btnPlaces[i].alpha = 1
                self.lblPlaces[i].center.y += 43
                self.lblPlaces[i].alpha = 1
                if i >= 3 {
                    self.btnPlaces[i].frame.origin.y = 117
                } else {
                    self.btnPlaces[i].frame.origin.y = 20
                }
                if i == 1 || i == 4 {
                    self.btnPlaces[i].frame.origin.x = (screenWidth - 16 - 58) / 2
                } else if i == 2 || i == 5 {
                    self.btnPlaces[i].frame.origin.x = screenWidth - 126
                } else {
                    self.btnPlaces[i].frame.origin.x = 52
                }
            }, completion: nil)
            delay += 0.1
        }
         */
    }
    
    // shows "no results"
    func loadNoResultsView() {
        uiviewNoResults = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: 100))
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
        view.addConstraintsWithFormat("V:|-\(23+device_offset_top)-[v0(96)]", options: [], views: uiviewSearch)
        uiviewSearch.layer.cornerRadius = 2
        addShadow(uiviewSearch)
        
        btnBack = UIButton(frame: CGRect(x: 3, y: 0, width: 34.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        btnBack.addTarget(self, action: #selector(self.backToMap(_:)), for: .touchUpInside)
        uiviewSearch.addSubview(btnBack)
        
        schPlaceBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 0, width: screenWidth - 38, height: 48))
        schPlaceBar.delegate = self
        schPlaceBar.txtSchField.placeholder = !boolFromChat ? "Search Fae Map" : "Search Place or Address"
        if strSearchedPlace != "Search Fae Map" {
            schPlaceBar.txtSchField.text = strSearchedPlace
            schPlaceBar.btnClose.isHidden = false
        }
        uiviewSearch.addSubview(schPlaceBar)
        
        schLocationBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 48, width: screenWidth - 38, height: 48))
        schLocationBar.delegate = self
        schLocationBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        if Key.shared.selectedPrediction != nil {
            schLocationBar.txtSchField.attributedText = Key.shared.selectedPrediction?.faeSearchBarAttributedText()
        } else {
            schLocationBar.txtSchField.text = "Current Location"
        }
        schLocationBar.txtSchField.returnKeyType = .next
        uiviewSearch.addSubview(schLocationBar)
        
        let uiviewDivLine = UIView(frame: CGRect(x: 39, y: 47.5, width: screenWidth - 94, height: 1))
        uiviewDivLine.layer.borderWidth = 1
        uiviewDivLine.layer.borderColor = UIColor._200199204cg()
        uiviewSearch.addSubview(uiviewDivLine)
    }
    
    // load six buttons
    func loadPlaceBtns() {
        uiviewPics = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: 214))
        uiviewPics.backgroundColor = .white
        view.addSubview(uiviewPics)
        uiviewPics.layer.cornerRadius = 2
        addShadow(uiviewPics)
        
        
        /**
        for _ in 0..<6 {
            btnPlaces.append(UIButton(frame: CGRect(x: 52 + 29, y: 20 + 29, width: 0, height: 0)))
            lblPlaces.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        
        for i in 0..<6 {
            self.btnPlaces[i].alpha = 0
            if i >= 3 {
                btnPlaces[i].frame.origin.y = 117 + 29
            }
            if i == 1 || i == 4 {
                btnPlaces[i].frame.origin.x = (screenWidth - 16 - 58) / 2 + 29
            } else if i == 2 || i == 5 {
                btnPlaces[i].frame.origin.x = screenWidth - 126 + 29
            }
            
            lblPlaces[i].center = CGPoint(x: btnPlaces[i].center.x, y: btnPlaces[i].center.y)
            lblPlaces[i].alpha = 0
            
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
         */
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
        uiviewSchResBg = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: screenHeight - 139 - device_offset_top)) // 124 + 15
        view.addSubview(uiviewSchResBg)
        addShadow(uiviewSchResBg)
        
        tblPlacesRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 139 - device_offset_top - device_offset_bot))
        tblPlacesRes.dataSource = self
        tblPlacesRes.delegate = self
        uiviewSchResBg.addSubview(tblPlacesRes)
        tblPlacesRes.separatorStyle = .none
        tblPlacesRes.backgroundColor = .white
        tblPlacesRes.layer.masksToBounds = true
        tblPlacesRes.layer.cornerRadius = 2
        tblPlacesRes.register(PlacesListCell.self, forCellReuseIdentifier: "SearchPlaces")
        tblPlacesRes.register(LocationListCell.self, forCellReuseIdentifier: "MyFixedCell")
        tblPlacesRes.register(CategoryListCell.self, forCellReuseIdentifier: "SearchCategories")
        
        // background view with shadow of table tblLocationRes
        uiviewSchLocResBg = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: screenHeight - 240 - device_offset_top - device_offset_bot)) // 124 + 20 + 2 * 48
        uiviewSchLocResBg.backgroundColor = .clear
        view.addSubview(uiviewSchLocResBg)
        addShadow(uiviewSchLocResBg)
        
        tblLocationRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 240 - device_offset_top - device_offset_bot))
        tblLocationRes.dataSource = self
        tblLocationRes.delegate = self
        uiviewSchLocResBg.addSubview(tblLocationRes)
        tblLocationRes.layer.cornerRadius = 2
        tblLocationRes.layer.masksToBounds = true
        tblLocationRes.separatorStyle = .none
        tblLocationRes.backgroundColor = .white
        tblLocationRes.register(LocationListCell.self, forCellReuseIdentifier: "SearchLocation")
    }
    
    func addShadow(_ uiview: UIView) {
        uiview.layer.shadowColor = UIColor._898989().cgColor
        uiview.layer.shadowRadius = 2.2
        uiview.layer.shadowOffset = CGSize(width: 0, height: 1)
        uiview.layer.shadowOpacity = 0.6
    }
    
    @objc func backToMap(_ sender: UIButton) {
//        delegate?.backToMainMapFromMapSearch()
        navigationController?.popViewController(animated: false)
    }
    
    func getPlaceInfo(content: String = "", source: String = "name") {
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "200")
        FaeSearch.shared.whereKey("radius", value: "99999999")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": LocManager.shared.searchedLoc.coordinate.latitude,
                                                      "longitude": LocManager.shared.searchedLoc.coordinate.longitude])
        FaeSearch.shared.search { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
//                print("[loadMapSearchPlaceInfo] status/100 != 2")
                self.showOrHideViews(searchText: content)
                return
            }
            let placeInfoJSON = JSON(message!)
//            print(placeInfoJSON)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
//                print("[loadMapSearchPlaceInfo] fail to parse map search place info")
                self.showOrHideViews(searchText: content)
                return
            }
            self.filteredPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
//            print(self.filteredPlaces.count)
            
            if source == "name" {
                self.showOrHideViews(searchText: content)
            } else {
                self.delegate?.jumpToPlaces?(searchText: content, places: self.filteredPlaces, selectedLoc: LocManager.shared.searchedLoc)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    @objc func searchByCategories(_ sender: UIButton) {
        // tag = 0 - Restaurant - arrPlaceNames[0], 1 - Bars - arrPlaceNames[1],
        // 2 - Shopping - arrPlaceNames[2], 3 - Coffee Shop - arrPlaceNames[3],
        // 4 - Parks - arrPlaceNames[4], 5 - Hotels - arrPlaceNames[5]
        var content = ""
        switch sender.tag {
        case 0:
            content = "Restaurant"
            break
        case 1:
            content = "Bars"
            break
        case 2:
            content = "Shopping"
            break
        case 3:
            content = "Coffee"
            break
        case 4:
            content = "Parks"
            break
        case 5:
            content = "Hotels"
            break
        default:
            break
        }
        getPlaceInfo(content: content, source: "categories")

        if catDict[content] == nil {
            catDict[content] = 0
        } else {
            catDict[content] = catDict[content]! + 1;
        }
        favCategoryCache.setObject(catDict as AnyObject, forKey: Key.shared.user_id as AnyObject)
//        print(FavCategoryCache.object(forKey: Key.shared.user_id as AnyObject))
    }
}

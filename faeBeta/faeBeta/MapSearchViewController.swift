//
//  MapSearchViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-07-28.
//  Copyright © 2017 fae. All rights reserved.
//
import SwiftyJSON
import MapKit

@objc protocol MapSearchDelegate: class {
    @objc optional func jumpToOnePlace(searchText: String, place: PlacePin)
    @objc optional func jumpToPlaces(searchText: String, places: [PlacePin])
    @objc optional func jumpToLocation(region: MKCoordinateRegion)
    @objc optional func selectPlace(place: PlacePin)
    @objc optional func selectLocation(loc: PlacePin)
}

class MapSearchViewController: UIViewController, FaeSearchBarTestDelegate {
    
    weak var delegate: MapSearchDelegate?
    
    var filteredCategory = [(key: String, value: Int)]()
    var fixedLocOptions: [String] = ["Use my Current Location", "Use Current Map View"]
    var searchedPlaces = [PlacePin]()
    var searchedAddresses = [MKLocalSearchCompletion]()
    var addressCompleter = MKLocalSearchCompleter()
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
    var strSearchedPlace = ""
    var cellStatus = 0
    enum SearchBarType {
        case place, location
    }
    var schBarType = SearchBarType.place
    
    // uiviews with shadow under table views
    var uiviewSchResBg: UIView!
    var uiviewSchLocResBg: UIView!
    
    // table tblSearchRes used for search places & display table "use current location"
    var tblPlacesRes: UITableView!
    
    // table tblLocationRes used for search locations
    var tblLocationRes: UITableView!
    
    var uiviewNoResults: UIView!
    var lblNoResults: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    
    // Geobytes City Data
    var geobytesCityData = [String]()
    
    // Throttle
    var placeThrottler = Throttler(name: "[Place]", seconds: 0.5)
    var locThrottler = Throttler(name: "[Location]", seconds: 0.5)
    
    var boolFromChat: Bool = false
    var boolNoCategory: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor._241241241()
        loadSearchBar()
        loadPlaceBtns()
        loadTable()
        loadNoResultsView()
        loadAddressCompleter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        schPlaceBar.txtSchField.becomeFirstResponder()
    }
    
    private func loadNoResultsView() {
        uiviewNoResults = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: 100))
        uiviewNoResults.backgroundColor = .white
        uiviewNoResults.layer.cornerRadius = 2
        view.addSubview(uiviewNoResults)
        
        lblNoResults = UILabel(frame: CGRect(x: 0, y: 0, width: 211, height: 50))
        uiviewNoResults.addSubview(lblNoResults)
        lblNoResults.center = CGPoint(x: screenWidth / 2 - 8, y: 50)
        lblNoResults.numberOfLines = 0
        lblNoResults.text = "No Results Found...\nTry a Different Search!"
        lblNoResults.textAlignment = .center
        lblNoResults.textColor = UIColor._115115115()
        lblNoResults.font = UIFont(name: "AvenirNext-Medium", size: 15)
        
        activityIndicator = createActivityIndicator(large: true)
        activityIndicator.center = CGPoint(x: screenWidth / 2 - 8, y: 50)
        uiviewNoResults.addSubview(activityIndicator)
        
        addShadow(uiviewNoResults)
    }
    
    private func loadSearchBar() {
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
        if strSearchedPlace != "Search Fae Map" && strSearchedPlace != "Search Place or Address" {
            schPlaceBar.txtSchField.text = strSearchedPlace
            schPlaceBar.btnClose.isHidden = false
        }
        uiviewSearch.addSubview(schPlaceBar)
        
        schLocationBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 48, width: screenWidth - 38, height: 48))
        schLocationBar.delegate = self
        schLocationBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")

        if Key.shared.selectedSearchedCity != nil {
            schLocationBar.txtSchField.attributedText = Key.shared.selectedSearchedCity?.faeSearchBarAttributedText()
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
    
    private func loadPlaceBtns() {
        uiviewPics = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: 214))
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
    
    private func loadTable() {
        // background shadow view of tblPlacesRes
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
        tblPlacesRes.register(PlacesListCell.self, forCellReuseIdentifier: "SearchAddresses")
        tblPlacesRes.register(LocationListCell.self, forCellReuseIdentifier: "MyFixedCell")
        tblPlacesRes.register(CategoryListCell.self, forCellReuseIdentifier: "SearchCategories")
        
        // background shadow view of tblLocationRes
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
    
    @objc private func backToMap(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    func getPlaceInfo(content: String = "", source: String = "name") {
        guard content != "" else {
            showOrHideViews(searchText: content)
            return
        }
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "5")
        FaeSearch.shared.whereKey("radius", value: "10000")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
        FaeSearch.shared.whereKey("location", value: ["latitude": LocManager.shared.searchedLoc.coordinate.latitude,
                                                      "longitude": LocManager.shared.searchedLoc.coordinate.longitude])
        FaeSearch.shared.search { (status: Int, message: Any?) in
            print("places fetching")
            self.activityStatus(isOn: false)
            if status / 100 != 2 || message == nil {
                self.searchedPlaces.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: content)
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                self.searchedPlaces.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: content)
                return
            }
            self.searchedPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
            if source == "name" {
                self.showOrHideViews(searchText: content)
            } else {
                self.delegate?.jumpToPlaces?(searchText: content, places: self.searchedPlaces)
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
            content = "Restaurants"
        case 1:
            content = "Bars"
        case 2:
            content = "Shopping"
        case 3:
            content = "Coffee"
        case 4:
            content = "Parks"
        case 5:
            content = "Hotels"
        default: break
        }
        getPlaceInfo(content: content, source: "categories")

        if catDict[content] == nil {
            catDict[content] = 0
        } else {
            catDict[content] = catDict[content]! + 1;
        }
        favCategoryCache.setObject(catDict as AnyObject, forKey: Key.shared.user_id as AnyObject)
    }
    
    func activityStatus(isOn: Bool) {
        if isOn {
            activityIndicator.startAnimating()
            lblNoResults.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            lblNoResults.isHidden = false
        }
    }
}

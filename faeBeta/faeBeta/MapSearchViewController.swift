//
//  MapSearchViewController.swift
//  faeBeta
//
//  Created by Vicky on 2017-07-28.
//  Copyright © 2017 fae. All rights reserved.
//
import SwiftyJSON
import MapKit
import Alamofire

@objc protocol MapSearchDelegate: class {
    @objc optional func jumpToCategory(category: String)
    @objc optional func jumpToPlaces(searchText: String, places: [PlacePin])
    @objc optional func continueSearching(searchText: String, zoomToFit: Bool)
    @objc optional func selectPlace(place: PlacePin)
    @objc optional func selectLocation(location: CLLocation)
}

class MapSearchViewController: UIViewController, FaeSearchBarTestDelegate {
    
    weak var delegate: MapSearchDelegate?
    
    // Previous View Controller Type
    enum PreviousViewControllerType {
        case chat, map, board
    }
    public var previousVC = PreviousViewControllerType.map
    
    // Public Variables
    public var strSearchedPlace = ""
    public var strSearchedLocation = ""
    
    public var faeMapView: MKMapView!
    var faeRegion: MKCoordinateRegion?
    
    // UI's
    var btnBack: UIButton!
    var uiviewSearch: UIView!
    var schPlaceBar: FaeSearchBarTest!
    var schLocationBar: FaeSearchBarTest!
    var activityIndicatorLocationSearch: UIActivityIndicatorView!
    
    var uiviewPics: UIView!
    var btnCategories = [UIButton]()
    var lblCategories = [UILabel]()
    
    var uiviewSchResBg: UIView!    // uiviews with shadow under table views
    var uiviewSchLocResBg: UIView! // uiviews with shadow under table views
    var tblPlacesRes: UITableView!   // table used for search places & display table fixedLocOptions
    var tblLocationRes: UITableView! // table used for search locations
    
    var uiviewNoResult: UIView!
    var lblNoResult: UILabel!
    var activityIndicatorNoResult: UIActivityIndicatorView!
    
    // Data
    var arrPlaceNames: [String] = []
    enum SearchBarType {
        case place, location
    }
    var schBarType = SearchBarType.place
    var strPreviousFixedOptionSelection: String = "Current Location"
    
    var filteredCategory = [(key: String, value: Int)]()
    var fixedLocOptions: [String] = ["Use my Current Location", "Use Current Map View"]
    var searchedPlaces = [PlacePin]()
    var searchedAddresses = [MKLocalSearchCompletion]() // Apple Place Data
    var addressCompleter = MKLocalSearchCompleter()     // Apple Place Data Getter
    var geobytesCityData = [String]()                   // Geobytes City Data
    var cityToSearch: String = ""
    var changeLocBarText: ((String, Bool) -> ())?
    
    // iOS Geocoder
    let clgeocoder = CLGeocoder()
    
    // Throttle
    var placeThrottler = Throttler(name: "[Place]", seconds: 0.5)
    var locThrottler = Throttler(name: "[Location]", seconds: 0.5)

    // Boolean Flags
    var flagPlaceFetched: Bool = false
    var flagAddrFetched: Bool = false
    var isCategorySearching: Bool = false
    
    // DataRequests Control
    var searchRequest: DataRequest?
    var citySearchRequest: DataRequest?
    var cityDetailRequest: DataRequest?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor._241241241()
        if previousVC == .board {
            fixedLocOptions.removeLast()
        }
        loadSearchBar()
        loadPlaceBtns()
        loadTable()
        loadNoResultsView()
        loadAddressCompleter()
        preloadSearchLocation()
        schPlaceBar.txtSchField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelAllRequests()
    }
    
    // MARK: - Process data about shortcut menu
    func getShortcutMenu() {
        let shortcutCategory = Category.shared.filterShortcutMenu()
        arrPlaceNames = []
        for idx in 0..<min(6, shortcutCategory.count) {
            arrPlaceNames.append(shortcutCategory[idx].name)
        }
        
        setButtonsUI()
    }
    
    // MARK: - Load UI's
    private func preloadSearchLocation() {
        if cityToSearch != "" {
            lookUpForCoordinate(cityData: cityToSearch)
        }
        guard previousVC == .board else { return }
        guard strSearchedLocation != "" else { return }
        joshprint("[preloadSearchLocation]", strSearchedLocation)
        if let attrText = processLocationName(separator: "@", text: strSearchedLocation, size: 18, size2: 16) {
            schLocationBar.txtSchField.attributedText = attrText
        } else {
            fatalError("Processing Location Name Fail, Need To Check Function")
        }
    }
    
    private func loadNoResultsView() {
        uiviewNoResult = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: 100))
        uiviewNoResult.backgroundColor = .white
        uiviewNoResult.layer.cornerRadius = 2
        uiviewNoResult.isHidden = true
        view.addSubview(uiviewNoResult)
        
        lblNoResult = UILabel(frame: CGRect(x: 0, y: 0, width: 211, height: 50))
        uiviewNoResult.addSubview(lblNoResult)
        lblNoResult.center = CGPoint(x: screenWidth / 2 - 8, y: 50)
        lblNoResult.numberOfLines = 0
        lblNoResult.text = "No Results Found...\nTry a Different Search!"
        lblNoResult.textAlignment = .center
        lblNoResult.textColor = UIColor._115115115()
        lblNoResult.font = UIFont(name: "AvenirNext-Medium", size: 15)
        
        activityIndicatorNoResult = createActivityIndicator(large: true)
        activityIndicatorNoResult.center = CGPoint(x: screenWidth / 2 - 8, y: 50)
        uiviewNoResult.addSubview(activityIndicatorNoResult)
        
        addShadow(uiviewNoResult)
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
        schPlaceBar.txtSchField.placeholder = previousVC != .chat ? "Search Fae Map" : "Search Place or Address"
        if strSearchedPlace != "Search Fae Map" && strSearchedPlace != "Search Place or Address" && strSearchedPlace != "All Places" {
            schPlaceBar.txtSchField.text = strSearchedPlace
            schPlaceBar.btnClose.isHidden = false
        }
        uiviewSearch.addSubview(schPlaceBar)
        
        schLocationBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 48, width: screenWidth - 38, height: 48))
        schLocationBar.delegate = self
        schLocationBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")

        schLocationBar.txtSchField.text = "Current Location"
        switch previousVC {
        case .map:
            if let selectedCity = Key.shared.selectedSearchedCity_map {
                schLocationBar.txtSchField.attributedText = selectedCity.faeSearchBarAttributedText()
                cityToSearch = selectedCity
            }
            if Key.shared.searchSource_map.lowercased() == "categories" {
                schPlaceBar.txtSchField.text = ""
            }
        case .board:
            if let selectedCity = Key.shared.selectedSearchedCity_board {
                schLocationBar.txtSchField.attributedText = selectedCity.faeSearchBarAttributedText()
                cityToSearch = selectedCity
            }
            if Key.shared.searchSource_board.lowercased() == "categories" {
                schPlaceBar.txtSchField.text = ""
            }
        case .chat:
            if let selectedCity = Key.shared.selectedSearchedCity_chat {
                schLocationBar.txtSchField.attributedText = selectedCity.faeSearchBarAttributedText()
                cityToSearch = selectedCity
            }
            if Key.shared.searchSource_chat.lowercased() == "categories" {
                schPlaceBar.txtSchField.text = ""
            }
        }
        
        schLocationBar.txtSchField.returnKeyType = .next
        uiviewSearch.addSubview(schLocationBar)
        
        let uiviewDivLine = UIView(frame: CGRect(x: 39, y: 47.5, width: screenWidth - 94, height: 1))
        uiviewDivLine.layer.borderWidth = 1
        uiviewDivLine.layer.borderColor = UIColor._200199204cg()
        uiviewSearch.addSubview(uiviewDivLine)
        
        activityIndicatorLocationSearch = createActivityIndicator(large: false)
        activityIndicatorLocationSearch.center.x = 24
        activityIndicatorLocationSearch.center.y = 72.5
        uiviewSearch.addSubview(activityIndicatorLocationSearch)
    }
    
    private func loadPlaceBtns() {
        uiviewPics = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: 214))
        uiviewPics.backgroundColor = .white
        view.addSubview(uiviewPics)
        uiviewPics.layer.cornerRadius = 2
        addShadow(uiviewPics)
        var origin_x_offset: CGFloat = 0
        if screenWidth == 320 {
            origin_x_offset = 20
        }
        for _ in 0..<6 {
            btnCategories.append(UIButton(frame: CGRect(x: 52 - origin_x_offset, y: 20, width: 58, height: 58)))
            lblCategories.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        
        for i in 0..<6 {
            if i >= 3 {
                btnCategories[i].frame.origin.y = 117
            }
            if i == 1 || i == 4 {
                btnCategories[i].frame.origin.x = (screenWidth - 16 - 58) / 2
            } else if i == 2 || i == 5 {
                btnCategories[i].frame.origin.x = screenWidth - 126 + origin_x_offset
            }
            
            lblCategories[i].center = CGPoint(x: btnCategories[i].center.x, y: btnCategories[i].center.y + 43)
            
            uiviewPics.addSubview(btnCategories[i])
            uiviewPics.addSubview(lblCategories[i])
            
            btnCategories[i].layer.borderColor = UIColor._225225225().cgColor
            btnCategories[i].layer.borderWidth = 2
            btnCategories[i].layer.cornerRadius = 8.0
            btnCategories[i].contentMode = .scaleAspectFit
            btnCategories[i].layer.masksToBounds = true
            btnCategories[i].tag = i
            btnCategories[i].addTarget(self, action: #selector(self.actionSearchByCategories(_:)), for: .touchUpInside)
            
            lblCategories[i].textAlignment = .center
            lblCategories[i].textColor = UIColor._138138138()
            lblCategories[i].font = UIFont(name: "AvenirNext-Medium", size: 13)
        }
        
        getShortcutMenu()
    }
    
    private func setButtonsUI() {
        for i in 0..<6 {
            
            let img_id = i < arrPlaceNames.count ? Category.shared.categories[arrPlaceNames[i]] ?? -1 : -1
            if img_id == -1 {
                btnCategories[i].setImage(nil, for: .normal)
                lblCategories[i].text = ""
            } else {
                btnCategories[i].setImage(UIImage(named: "place_result_\(img_id)"), for: .normal)
                lblCategories[i].text = arrPlaceNames[i]
            }
        }
    }
    
    private func loadTable() {
        // background shadow view of tblPlacesRes
        uiviewSchResBg = UIView(frame: CGRect(x: 8, y: 124 + device_offset_top, width: screenWidth - 16, height: screenHeight - 139 - device_offset_top)) // 124 + 15
        uiviewSchResBg.isHidden = true
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
        uiviewSchLocResBg.isHidden = true
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
    
    private func addShadow(_ uiview: UIView) {
        uiview.layer.shadowColor = UIColor._898989().cgColor
        uiview.layer.shadowRadius = 2.2
        uiview.layer.shadowOffset = CGSize(width: 0, height: 1)
        uiview.layer.shadowOpacity = 0.6
    }
    
    private func cancelAllRequests() {
        searchRequest?.cancel()
        citySearchRequest?.cancel()
        cityDetailRequest?.cancel()
        addressCompleter.cancel()
    }
    
    // MARK: - Actions
    @objc private func backToMap(_ sender: UIButton) {
        cancelAllRequests()
        navigationController?.popViewController(animated: false)
    }
    
    @objc func actionSearchByCategories(_ sender: UIButton) {
        let content = arrPlaceNames[sender.tag]
        if !Key.shared.is_guest {
            Category.shared.visitCategory(category: content)
        }
        
        sendBackLocationText()
        if previousVC == .board {
            delegate?.jumpToCategory?(category: content)
            navigationController?.popViewController(animated: false)
        } else {
            getPlaceInfo(content: content, source: "categories")
        }
    }
    
    func activityStatus(isOn: Bool) {
        if isOn {
            guard !activityIndicatorNoResult.isAnimating else { return }
            activityIndicatorNoResult.startAnimating()
            lblNoResult.isHidden = true
            if uiviewSchResBg.isHidden {
                uiviewNoResult.isHidden = false
            }
            if !uiviewPics.isHidden {
                uiviewPics.isHidden = true
            }
        } else {
            guard activityIndicatorNoResult.isAnimating else { return }
            activityIndicatorNoResult.stopAnimating()
            lblNoResult.isHidden = false
        }
    }
}

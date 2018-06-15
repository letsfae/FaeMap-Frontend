//
//  CitySearcherViewViewModel.swift
//  faeBeta
//
//  Created by Yue Shen on 6/13/18.
//  Copyright © 2018 fae. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
import SwiftyJSON

class CitySearcherViewViewModel {
    
    // MARK: - Properties
    
    var querying: Driver<Bool> { return _querying.asDriver() }
    var locations: Driver<[String]> { return _locations.asDriver() }
    
    private let _querying = BehaviorRelay<Bool>(value: false)
    private let _locations = BehaviorRelay<[String]>(value: [])
    
    var hasLocations: Bool { return numberOfLocations > 0 }
    var numberOfLocations: Int { return _locations.value.count }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializtion
    
    init(query: Driver<String>) {
        query
            .throttle(1)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (addressString) in
                self?.geocode(addressString: addressString)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    
    func location(at index: Int) -> String? {
        guard index < _locations.value.count else { return nil }
        return _locations.value[index]
    }
    
    func viewModelForLocation(at index: Int) -> String? {
        guard let location = location(at: index) else { return nil }
        return location
    }
    
    // MARK: - Helper Methods
    
    private func geocode(addressString: String?) {
        guard let addressString = addressString, !addressString.isEmpty else {
            _locations.accept([])
            return
        }
        
        _querying.accept(true)
        
        // Geocode Address String
        
        CitySearcher.shared.cityAutoComplete(addressString) { [weak self] (status, result) in
            var locations: [String] = []
            self?._querying.accept(false)
            self?._querying.accept(false)
            guard status / 100 == 2 else {
                self?._locations.accept([])
                return
            }
            guard let result = result else {
                self?._locations.accept([])
                return
            }
            let value = JSON(result)
            let citys = value.arrayValue
            for city in citys {
                if city.stringValue == "%s" || city.stringValue == "" {
                    break
                }
                locations.append(city.stringValue)
                
            }
            self?._locations.accept(locations)
        }
    }
    
}

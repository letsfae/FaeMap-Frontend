//
//  Pls&LocSearchViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class Pls_LocSearchViewController: CollectionSearchViewController, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        tblSearchResults.backgroundColor = .white
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceAndLocationCell", for: indexPath) as! PlaceAndLocationTableViewCell
        cell.setValueForCell(_: filteredArray[indexPath.section])
        // Hide the separator line
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 89.5, bottom: 0, right: 0)
        return cell
    }

}

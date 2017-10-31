//
//  PlaceDetailTableView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-15.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension PlaceDetailViewController: UITableViewDataSource, UITableViewDelegate, PlaceDetailMapCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return intCellCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if intHaveHour == 0 && intHaveWebPhone == 0 {
            if section == 0 {
                return 1
            } else {
                return 2
            }
        } else if intHaveHour == 0 && intHaveWebPhone == 1 {
            if section == 0 {
                return 1
            } else if section == 1 {
                if place.phone == "" { return 1 }
                if place.url == "" { return 1 }
                return 2
            } else {
                return 2
            }
        } else if intHaveHour == 1 && intHaveWebPhone == 0  {
            if section < 2 {
                return 1
            } else {
                return 2  // fixed
            }
        } else {
            if section < 2 {
                return 1
            } else if section == 2 {
                if place.phone == "" { return 1 }
                if place.url == "" { return 1 }
                return 2
            } else {
                return 2  // fixed
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tblPlaceDetail.rowHeight = UITableViewAutomaticDimension
        tblPlaceDetail.estimatedRowHeight = 60
        let section = indexPath.section
        if intHaveHour == 0 && intHaveWebPhone == 0 {
            if section == 0 {
                return tblPlaceDetail.rowHeight
            } else {
                return 222
            }
        } else if intHaveHour == 0 && intHaveWebPhone == 1 {
            if section == 0 {
                return tblPlaceDetail.rowHeight
            } else if section == 1 {
                return tblPlaceDetail.rowHeight
            } else {
                return 222
            }
        } else if intHaveHour == 1 && intHaveWebPhone == 0  {
            if section < 2 {
                return tblPlaceDetail.rowHeight
            } else {
                return 222
            }
        } else {
            if section < 2 {
                return tblPlaceDetail.rowHeight
            } else if section == 2 {
                return tblPlaceDetail.rowHeight
            } else {
                return 222
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if intHaveHour == 0 && intHaveWebPhone == 0 {
            if section == 0 {
                return getMapCell(tableView, indexPath)
            } else {
                return getMBCell(tableView, indexPath)
            }
        } else if intHaveHour == 0 && intHaveWebPhone == 1 {
            if section == 0 {
                return getMapCell(tableView, indexPath)
            } else if section == 1 {
                if place.phone == "" && row == 1 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else if place.url == "" && row == 1 {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                } else if indexPath.row == 1 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                }
            } else {
                return getMBCell(tableView, indexPath)
            }
        } else if intHaveHour == 1 && intHaveWebPhone == 0  {
            if section < 2 {
                if section == 1 {
                    return getMapCell(tableView, indexPath)
                }
                return getHoursCell(tableView, indexPath)
            } else {
                return getMBCell(tableView, indexPath)
            }
        } else {
            if section < 2 {
                if section == 1 {
                    return getMapCell(tableView, indexPath)
                }
                return getHoursCell(tableView, indexPath)
            } else if section == 2 {
                if place.phone == "" && row == 1 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else if place.url == "" && row == 1 {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                } else if indexPath.row == 1 {
                    return getWebPhoneCell(tableView, indexPath, isURL: true)
                } else {
                    return getWebPhoneCell(tableView, indexPath, isURL: false)
                }
            } else {
                return getMBCell(tableView, indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 || section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! PlaceDetailCell
            PlaceDetailCell.boolFold = cell.imgDownArrow.image == #imageLiteral(resourceName: "arrow_up")
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        } else if section == 2 {   // open place website / call place phone number
            let phoneNum = place.phone.onlyNumbers()
            let strURL = indexPath.row == 0 ? place.url : "tel://\(phoneNum)"
            if let url = URL(string: strURL), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func getMBCell(_ tableView: UITableView, _ indexPath: IndexPath) -> MBPlacesCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MBPlacesCell", for: indexPath) as! MBPlacesCell
        if arrRelatedPlaces.count != 0 {
            cell.delegate = self
            let places = arrRelatedPlaces[indexPath.row]
            cell.setValueForCell(title: arrTitle[indexPath.row], places: places)
        }
        return cell
    }
    
    func getMapCell(_ tableView: UITableView, _ indexPath: IndexPath) -> PlaceDetailMapCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailMapCell", for: indexPath) as! PlaceDetailMapCell
        cell.delegate = self
        cell.setValueForCell(place: place)
        return cell
    }
    
    func getHoursCell(_ tableView: UITableView, _ indexPath: IndexPath) -> PlaceDetailHoursCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailHoursCell", for: indexPath) as! PlaceDetailHoursCell
        cell.setValueForCell(place: place)
        return cell
    }
    
    func getWebPhoneCell(_ tableView: UITableView, _ indexPath: IndexPath, isURL: Bool) -> PlaceDetailSection3Cell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailSection3Cell", for: indexPath) as! PlaceDetailSection3Cell
        cell.isURL = isURL
        cell.setValueForCell(place: place)
        return cell
    }
    
    func jumpToMainMapWithPlace() {
        delegate?.jumpToOnePlace?(searchText: "fromPlaceDetail", place: self.place)
        navigationController?.popViewController(animated: false)
    }
}

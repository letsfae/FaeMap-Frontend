//
//  MapBoardTableView.swift
//  FaeMapBoard
//
//  Created by vicky on 4/14/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

extension MapBoardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableMapBoard.rowHeight = UITableViewAutomaticDimension
        tableMapBoard.estimatedRowHeight = 200
        
        if tableMode == .social {
            tableMapBoard.estimatedRowHeight = 78
            return 78
        } else if tableMode == .people || tableMode == .places {
            tableMapBoard.estimatedRowHeight = 90
            return 90
        } else if tableMode == .talk {
            if talkTableMode == .topic {
                tableMapBoard.estimatedRowHeight = 66
                return 66
            }
        }
        return tableMapBoard.rowHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableMode {
        case .social:
            return 3
        case .people:
            return lblUsrNameTxt.count
        case .places:
            return mbPlaces.count
        case .talk:
            switch talkTableMode {
            case .feed:
                return valUsrName.count
            case .topic:
                return topic.count
            case .post:
                if talkPostTableMode == .talk {
                    return myTalk_avatarArr.count
                } else if talkPostTableMode == .comment {
                    return comment_avatarArr.count
                }
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableMode == .social {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mbSocialCell", for: indexPath) as! MBSocialCell
            cell.imgIcon.image = imgIconArr[indexPath.row]
            cell.lblTitle.text = lblTitleTxt[indexPath.row]
            cell.lblContent.text = lblContTxt[indexPath.row]
            return cell
        } else if tableMode == .people {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mbPeopleCell", for: indexPath) as! MBPeopleCell
            cell.imgAvatar.image = imgAvatarArr[indexPath.row]
            cell.lblUsrName.text = lblUsrNameTxt[indexPath.row]
            cell.lblIntro.text = lblIntroTxt[indexPath.row]
            if age[indexPath.row] == "" {
                cell.imgGenderWithAge.isHidden = true
                if gender[indexPath.row] == "F" {
                    cell.imgGender.image = #imageLiteral(resourceName: "mb_female")
                } else {
                    cell.imgGender.image = #imageLiteral(resourceName: "mb_male")
                }
            } else {
                cell.imgGender.isHidden = true
                if gender[indexPath.row] == "F" {
                    cell.imgGenderWithAge.image = #imageLiteral(resourceName: "mb_femaleWithAge")
                } else {
                    cell.imgGenderWithAge.image = #imageLiteral(resourceName: "mb_maleWithAge")
                }
                cell.lblAge.text = age[indexPath.row]
            }
            
            cell.lblDistance.text = peopleDis[indexPath.row]
            return cell
        } else if tableMode == .places {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mbPlacesCell", for: indexPath) as! MBPlacesCell
            let place = mbPlaces[indexPath.row]
            cell.imgPlaceIcon.image = #imageLiteral(resourceName: "mb_defaultPlace")
            cell.lblPlaceName.text = place.name
            cell.lblPlaceAddr.text = place.address
            cell.lblDistance.text = place.distance

//            cell.lblPlaceName.text = placeName[indexPath.row]
//            cell.lblPlaceAddr.text = placeAddr[indexPath.row]
//            cell.lblDistance.text = distance[indexPath.row]
            return cell
        } else if tableMode == .talk {
            if talkTableMode == .feed {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mbTalkFeedCell", for: indexPath) as! MBTalkFeedCell
                cell.imgAvatar.image = avatarArr[indexPath.row]
                cell.lblUsrName.text = valUsrName[indexPath.row]
                cell.lblTime.text = valTalkTime[indexPath.row]
                cell.lblReplyCount.text = String(valReplyCount[indexPath.row])
                cell.lblContent.text = valContent[indexPath.row]
                cell.lblVoteCount.text = String(valVoteCount[indexPath.row])
                return cell
            } else if talkTableMode == .topic {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mbTalkTopicCell", for: indexPath) as! MBTalkTopicCell
                cell.lblTopics.text = "//\(topic[indexPath.row])"
                cell.lblPostsCount.text = "\(postsCount[indexPath.row])k posts"
                return cell
            } else if talkTableMode == .post {
                if talkPostTableMode == .talk {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "mbTalkMytalksCell", for: indexPath) as! MBTalkMytalksCell
                    cell.imgAvatar.image = myTalk_avatarArr[indexPath.row]
                    cell.lblUsrName.text = myTalk_valUsrName[indexPath.row]
                    cell.lblTime.text = myTalk_valTalkTime[indexPath.row]
                    cell.lblReplyCount.text = String(myTalk_valReplyCount[indexPath.row])
                    cell.lblContent.text = myTalk_valContent[indexPath.row]
                    cell.lblVoteCount.text = String(myTalk_valVoteCount[indexPath.row])
                    return cell
                } else if talkPostTableMode == .comment {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "mbTalkCommentsCell", for: indexPath) as! MBTalkCommentsCell
                    cell.imgAvatar.image = comment_avatarArr[indexPath.row]
                    cell.lblUsrName.text = comment_valUsrName[indexPath.row]
                    cell.lblTime.text = comment_valTalkTime[indexPath.row]
                    cell.lblContent.text = comment_valContent[indexPath.row]
                    cell.lblVoteCount.text = String(comment_valVoteCount[indexPath.row])
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableMapBoard.backgroundColor = .clear
        
        if tableMode == .social {
            if (indexPath.row == 0) {  // comments
                let mbCommentsVC = MBCommentsViewController()
                mbCommentsVC.mbComments = self.mbComments
                self.navigationController?.pushViewController(mbCommentsVC, animated: true)
//                self.present(mbCommentsVC, animated: false, completion: nil)
            } else if (indexPath.row == 1) {  // chats
                let mbChatsVC = MBChatsViewController()
//                self.present(mbChatsVC, animated: false, completion: nil)
                self.navigationController?.pushViewController(mbChatsVC, animated: true)
            } else {  // stories
                let mbStoriesVC = MBStoriesViewController()
                mbStoriesVC.mbStories = self.mbStories
//                self.present(mbStoriesVC, animated: false, completion: nil)
                self.navigationController?.pushViewController(mbStoriesVC, animated: true)
            }
            
//            self.renewSelfLocation()
            
        } else if tableMode == .people {
            
        } else if tableMode == .places {
            
        } else if tableMode == .talk {
        }
    }
}

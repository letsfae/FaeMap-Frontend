//
//  CategoryTree.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-07-03.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation
import RealmSwift

class Node {
    var value: String
    var children: [Node] = []
    weak var parent: Node?
    
    init(_ value: String) {
        self.value = value
    }
    
    func add(child: Node) {
        children.append(child)
        child.parent = self
    }
}

extension Node: Hashable {
    var hashValue: Int {
        return value.hashValue
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        var text = value
        
        if !children.isEmpty {
            text += " {" + children.map { $0.description }.joined(separator: ", ") + "} "
        }
        return text
    }
}

class Category {
    static let shared = Category()
    let realm  = try! Realm()
    var root: Node = Node("0")
    var masterlvl_set: Set<Node> = [], level1_set: Set<Node> = [], level2_set: Set<Node> = [], level3_set: Set<Node> = [], level4_set: Set<Node> = [], level5_set: Set<Node> = []
    let base: Double = 1.0, factor: Double = 0.5
    var level1 = "", level2 = "", level3 = "", level4 = "", level5 = "", level6 = ""
    let shortcutMenu = ["Restaurant", "Bar", "Pizza Place", "Coffee Shop", "Park", "Hotel", "Fast Food Restaurant", "Beer Bar", "Cosmetics Shop", "Gym / Fitness Center", "Grocery Store", "Pharmacy"]
    var master_to_class1 = [String: Set<String>]()
    var class12 = [String: Set<String>]()
    var class23 = [String: Set<String>]()
    var class34 = [String: Set<String>]()
    var class45 = [String: Set<String>]()
    var class55 = Set<String>()
    var category_to_icon = [String : String]()
    
    init() {
        parseCategoriesCSV()
        
        let myDict = realm.filterMyCatDict()
        if myDict.isEmpty {
            writeDefault()
        }
        
        buildTree()
        
//        testData()
    }
    
    private func testData() {
//        vickyprint("category count \(category_to_icon.count)")   // 915
//        vickyprint("master \(master_to_class1.count) \(master_to_class1)")   // 7
//        vickyprint("class12 \(class12.count) \(class12)")   // 407- 390
//        vickyprint("class23 \(class23.count) \(class23)")   // 390
//        vickyprint("class34 \(class34.count) \(class34)")   // 105
//        vickyprint("class45 \(class45.count) \(class45)")   // 13
//        vickyprint("class55 \(class55.count) \(class55)")   // 0
        
        vickyprint("masterlvlSet \(masterlvl_set.count)  level1_tree \(level1_set.count) level2_tree \(level2_set.count) level3_tree \(level3_set.count) level4_tree \(level4_set.count) level5_tree \(level5_set.count)")
        // print tree
        // vickyprint(root.description)
    }
    
    private func parseCategoriesCSV() {
        func cleanRows(file: String)->String{
            var cleanFile = file
            cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
            cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
            return cleanFile
        }
        
        guard let filepath = Bundle.main.path(forResource: "Categories", ofType: "csv") else {
            print("Categories.csv File does not exist")
            return
        }
        
        do {
            var data = try String(contentsOfFile: filepath, encoding: String.Encoding.utf8)
            data = cleanRows(file: data)
            let rows = data.components(separatedBy: "\n")
            
            for rowIdx in 0..<rows.count {
                if rowIdx == 0 {
                    continue
                }
                let cols = rows[rowIdx].components(separatedBy: ",")
                if cols.count != 11 {
//                    print("Format Error: rowIdx \(rowIdx) cols \(cols)")
                    continue
                }
                
                let master = cols[0].trimmingCharacters(in: .whitespaces)
                let class_1 = cols[1].trimmingCharacters(in: .whitespaces)
                let class_2 = cols[3].trimmingCharacters(in: .whitespaces)
                let class_3 = cols[5].trimmingCharacters(in: .whitespaces)
                let class_4 = cols[7].trimmingCharacters(in: .whitespaces)
                let class_5 = cols[9].trimmingCharacters(in: .whitespaces)
                
                let icon_1 = cols[2].trimmingCharacters(in: .whitespaces)
                let icon_2 = cols[4].trimmingCharacters(in: .whitespaces)
                let icon_3 = cols[6].trimmingCharacters(in: .whitespaces)
                let icon_4 = cols[8].trimmingCharacters(in: .whitespaces)
                let icon_5 = cols[10].trimmingCharacters(in: .whitespaces)
                
                // construct category_to_iconId dictionary
                if class_1 != "" && category_to_icon[class_1] == nil {
                    category_to_icon[class_1] = icon_1
                }
                if class_2 != "" && category_to_icon[class_2] == nil {
                    category_to_icon[class_2] = icon_2
                }
                if class_3 != "" && category_to_icon[class_3] == nil {
                    category_to_icon[class_3] = icon_3
                }
                if class_4 != "" && category_to_icon[class_4] == nil {
                    category_to_icon[class_4] = icon_4
                }
                if class_5 != "" && category_to_icon[class_5] == nil {
                    category_to_icon[class_5] = icon_5
                }
                
                // construct class-reltionship dictionary
                if master == "" {
                    continue
                }
                
                if master_to_class1[master] == nil {
                    master_to_class1[master] = Set<String>()
                }
                if class_1 == "" {
                    continue
                }
                
                master_to_class1[master]!.insert(class_1)
                
                if class12[class_1] == nil {
                    class12[class_1] = Set<String>()
                }
                if class_2 == "" {
                    continue
                }
                
                class12[class_1]!.insert(class_2)
                
                
                if class23[class_2] == nil {
                    class23[class_2] = Set<String>()
                }
                if class_3 == "" {
                    continue
                }
                
                class23[class_2]!.insert(class_3)
                
                if class34[class_3] == nil {
                    class34[class_3] = Set<String>()
                }
                
                if class_4 == "" {
                    continue
                }
                class34[class_3]!.insert(class_4)
                
                if class45[class_4] == nil {
                    class45[class_4] = Set<String>()
                }
                
                if class_5 == "" {
                    continue
                }
                class45[class_4]!.insert(class_5)
                
                class55.insert(class_4)
                
            }
        } catch let err as NSError {
            print("File Read Error for file \(filepath). Error: \(err)")
            return
        }
    }
    
    private func writeDefault() {
        for i in 0..<shortcutMenu.count {
            writeInRealmCategory(category: shortcutMenu[i], weight: (Double)(12 - i) * 0.001)
        }
    }
    
    private func writeInRealmCategory(category: String, weight: Double) {
        let catDict = realm.filterCategory(primary_key: "\(Key.shared.user_id)_\(category)")
        
        try! realm.write{
            if catDict == nil {
                let dict = RealmCategory(value: ["\(Key.shared.user_id)_\(category)", Key.shared.user_id, category, weight])
                realm.add(dict, update: true)
            } else {
                catDict?.weight += weight
            }
        }
    }
    
    private func write() {
        vickyprint("level1 \(level1) level2 \(level2) level3 \(level3) level4 \(level4) level5 \(level5) level6 \(level6)")
        
        if level1 != "" {
            writeInRealmCategory(category: level1, weight: base)
        }
        if level2 != "" {
            writeInRealmCategory(category: level2, weight: base * factor)
        }
        if level3 != "" {
            writeInRealmCategory(category: level3, weight: base * factor * factor)
        }
        if level4 != "" {
            writeInRealmCategory(category: level4, weight: base * factor * factor * factor)
        }
        if level5 != "" {
            writeInRealmCategory(category: level4, weight: base * factor * factor * factor * factor * factor)
        }
        if level6 != "" {
            writeInRealmCategory(category: level4, weight: base * factor * factor * factor * factor * factor * factor)
        }
        
//        let realm = try! Realm()
//        let realmCategory = realm.filterMyCatDict()
//        vickyprint(realmCategory)
    }
    
    private func buildTree() {
        for (master, class1_set) in master_to_class1 {
            let master_node = Node(master)
            masterlvl_set.insert(master_node)
            root.add(child: master_node)
            
            for class1 in class1_set {
                if class1 == "" {
                    continue
                }
                let class1_node = Node(class1)
                level1_set.insert(class1_node)
                master_node.add(child: class1_node)
                
                for class2 in class12[class1]! {
                    if class2 == "" {
                        continue
                    }
                    let class2_node = Node(class2)
                    level2_set.insert(class2_node)
                    class1_node.add(child: class2_node)

                    for class3 in class23[class2]! {
                        if class3 == "" {
                            continue
                        }
                        let class3_node = Node(class3)
                        level3_set.insert(class3_node)
                        class2_node.add(child: class3_node)
                        
                        for class4 in class34[class3]! {
                            if class4 == "" {
                                continue
                            }
                            let class4_node = Node(class4)
                            level4_set.insert(class4_node)
                            class3_node.add(child: class4_node)
                            
                            for class5 in class45[class4]! {
                                if class5 == "" {
                                    continue
                                }
                                let class5_node = Node(class5)
                                level5_set.insert(class5_node)
                                class4_node.add(child: class5_node)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func searchNode(_ level: Set<Node>, _ value: String) -> Node? {
        for node in level {
            if node.value == value {
                return node
            }
        }
        
        return nil
    }
    
     func updateCategoryDictionary(place: PlacePin) {
        level1 = ""
        level2 = ""
        level3 = ""
        level4 = ""
        level5 = ""
        level6 = ""
        
        switch place.category {
        case place.class_5:
            level1 = place.class_5
            level2 = place.class_4
            level3 = place.class_3
            level4 = place.class_2
            level5 = place.class_1
            level6 = place.master_class
            break
        case place.class_4:
            level1 = place.class_4
            level2 = place.class_3
            level3 = place.class_2
            level4 = place.class_1
            level5 = place.master_class
            break
        case place.class_3:
            level1 = place.class_3
            level2 = place.class_2
            level3 = place.class_1
            level4 = place.master_class
            break
        case place.class_2:
            level1 = place.class_2
            level2 = place.class_1
            level3 = place.master_class
            break
        case place.class_1:
            level1 = place.class_1
            level2 = place.master_class
        case place.master_class:
            level1 = place.master_class
            break
        default:
            break
        }
        
        write()
    }
    
    func visitCategory(category: String) {
        level1 = ""
        level2 = ""
        level3 = ""
        level4 = ""
        level5 = ""
        level6 = ""
        let level1_node: Node?
        
        if class55.contains(category) {
            // category belongs to class5
            guard let node = searchNode(level5_set, category) else { return }
            level1_node = node
        } else if class45[category] != nil {
            // category belongs to class4
            guard let node = searchNode(level4_set, category) else { return }
            level1_node = node
        } else if class34[category] != nil {
            // category belongs to class3
            guard let node = searchNode(level3_set, category) else { return }
            level1_node = node
        } else if class23[category] != nil {
            // category belongs to class2
            guard let node = searchNode(level2_set, category) else { return }
            level1_node = node
        } else if class12[category] != nil {
            // category belongs to class1
            guard let node = searchNode(level1_set, category) else { return }
            level1_node = node
        } else if master_to_class1[category] != nil {
            // category belongs to master class
            guard let node = searchNode(masterlvl_set, category) else { return }
            level1_node = node
        } else {
            return
        }
        
        guard let lvl1_node = level1_node else { return }
        level1 = lvl1_node.value
        
        guard let level2_node = lvl1_node.parent else { return }
        guard level2_node.value != "0" else {
            write()
            return
        }
        level2 = level2_node.value
        
        guard let level3_node = level2_node.parent else { return }
        guard level3_node.value != "0" else {
            write()
            return
        }
        level3 = level3_node.value
        
        guard let level4_node = level3_node.parent else { return }
        guard level4_node.value != "0" else {
            write()
            return
        }
        level4 = level4_node.value
        
        guard let level5_node = level4_node.parent else { return }
        guard level5_node.value != "0" else {
            write()
            return
        }
        level5 = level5_node.value
        
        guard let level6_node = level5_node.parent else { return }
        guard level6_node.value != "0" else {
            write()
            return
        }
        level6 = level6_node.value
        
        write()
    }
    
    func filterShortcutMenu() -> Results<RealmCategory> {
        return realm.filterMyCatDict().filter("name IN %@", shortcutMenu).sorted(byKeyPath: "weight", ascending: false)
    }
}

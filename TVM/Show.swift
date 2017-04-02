//
//  Show.swift
//  TVM
//
//  Created by Vasil Nunev on 01/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//
import UIKit
import SwiftyJSON

class Show: NSObject {
    
    var name: String = ""
    var days: [String] = []
    var imageURL: String = ""
    var status: String = ""
    var nextEpURL: String?

    init?(data json: JSON){
        if let show = json["show"].dictionary, let schedule = show["schedule"]?.dictionaryValue, let image = show["image"]?.dictionaryValue {
            self.name = show["name"]!.stringValue
            self.days = schedule["days"]!.arrayObject as! [String]
            self.imageURL = image["medium"]?.stringValue ?? ""
            self.status = show["status"]!.stringValue
            if let links = show["_links"]?.dictionary, let next = links["nextepisode"]?.dictionaryValue {
                self.nextEpURL = next["href"]?.stringValue
            }
        }
    }
}

//
//  Show.swift
//  TVM
//
//  Created by Vasil Nunev on 01/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//
import UIKit
import SwiftyJSON
import Alamofire

enum Status: String {
    case Running    = "running"
    case Finished   = "ended"
    case TBD        = "to be determined"
    case InDev      = "in development"
    case Unknown    = ""
}

class Show: NSObject {
    
    var name: String = ""
    var days: [String] = []
    var imageURL: String = ""
    var status: Status = Status(rawValue: "")!
    var nextEpURL: String?
    var nextEpDate: String?
    var dateForNotification: String?
    var summary: String = ""
    var rating: String = ""
    var genres: [String] = []
    var showID: String = ""
    var runtime: String = ""
    var link: String = ""

    init?(data json: JSON){
        if let show = json["show"].dictionary, let schedule = show["schedule"]?.dictionaryValue, let image = show["image"]?.dictionaryValue {
            self.name = show["name"]!.stringValue
            self.days = schedule["days"]!.arrayObject as! [String]
            self.imageURL = image["medium"]?.stringValue ?? ""
            self.status = Status(rawValue: show["status"]!.stringValue.lowercased())!
            if let links = show["_links"]?.dictionary, let next = links["nextepisode"]?.dictionaryValue {
                self.nextEpURL = next["href"]?.stringValue
            }
            self.summary = show["summary"]!.stringValue
            self.runtime = show["runtime"]!.stringValue
            self.showID  = show["id"]!.stringValue
            if let rating = show["rating"]?.dictionary, let average = rating["average"]?.double{
                self.rating = String(average)
            }
            self.link = show["url"]!.stringValue
            self.genres = show["genres"]?.arrayObject as! [String]
        }
    }
    
    init?(dictionary json: [String : JSON]){
        if let schedule = json["schedule"]?.dictionaryValue, let image = json["image"]?.dictionaryValue {
            self.name = json["name"]!.stringValue
            self.days = schedule["days"]!.arrayObject as! [String]
            self.imageURL = image["medium"]?.stringValue ?? ""
            self.status = Status(rawValue: json["status"]!.stringValue.lowercased())!
            if let links = json["_links"]?.dictionary, let next = links["nextepisode"]?.dictionaryValue {
                self.nextEpURL = next["href"]?.stringValue
            }
            self.summary = json["summary"]!.stringValue
            self.runtime = json["runtime"]!.stringValue
            self.showID  = json["id"]!.stringValue
            if let rating = json["rating"]?.dictionary, let average = rating["average"]?.double{
                self.rating = String(average)
            }
            self.genres = json["genres"]?.arrayObject as! [String]
        }

    }
}

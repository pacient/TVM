//
//  ShowDetailsViewController.swift
//  TVM
//
//  Created by Vasil Nunev on 01/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ShowDetailsViewController: UIViewController {

    @IBOutlet weak var showImageView: UIImageView!
    @IBOutlet weak var showName: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var showDays: UILabel!
    @IBOutlet weak var nextEpName: UILabel!
    @IBOutlet weak var nextEpDate: UILabel!
    @IBOutlet weak var nextEpSummary: UITextView!
    @IBOutlet weak var summaryHeightConstraint: NSLayoutConstraint!
    
    var show = Show()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateView()
    }
    
    override func viewDidLayoutSubviews() {
        let size = self.nextEpSummary.sizeThatFits(CGSize(width: self.nextEpSummary.frame.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != summaryHeightConstraint.constant {
            self.summaryHeightConstraint.constant = size.height
            self.view.layoutIfNeeded()
        }
    }
    
    func populateView() {
        showName.text = show.name
        statusView.backgroundColor = show.status == "Running" ? #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) : #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        showDays.text = show.days.joined(separator: ", ")
        showImageView.downloadImage(from: show.imageURL)
        
        if let url = show.nextEpURL {
            Alamofire.request(url).responseData(completionHandler: { (response) in
                if let json = response.result.value, let data = JSON(json).dictionary {
                    self.nextEpName.text = data["name"]!.stringValue
                    self.nextEpDate.text = "\(data["airdate"]!.stringValue) \(data["airtime"]!.stringValue)"
                    self.nextEpSummary.text = data["summary"]?.stringValue.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "")//lazy way to remove <p> tags
                }
            })
        }else {
            self.nextEpSummary.text = ""
            self.nextEpDate.text = ""
            self.nextEpName.text = "No info available"
        }
    }

    @IBAction func xPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}

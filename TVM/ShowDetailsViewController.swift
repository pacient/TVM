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
    @IBOutlet weak var showSummary: UITextView!
    @IBOutlet weak var summaryHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: SpringView!
    
    var show: Show!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateView(with: "zoomIn")
        containerView.animate()
    }
    
    override func viewDidLayoutSubviews() {
        let size = self.showSummary.sizeThatFits(CGSize(width: self.showSummary.frame.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != summaryHeightConstraint.constant {
            self.summaryHeightConstraint.constant = size.height
            self.view.layoutIfNeeded()
        }
    }
    
    func animateView(with animation: String) {
        containerView.animation = animation
        containerView.curve = "easeIn"
        containerView.duration = 0.7
    }
    
    func populateView() {
        showName.text = show.name
        statusView.backgroundColor = show.status == "Running" ? #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) : #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        showDays.text = show.days.joined(separator: ", ")
        showSummary.text = show.summary.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "")//lazy way to remove <p> tags
        showImageView.downloadImage(from: show.imageURL)
        
        if let url = show.nextEpURL {
            Alamofire.request(url).responseData(completionHandler: { (response) in
                if let json = response.result.value, let data = JSON(json).dictionary {
                    self.nextEpName.text = data["name"]!.stringValue
                    self.nextEpDate.text = "\(data["airdate"]!.stringValue) \(data["airtime"]!.stringValue)"
                }
            })
        }else {
            self.nextEpDate.text = ""
            self.nextEpName.text = "No info available"
        }
    }

    @IBAction func xPressed(_ sender: Any) {
        animateView(with: "zoomOut")
        containerView.animateNext {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

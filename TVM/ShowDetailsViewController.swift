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
    @IBOutlet weak var showRating: UILabel!
    @IBOutlet weak var showGenres: UILabel!
    @IBOutlet weak var showRuntime: UILabel!

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
    
    
    func animateView(with animation: String) {
        containerView.animation = animation
        containerView.curve = "easeIn"
        containerView.duration = 0.5
    }
    
    func populateView() {
        showName.text = show.name
        switch show.status {
        case .Finished: statusView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        case .Running:  statusView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        case .TBD:      statusView.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        case .Unknown,.InDev:  statusView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        showDays.text = show.days.joined(separator: ", ")
        showImageView.downloadImage(from: show.imageURL)
        showRating.text = show.rating
        showGenres.text = show.genres.joined(separator: ", ")
        showRuntime.text = "\(show.runtime) mins"
        
        if let url = show.nextEpURL {
            Alamofire.request(url).responseData(completionHandler: { (response) in
                if let json = response.result.value, let data = JSON(json).dictionary {
                    self.nextEpName.text = data["name"]!.stringValue
                    let arr = data["airdate"]!.string!.components(separatedBy: "-")
                    let dateStr = "\(arr[2])/\(arr[1])/\(arr[0])"
                    self.nextEpDate.text = "\(dateStr) \(data["airtime"]!.stringValue)"
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

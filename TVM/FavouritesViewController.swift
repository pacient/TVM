//
//  FavouritesViewController.swift
//  TVM
//
//  Created by Vasil Nunev on 02/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    var storedShows = [Show]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        retrieveFavourites()
    }
    
    func retrieveFavourites() {
        let shows = UserDefaults.standard.array(forKey: "storedShows") as? [String] ?? []
        if shows.count > 0 {
            for each in shows {
                storedShows.removeAll()
                Alamofire.request("http://api.tvmaze.com/shows/\(each)").responseJSON(completionHandler: { (response) in
                    if let json = response.result.value {
                        let data = JSON(json).dictionary
                        let showObject = Show(dictionary: data!)
                        if let nextURL = showObject?.nextEpURL {
                            Alamofire.request(nextURL).responseJSON(completionHandler: { (res) in
                                if let json = res.result.value, let data = JSON(json).dictionary {
                                    let arr = data["airdate"]!.string!.components(separatedBy: "-")
                                    let dateStr = "\(arr[2])/\(arr[1])/\(arr[0])"
                                    showObject?.nextEpDate = "\(dateStr) \(data["airtime"]!.stringValue)"
                                    self.tableview.reloadData()
                                }
                            })
                        }else {
                            showObject?.nextEpDate = "No info available"
                        }
                        self.storedShows.append(showObject!)
                        self.storedShows.sort {$0.name < $1.name}
                    }
                    self.tableview.reloadData()
                })
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowCell
        cell.showName.text = storedShows[indexPath.row].name
        cell.showDays.text = storedShows[indexPath.row].days.joined(separator: ", ")
        cell.nextEpDate.text = storedShows[indexPath.row].nextEpDate
        switch storedShows[indexPath.row].status {
        case .Finished: cell.statusView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        case .Running:  cell.statusView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        case .TBD:      cell.statusView.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        case .Unknown,.InDev:  cell.statusView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        cell.showImage.downloadImage(from: storedShows[indexPath.row].imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

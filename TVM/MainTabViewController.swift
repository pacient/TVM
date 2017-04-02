//
//  MainTabViewController.swift
//  TVM
//
//  Created by Vasil Nunev on 01/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    var shows = [Show]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
    }

    
    //MARK: Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowCell
        cell.showName.text = shows[indexPath.row].name
        cell.showDays.text = shows[indexPath.row].days.joined(separator: ", ")
        cell.nextEpDate.text = shows[indexPath.row].nextEpDate
        switch shows[indexPath.row].status {
        case .Finished: cell.statusView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        case .Running:  cell.statusView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        case .TBD:      cell.statusView.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        case .Unknown:  cell.statusView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        cell.showImage.downloadImage(from: shows[indexPath.row].imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showDetails") as! ShowDetailsViewController
        vc.show = shows[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.present(vc, animated: false, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchbar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: "Save") { (action, indexPath) in
            print("save this")
        }
        return [action]
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text != "" else {return}
        shows.removeAll()
        self.searchbar.endEditing(true)
        let query = searchBar.text!.replacingOccurrences(of: " ", with: "%20")
        Alamofire.request(URL(string: "http://api.tvmaze.com/search/shows?q=\(query)")!).responseJSON { (response) in
            if let json = response.result.value {
                let data = JSON(json).arrayValue
                for each in data {
                    let showObject = Show(data: each)
                    if let nextURL = showObject?.nextEpURL {
                        Alamofire.request(nextURL).responseJSON(completionHandler: { (res) in
                            if let json = res.result.value, let data = JSON(json).dictionary {
                                let arr = data["airdate"]!.string!.components(separatedBy: "-")
                                let dateStr = "\(arr[2])/\(arr[1])/\(arr[0])"
                                showObject?.nextEpDate = "\(dateStr) \(data["airtime"]!.stringValue)"
                                self.tableView.reloadData()
                            }
                        })
                    }else {
                        showObject?.nextEpDate = "No info available"
                    }
                    self.shows.append(showObject!)
                }
                self.tableView.reloadData()
            }
        }
    }
    
}

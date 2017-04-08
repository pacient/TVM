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
import UserNotifications

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    var storedShows = [Show]()
    var shows        = [Show]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(retrieveFavourites), for: .valueChanged)
        self.tableview.refreshControl = refreshControl
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
                                    showObject?.dateForNotification = data["airdate"]!.string
                                    let arr = data["airdate"]!.string!.components(separatedBy: "-")
                                    let dateStr = "\(arr[2])/\(arr[1])/\(arr[0])"
                                    showObject?.nextEpDate = "\(dateStr) \(data["airtime"]!.stringValue)"
                                    self.scheduleNotification(for: showObject!)
                                    self.tableview.reloadData()
                                }
                            })
                        }else {
                            showObject?.nextEpDate = "No info available"
                        }
                        self.storedShows.append(showObject!)
                        self.storedShows.sort {$0.name < $1.name}
                        self.shows = self.storedShows
                    }
                    self.tableview.reloadData()
                })
            }
            self.tableview.refreshControl?.endRefreshing()
        }
    }
    
    func scheduleNotification(for show: Show) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [show.name])
        let content = UNMutableNotificationContent()
        content.body = "New \(show.name) episode is coming out today!"
        content.badge = 1
        
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "yyyy-MM-dd"
        let dateToFire = dateFromatter.date(from: show.dateForNotification!)
        var dateComponents = Calendar.current.dateComponents([.year,.month,.day], from: dateToFire!)
        dateComponents.hour = 10
        dateComponents.minute = 00
        dateComponents.second = 00
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: show.name, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
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
        case .Unknown,.InDev:  cell.statusView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        cell.showImage.downloadImage(from: shows[indexPath.row].imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showDetails") as! ShowDetailsViewController
        vc.show = shows[indexPath.row]
        searchbar.endEditing(true)
        tableview.deselectRow(at: indexPath, animated: true)
        self.present(vc, animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.lowercased()
        let queryShows = storedShows.filter { (show) -> Bool in
            return show.name.lowercased().contains(query)
        }
        shows = query != "" ? queryShows : storedShows
        self.tableview.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchbar.endEditing(true)
    }
}

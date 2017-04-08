//
//  CollectionViewController.swift
//  TVM
//
//  Created by Vasil Nunev on 07/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var shows = [Show]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 16)
        layout.itemSize = CGSize(width: (collectionView.frame.width/2)-16-5, height: 150)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        collectionView.collectionViewLayout = layout
        
        retrieveShows()
    }
    
    func retrieveShows() {
        shows.removeAll()
        Alamofire.request(URL(string: "http://api.tvmaze.com/schedule")!).responseJSON { (response) in
            if let json = response.result.value {
                let data = JSON(json).arrayValue
                for each in data {
                    let showObject = Show(data: each)
                    self.shows.append(showObject!)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func transform(cell: UICollectionViewCell) {
        let coverFrame = cell.convert(cell.bounds, to: view)
        
        // TODO: this works currently but may not work for all
        let transformOffsetY = collectionView.bounds.height * 2/3 // Point at which transform should be complete
        let percent = (0...1).clamp((coverFrame.minY - transformOffsetY) / (collectionView.bounds.height-transformOffsetY))
        
        let maxScaleDifference: CGFloat = 0.2
        let scale = percent * maxScaleDifference
        
        cell.transform = CGAffineTransform(scaleX: 1-scale, y: 1-scale)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width/2)-21
        return CGSize(width: width, height: width+20)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showDetails") as! ShowDetailsViewController
        vc.show = shows[indexPath.row]
        self.present(vc, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionShow", for: indexPath) as! ShowCollectionCell
        cell.showImage.downloadImage(from: shows[indexPath.item].imageURL)
        transform(cell: cell)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView.visibleCells.forEach{transform(cell: $0)}
    }
}

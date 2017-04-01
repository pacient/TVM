//
//  ImageViewExtension.swift
//  TVM
//
//  Created by Vasil Nunev on 01/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

extension UIImageView {
    func downloadImage(from url: String) {
        Alamofire.request(url).downloadProgress { progress in
            //add code for progress of the image loading
            }
            .responseData { response in
                if let data = response.result.value {
                    self.image = UIImage(data: data)
                }
        }
    }
}

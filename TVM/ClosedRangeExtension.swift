//
//  ClosedRangeExtension.swift
//  TVM
//
//  Created by Vasil Nunev on 08/04/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import UIKit

extension ClosedRange{
    func clamp(_ value: Bound) -> Bound {
        if value < lowerBound {
            return lowerBound
        } else if value > upperBound {
            return upperBound
        }
        return value
    }
}

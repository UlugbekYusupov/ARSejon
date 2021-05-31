//
//  HaversineDistance.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 11/11/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import CoreLocation

class HaversinDistance {
    
    static let shared = HaversinDistance()
    
    func haversinDistance(lan1: Double, lon1: Double, lan2: Double, lon2: Double, radius: Double = 6367444.7) -> Double {
        
        let haversin = {(angle: Double) -> Double in
            return (1 - cos(angle))/2
        }
        
        let ahaversin = { (angle: Double) -> Double in
            return 2*asin(sqrt(angle))
        }
        
        let dToR = { (angle: Double) -> Double in
            return (angle / 360) * 2 * .pi
        }
        
        let lat1 = dToR(lan1)
        let lon1 = dToR(lon1)
        let lat2 = dToR(lan2)
        let lon2 = dToR(lon2)
        
        return radius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1))
    }
}

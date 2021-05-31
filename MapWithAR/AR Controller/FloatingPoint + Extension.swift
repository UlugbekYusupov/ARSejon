//
//  FloatingPoint + Extension.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 11/11/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}

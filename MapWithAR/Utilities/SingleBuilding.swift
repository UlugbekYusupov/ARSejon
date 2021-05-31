//
//  SingleBuilding.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 2/1/20.
//  Copyright © 2020 Ulugbek Yusupov. All rights reserved.
//

import Foundation
import UIKit

struct SingleBuilding {
    let buildingName: String
    init(uid: String, dictionary: [String: Any]) {
        self.buildingName = dictionary["buildingName"] as? String ?? ""
    }
}

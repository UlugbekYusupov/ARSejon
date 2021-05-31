//
//  MapView  + Extension.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 12/23/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import MapKit
extension UniversityMapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        renderer.lineWidth = 5
        renderer.createPath()
        return renderer
    }
}

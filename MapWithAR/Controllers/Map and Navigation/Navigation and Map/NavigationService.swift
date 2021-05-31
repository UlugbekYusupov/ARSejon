//
//  NavigationService.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 10/10/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NavigationService {
    
    static let shared = NavigationService()
    
    var steps: [MKRoute.Step] = []
    var distance: CLLocationDistance?
    var instructions: String?
    var expectedTimeInterval: TimeInterval?
    
    func getDirection(mapView: MKMapView, startingMapItem: MKMapItem, destinationMapItem: MKMapItem) {
        let request = self.createDirectionsRequest(startingMapItem: startingMapItem,destinationMapItem: destinationMapItem)
        let directions = MKDirections(request: request)
        
        directions.calculate { responce, error in
            guard let responce = responce else {return}
            
            for route in responce.routes {
                self.steps.append(contentsOf: route.steps)
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                self.expectedTimeInterval = route.expectedTravelTime
            }
            
            for step in self.steps {
                self.distance = step.distance
                self.instructions = step.instructions
                print(self.distance)
                print(self.instructions)
            }
        }
    }
    
    func createDirectionsRequest(startingMapItem: MKMapItem, destinationMapItem: MKMapItem) -> MKDirections.Request{
        let directionRequest = MKDirections.Request()
        directionRequest.source = startingMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        directionRequest.requestsAlternateRoutes = true
        return directionRequest
    }
}

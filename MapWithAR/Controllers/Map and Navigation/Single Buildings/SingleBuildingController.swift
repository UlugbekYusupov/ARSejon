//
//  SingleBuildingController.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 1/19/20.
//  Copyright © 2020 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import SwiftyButton
import FirebaseStorage
import FirebaseDatabase
import MapKit
import CoreLocation
import FlyoverKit

class SingleBuildingController: UIViewController {
    
    let shared = UniversityMapController.shared
    
    let screenSize = UIScreen.main.bounds.size
    var database: Database = Database.database()
    var storage: Storage = Storage.storage()
    
    let roundedWhiteView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    let buildingNameLabel: UILabel = {
        let label = UILabel()
        label.text = "jfhkdsjhfks"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    let cellID = "cellID"
    
    var buildingImagesCollectionView: UICollectionView?
    
    let seeBuildingButton: PressableButton = {
        let button = PressableButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        button.setTitleColor(.white, for: .normal)
        button.colors = .init(button: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0), shadow: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0))
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(handleSeeBuildingsButton), for: .touchUpInside)
        return button
    }()
    
    let buildingImageView: UIImageView = {
        let v = UIImageView(image: #imageLiteral(resourceName: "image"))
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBuildingImagesCollectionView()
    }

    fileprivate func setupBuildingImagesCollectionView() {
        let layout: CarouselLayout = CarouselLayout()
        buildingImagesCollectionView = UICollectionView(frame: CGRect(x: 0, y: screenSize.height , width: screenSize.width, height: view.frame.size.height / 4), collectionViewLayout: layout)
        buildingImagesCollectionView!.dataSource = self
        buildingImagesCollectionView!.delegate = self
        buildingImagesCollectionView!.contentInsetAdjustmentBehavior = .always
        buildingImagesCollectionView?.register(BuildingImageCell.self, forCellWithReuseIdentifier: cellID)
        buildingImagesCollectionView!.decelerationRate = .fast
        buildingImagesCollectionView!.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(roundedWhiteView)
        roundedWhiteView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(), size: CGSize(width:0,height:0))
        roundedWhiteView.roundCorners([.topLeft, .topRight], radius: 40)
        
        roundedWhiteView.addSubview(buildingNameLabel)
        buildingNameLabel.centerXInSuperview()
        buildingNameLabel.anchor(top: roundedWhiteView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 50))
        
        roundedWhiteView.addSubview(buildingImagesCollectionView!)
        buildingImagesCollectionView!.anchor(top: buildingNameLabel.bottomAnchor, leading: roundedWhiteView.leadingAnchor, bottom: nil, trailing: roundedWhiteView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 210))
        
        roundedWhiteView.addSubview(seeBuildingButton)
        seeBuildingButton.centerXInSuperview()
        seeBuildingButton.anchor(top: nil, leading: nil, bottom: roundedWhiteView.bottomAnchor, trailing: nil, padding: .init(), size: CGSize(width: 100, height: 50))
    }
    
    @objc func handleSeeBuildingsButton() {
        
        self.removeFromParent()
        
        let tappedBuildingName = buildingNameLabel.text
        
        let data = Dictionary<String, String>(plistNamed: "BuildingCoordinates")

            for name in data.keys {
                if tappedBuildingName == name {
                    // setting the latitude and longtitidu of tapped building
                    let coordinate = data[name]
                    let latitude = Double((coordinate?.prefix(9))!)!
                    let longtitude = Double((coordinate?.suffix(10))!)!
                    shared.destination = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)

                    //config of the camera of tapped building
                    let configuration = FlyoverCamera.Configuration(duration: 10.0, altitude: 100.0, pitch: 80.0, headingStep: -50.0, regionChangeAnimation: .animated(duration: 5.0, curve: .easeOut))
                    let camera = FlyoverCamera(mapView:shared.mapView!,configuration: configuration)
                    
                    camera.start(flyover: shared.destination!)

                    let currentPlacemark = MKPlacemark(coordinate: shared.currentLocation!, addressDictionary: nil)
                    let destinationPlacemark = MKPlacemark(coordinate: shared.destination!, addressDictionary: nil)

                    if let destinationLocation = destinationPlacemark.location {
                        shared.mapView?.removeAnnotations(shared.mapView!.annotations)
                        shared.addAnnotation(title: name, coordinate: destinationLocation.coordinate)
                    }

                    shared.startingMapItem = MKMapItem(placemark: currentPlacemark)
                    shared.destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                }
        }
    }
}

extension UIImageView {
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 10
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}

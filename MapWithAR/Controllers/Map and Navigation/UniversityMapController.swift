//
//  UniversityMapController.swift
//  MapWithMapKit
//
//  Created by Ulugbek Yusupov on 9/16/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FlyoverKit
import DCAnimationKit
import ARKit
import SwiftyButton


class UniversityMapController: UIViewController {
    
    var expandedCell: BuildingCell?
    var isStatusBarHidden = false
     

    var startingMapItem: MKMapItem?
    var destinationMapItem: MKMapItem?
    var destination: CLLocationCoordinate2D?
    var currentLocation: CLLocationCoordinate2D?

    
    static let shared = UniversityMapController()
    
    //MARK:- vars and views
    var mapSwitchSegment: UISegmentedControl?
    var mapView: MKMapView?
    var sejong = Sejong(filename: "UniversityCoordinate")
    var arView: UIView?
    

    let screenSize = UIScreen.main.bounds.size

    let arController = ARController()
    let cellID = "cellID"
    
    private let locationManager = CLLocationManager()
    
    fileprivate let menuWidth: CGFloat = 250
    fileprivate var isMenuOpen = false
    
    let transparentView = UIView()

    let seperaterLineView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()
    
//    let singleBuildingController = SingleBuildingController()
    
    let selectedView: UIView = {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }()
    
    var menuCollectionView: UICollectionView!
    
    let menuView: UIView = {
        let v = UIView()
//        v.backgroundColor = UIColor(white: 0, alpha: 0.5)
        v.backgroundColor = .clear
        return v
    }()
    
    let buildingButton: PressableButton = {
        let button = PressableButton(type: .system)
        button.addTarget(self, action: #selector(handleBuildingButton), for: .touchUpInside)
        button.colors = .init(button: .init(red: 30/255, green: 52/255, blue: 66/255, alpha: 1), shadow: .init(white: 0, alpha: 0.9))
        button.tintColor = .white
        button.shadowHeight = 5
        button.cornerRadius = 5
        return button
    }()
    
    let viewInAR: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(white: 0, alpha: 0.5)
        button.backgroundColor = #colorLiteral(red: 0.1364961977, green: 0.3638872426, blue: 0.5168345495, alpha: 1)
        button.addTarget(self, action: #selector(handleViewInAR), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(white: 0, alpha: 0.5)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "Icon_12-512"), for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let directionButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDirectionButton), for: .touchUpInside)
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "Map__Directions-512"), for: .normal)
        button.contentMode = .scaleToFill
        return button
    }()
    
    let buildingLabel: UILabel = {
        let label = UILabel()
        label.text = "Buildings"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let viewInARLabel: UILabel = {
           let label = UILabel()
           label.text = "View in AR"
           label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
           label.textColor = .white
           label.textAlignment = .center
           return label
       }()
  
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapKitView()
        setupButtons()
        setupCamera()
        setupLocationManager()
        setupCollectionView()
    }
    
    //MARK:- setup fileprivates
    
    fileprivate func setupCollectionView() {
        let layout: ZoomAndSnapFlowLayout = ZoomAndSnapFlowLayout()
        
        menuCollectionView = UICollectionView(frame: CGRect(x: 0, y: screenSize.height , width: screenSize.width, height: 350), collectionViewLayout: layout)
        
        menuCollectionView.dataSource = self
        menuCollectionView.delegate = self
        menuCollectionView.contentInsetAdjustmentBehavior = .always
        menuCollectionView.register(BuildingCell.self, forCellWithReuseIdentifier: cellID)
        menuCollectionView.decelerationRate = .fast
        menuCollectionView.backgroundColor = .clear
    }
    
    fileprivate func setupMapKitView() {
        mapView = MKMapView()
        view.addSubview(mapView!)
        mapView?.frame = view.frame
        mapView?.delegate = self
        mapView?.setUserTrackingMode(.followWithHeading, animated: true)
        
        let latDelta = sejong.overlayTopLeftCoordinate.latitude -
            sejong.overlayBottomRightCoordinate.latitude
        let span = MKCoordinateSpan(latitudeDelta: fabs(latDelta), longitudeDelta: 0.0)
        let region = MKCoordinateRegion(center: sejong.midCoordinate, span: span)
        mapView!.region = region
    }
    
    fileprivate func openCamera() {
        arView = arController.view
        self.mapView!.addSubview(arView!)
        arView?.anchor(top: mapView?.topAnchor, leading: mapView?.leadingAnchor, bottom:nil, trailing: mapView?.trailingAnchor,padding: .init(),size: CGSize(width: 0, height: (mapView?.frame.size.height)!))
    }

    fileprivate func setupButtons() {
        mapView?.addSubview(buildingButton)
        buildingButton.centerXInSuperview()
        buildingButton.anchor(top: nil, leading: nil, bottom: mapView?.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 40, right: 0), size: CGSize(width: 150, height: 40))
        
        buildingButton.addSubview(buildingLabel)
        buildingLabel.fillSuperview()
    }
    
    fileprivate func setupCamera() {
        let camera = MKMapCamera()
        camera.centerCoordinate = mapView!.centerCoordinate
        camera.pitch = 80.0
        camera.altitude = 180
        camera.heading = -15.0
        mapView!.setCamera(camera, animated: true)
    }
    
    @objc fileprivate func handleViewInAR() {
        self.openCamera()
        self.viewInAR.isHidden = true
        self.viewInARLabel.isHidden = true
    }
    
    @objc fileprivate func handleCancel() {
        self.setupCamera()
        self.mapView?.removeOverlays(self.mapView!.overlays)
        self.mapView?.removeAnnotations(self.mapView!.annotations)
        self.cancelButton.isHidden = true
        self.viewInAR.isHidden = true
        self.viewInARLabel.isHidden = true
        self.buildingButton.isHidden = false
        self.buildingLabel.isHidden = false
    }
    
    fileprivate func setupTransparentView() {
        transparentView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        transparentView.frame = self.mapView!.frame
        transparentView.alpha = 0
        transparentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        mapView?.addSubview(transparentView)
    }
    
    @objc fileprivate func handleBuildingButton() {
          
        setupTransparentView()
        
        menuView.frame = CGRect(x: 0, y: screenSize.height , width: screenSize.width, height: 350)
        
        menuView.addSubview(menuCollectionView)
        
        menuCollectionView.fillSuperview(padding: .init(top: 0, left: 0, bottom: self.view.safeAreaInsets.bottom, right: 0))
        mapView?.addSubview(menuView)

        menuView.roundCorners([.topLeft,.topRight], radius: 10)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.3
            self.menuView.frame =  CGRect(x: 0, y: self.screenSize.height - 300, width: self.screenSize.width, height: 350)
          }, completion: nil)
      }
      
      @objc func handleTapDismiss() {
          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
              self.transparentView.alpha = 0
            self.menuView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: 350)
          }, completion: nil)
      }
    
    @objc func handleFocusLocation() {
        self.beginLocationUpdates(locationManager: self.locationManager)
        self.setupCamera()
    }
}

extension UniversityMapController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {return}
        currentLocation = latestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status ==  .authorizedWhenInUse || status == .authorizedAlways {
            beginLocationUpdates(locationManager: manager)
        }
    }
    
    fileprivate func setupLocationManager() {
          locationManager.delegate = self
          switch CLLocationManager.authorizationStatus() {
          case .notDetermined:
              locationManager.requestAlwaysAuthorization()
              break
          case .authorizedAlways:
              beginLocationUpdates(locationManager: locationManager)
              break
          case .denied:
              break
          case .authorizedWhenInUse:
              beginLocationUpdates(locationManager: locationManager)
              break
          case .restricted:
              break
          default:
              break
          }
    }
    
    fileprivate func beginLocationUpdates(locationManager: CLLocationManager) {
        mapView?.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
       
       
    @objc fileprivate func handleDirectionButton() {
        
        self.directionButton.isHidden = true
        self.buildingLabel.isHidden = true
        self.buildingButton.isHidden = true
        
        setupCamera()
        
        NavigationService.shared.getDirection(mapView: self.mapView!, startingMapItem: startingMapItem!, destinationMapItem: destinationMapItem!)
        
        mapView?.addSubview(cancelButton)
        cancelButton.anchor(top: mapView?.topAnchor, leading: mapView?.leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 15, left: 2, bottom: 0, right: 5),size: CGSize(width: 40, height: 40))
        cancelButton.layer.cornerRadius = 40 / 2
        cancelButton.isHidden = false
        
        self.mapView?.addSubview(viewInAR)
        viewInAR.centerXInSuperview()
        viewInAR.anchor(top: nil, leading: nil, bottom: mapView?.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 40, right: 0), size: CGSize(width: 100, height: 30))
        viewInAR.isHidden = false
        viewInAR.addSubview(viewInARLabel)
        viewInARLabel.fillSuperview()
        viewInARLabel.isHidden = false
    }
    
    func addAnnotation(title: String, coordinate: CLLocationCoordinate2D) {
            let appleMarkAnnotation = MKPointAnnotation()
            appleMarkAnnotation.title = title
            appleMarkAnnotation.coordinate = coordinate
            mapView?.addAnnotation(appleMarkAnnotation)
    }
    
}
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(buildingNames.count)
//        return buildingNames.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BuildingCell
//        cell.buildingNameLabel.text = buildingNames[indexPath.row]
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 30
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        menuView.removeFromSuperview()
//        transparentView.removeFromSuperview()
//
//        mapView?.addSubview(directionButton)
//        directionButton.centerXInSuperview()
//
//        directionButton.anchor(top: nil, leading: nil, bottom: buildingButton.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 20, right: 0), size: CGSize(width: 50, height: 50))
//
//        directionButton.expand(into: self.mapView!, finished: nil)
//
//        let tappedBuildingName = buildingNames[indexPath.row]
//
//        let data = Dictionary<String, String>(plistNamed: "BuildingCoordinates")
//
//        for name in data.keys {
//            if tappedBuildingName == name {
//                // setting the latitude and longtitidu of tapped building
//                let coordinate = data[name]
//                let latitude = Double((coordinate?.prefix(9))!)!
//                let longtitude = Double((coordinate?.suffix(10))!)!
//                destination = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
//
//                //config of the camera of tapped building
//                let configuration = FlyoverCamera.Configuration(duration: 10.0, altitude: 100.0, pitch: 80.0, headingStep: -50.0, regionChangeAnimation: .animated(duration: 5.0, curve: .easeOut))
//                let camera = FlyoverCamera(mapView: self.mapView!, configuration: configuration)
//                camera.start(flyover: destination!)
//
//                let currentPlacemark = MKPlacemark(coordinate: currentLocation!, addressDictionary: nil)
//                let destinationPlacemark = MKPlacemark(coordinate: destination!, addressDictionary: nil)
//
//                if let destinationLocation = destinationPlacemark.location {
//                    mapView?.removeAnnotations(mapView!.annotations)
//                    addAnnotation(title: name, coordinate: destinationLocation.coordinate)
//                }
//
//                startingMapItem = MKMapItem(placemark: currentPlacemark)
//                destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//            }
//        }
//    }

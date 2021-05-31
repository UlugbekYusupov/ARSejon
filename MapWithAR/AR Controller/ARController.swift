//
//  ViewController.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 9/23/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

/*
 ARKit requires iOS 11, and supports the following devices:

 iPhone 6S and upwards
 iPhone SE
 iPad (2017)
 All iPad Pro models
 iOS 11 can be downloaded from Apple’s Developer website.
 */


import UIKit
import SceneKit
import ARKit
import CoreLocation

class ARController: UIViewController {
    
    let sceneView: ARSCNView = {
        let v = ARSCNView()
        return v
    }()
    
    let b: UIButton = {
        let f = UIButton()
        return f
    }()
    
    var x: CGFloat?
    var y: CGFloat?
    var z: CGFloat?

    var planeNode: SCNNode?

    let scanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "766928c0cd75ebb3619ae050c934fac7"), for: .normal)
        return button
    }()
    
    static let shared = ARController()
    
    let goButton: UIButton = {
        let button = UIButton(type: .custom)
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "logo-brand-red-font-the-start-button"), for: .normal)
        button.addTarget(self, action: #selector(handleGoButton(node:)), for: .touchUpInside)
        return button
    }()
    
    var planeDetected = false
    var didChange = false
    var isMoved = false
    let configuration = ARWorldTrackingConfiguration()
    
    let idleScene = SCNScene(named: "art.scnassets/goast/idleFixed.dae")!
    let dancingScene = SCNScene(named: "art.scnassets/goast/samba.dae")
    let walkingScene = SCNScene(named: "art.scnassets/goast/WalkingFixed.dae")
    
    
    fileprivate func setupPlayButton() {
        view.addSubview(scanButton)

        scanButton.centerInSuperview(size: CGSize(width: 200, height: 200))

        scanButton.addTarget(self, action: #selector(handleScanButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        sceneView.fillSuperview()
        setupPlayButton()
    }
    
    @objc fileprivate func handleScanButton(node: SCNNode) {
        configuration.planeDetection = .horizontal
        self.scanButton.removeFromSuperview()
        setupSceneView()
//        planeNode?.eulerAngles.z = -90
    }
    
    func setupSceneView() {
        configuration.worldAlignment = .gravity
        sceneView.session.run(configuration, options: [.removeExistingAnchors,.resetTracking])
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            // 4x4  transform matrix describing camera in world space
            let mat = SCNMatrix4(frame.camera.transform)
            // orientation of camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            // location of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
}

extension ARController: ARSCNViewDelegate {
    
    fileprivate func addNodeToPlane(_ planeAnchor: ARPlaneAnchor, _ node: SCNNode) {

        let width = CGFloat(0.2)
        let height = CGFloat(0.2)

        let plane = SCNPlane(width: width, height: height)

        plane.materials.first?.diffuse.contents = UIColor.clear

        let planeNode = SCNNode(geometry: plane)

        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)

        planeNode.position = SCNVector3(x,y,z)
        print(x,y,z)
        planeNode.scale = SCNVector3(0.2,0.2,0.2)
        planeNode.eulerAngles.y = 45

        for child in idleScene.rootNode.childNodes {
            child.name = "firstName"
            planeNode.addChildNode(child)
        }

        node.addChildNode(planeNode)

    }
    
    @objc fileprivate func handleGoButton(node: SCNNode) {
        planeNode?.eulerAngles.y = -90
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !planeDetected {
            planeDetected = true
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            addNodeToPlane(planeAnchor, node)

            DispatchQueue.main.async {
                self.view.addSubview(self.goButton)
                self.goButton.centerXInSuperview()
                self.goButton.anchor(top: nil, leading: nil, bottom: self.view.bottomAnchor, trailing: nil,padding: .init(top: 0, left: 0, bottom: 10, right: 0),size: CGSize(width: 100, height: 50))
            }
            planeNode = node
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        node.eulerAngles = planeNode!.eulerAngles
        let distance = simd_distance(node.simdTransform.columns.3, (sceneView.session.currentFrame?.camera.transform.columns.3)!)
        print(distance)

        if !didChange {
            didChange = true
            node.eulerAngles = planeNode!.eulerAngles
        }
    }
}

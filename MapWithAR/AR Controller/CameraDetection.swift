//
//  CameraDetection.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 11/25/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import AVKit
import Vision

class CameraDetection: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(white: 0, alpha: 0.5)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "Icon_12-512"), for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    @objc fileprivate func handleCancel() {
        self.dismiss(animated: true, completion: nil)
        ARController.shared.setupSceneView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 2, bottom: 0, right: 0),size: CGSize(width: 50, height: 50))
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        setupIdentifierConfidenceLabel()
    }
        
        fileprivate func setupIdentifierConfidenceLabel() {
            view.addSubview(identifierLabel)
            identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
            identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
            let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                
                guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                
                guard let firstObservation = results.first else { return }
                
                print(firstObservation.identifier, firstObservation.confidence)
                
                DispatchQueue.main.async {
                    self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                }
                
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }

    }

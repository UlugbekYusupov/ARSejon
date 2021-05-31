//
//  RootController.swift
//  MapWithMapKit
//
//  Created by Ulugbek Yusupov on 9/19/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit
import SwiftyButton

class RootController: UIViewController {
    
    let universityMap = UniversityMapController()
    let arController = ARController()
    
    static let shared = RootController()
    
    let rootImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "318755")
        return iv
    }()
    
    let transparentView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1, alpha: 0)
        return v
    }()
    
    let nextButtonLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Verdana", size: 16)
        return label
    }()
    
    let nameTextField: UITextField = {
        let field = UITextField()
        field.tintColor = .white
        field.textColor = .white
        field.textAlignment = .center
        field.backgroundColor = UIColor(white: 0, alpha: 0.6)
        return field
    }()
    
    let nextButton: PressableButton = {
        let button = PressableButton(type: .system)
        button.clipsToBounds = true
        button.setTitle("Next", for: .normal)
        button.colors = .init(button: .red, shadow: .black)
        button.tintColor = .white
        button.shadowHeight = 5
        button.cornerRadius = 5
        return button
    }()
    
    var scrollView: UIScrollView?
    var arScrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScrollView()
        
    }
    
    fileprivate func setupScrollView() {
        let width = self.view.bounds.size.width * 3
        
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView?.backgroundColor = .white
        scrollView?.isPagingEnabled = true
        scrollView?.contentSize = CGSize(width: width, height: 1.0)
        scrollView?.isScrollEnabled = false
        scrollView?.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView?.addSubview(rootImageView)
        rootImageView.centerInSuperview(size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
        
        scrollView?.addSubview(transparentView)
        transparentView.centerInSuperview(size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
        
        
        //        nameTextField
        scrollView?.addSubview(nameTextField)
        nameTextField.centerInSuperview(size: CGSize(width: 200, height: 40))
        nameTextField.resignFirstResponder()
        
        //        nextButton
        scrollView?.addSubview(nextButton)
        nextButton.centerXInSuperview()
        nextButton.anchor(top: nameTextField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 15, left: 0, bottom: 0, right: 0), size: CGSize(width: 140, height: 40))
        nextButton.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)

        
        //        add scrollView to the view
        view.addSubview(scrollView!)
        scrollView!.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
    }
    
    @objc fileprivate func handleNextButton() {
//        universityMap.nameLabel.text = nameTextField.text
        var frame = universityMap.view.frame
        frame.origin.x = view.bounds.size.width
        universityMap.view.frame = frame
        self.addChild(universityMap)
        scrollView!.addSubview(universityMap.view)
        scrollView!.scrollRectToVisible(CGRect(x: scrollView!.frame.size.width * 1, y: 0, width: scrollView!.frame.size.width, height: scrollView!.frame.size.height), animated: true)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

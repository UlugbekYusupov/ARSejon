//
//  BuildingImageCells.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 1/24/20.
//  Copyright © 2020 Ulugbek Yusupov. All rights reserved.
//

import UIKit

class BuildingImageCell: UICollectionViewCell {
    
    let shadowViews: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset = CGSize.zero
        v.layer.shadowRadius = 10
        v.layer.shadowPath = UIBezierPath(roundedRect: v.bounds, cornerRadius: 10).cgPath
        v.backgroundColor = .clear
        return v
    }()
    
    let imageView: UIImageView = {
        let v = UIImageView(image: #imageLiteral(resourceName: "image"))
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleToFill
        v.layer.cornerRadius = 15
        v.backgroundColor = .red
        
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 5
        v.layer.shadowOffset = CGSize(width: -1, height: 10)
        v.layer.shadowRadius = 10
        v.layer.shadowPath = UIBezierPath(roundedRect: v.bounds, cornerRadius: 10).cgPath
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
//        addSubview(shadowView)
//        shadowView.fillSuperview()
        
        addSubview(imageView)
        imageView.fillSuperview()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

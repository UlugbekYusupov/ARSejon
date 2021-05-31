//
//  BuildingCell.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 9/27/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit

class BuildingCell: UICollectionViewCell {
    
    private let maskShapeLayer: CAShapeLayer = CAShapeLayer()
    var initialFrame: CGRect?
    var initialCornerRadius: CGFloat?
    
    let screenSize = UIScreen.main.bounds
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        maskShapeLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 12).cgPath
    }
    
    let buildingNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        return label
    }()

    let buildingImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "318755"))
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialFrame = self.frame
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 1
//        layer.shadowOffset = .zero
//        layer.shadowRadius = 5
//
//        self.contentView.layer.cornerRadius = 2.0
//        self.contentView.layer.borderWidth = 1.0
//        self.contentView.layer.borderColor = UIColor.clear.cgColor
//        self.contentView.layer.masksToBounds = false

        addSubview(buildingImageView)
        buildingImageView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(),size: CGSize(width: 0, height: self.frame.size.height - 35))
        addSubview(buildingNameLabel)
        buildingNameLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: buildingImageView.topAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BuildingCell {
    class var reusableIndentifer: String { return String(describing: self) }
}

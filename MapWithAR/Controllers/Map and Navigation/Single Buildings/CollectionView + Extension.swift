//
//  CollectionView + Extension.swift
//  MapWithAR
//
//  Created by Ulugbek Yusupov on 12/23/19.
//  Copyright © 2019 Ulugbek Yusupov. All rights reserved.
//

import UIKit

extension UniversityMapController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BuildingCell
        cell.buildingNameLabel.text = buildingNames[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buildingNames.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let singleBuildingController = SingleBuildingController()
        singleBuildingController.buildingNameLabel.text = buildingNames[indexPath.row]
        
        self.present(singleBuildingController,animated: true)
        handleTapDismiss()
    }
}

extension SingleBuildingController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BuildingImageCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenSize.width - 70, height: 210)
    }
}

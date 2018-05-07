//
//  ImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by doc on 07/05/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func set(imageData: Data){
        self.imageView.image = UIImage(data: imageData)
    }
}

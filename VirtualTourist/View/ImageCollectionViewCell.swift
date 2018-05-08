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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func set(imageData: Data){
        self.imageView.image = UIImage(data: imageData)
    }
    
    func startActivity(){
        activityIndicator.startAnimating()
    }
    
    func stopActivity(){
        activityIndicator.stopAnimating()
    }
    
    func resetCellImage(){
        self.imageView.image = nil
    }
    
    func setSelected(){
        self.imageView.alpha = self.imageView.alpha == 0.5 ? 1.0 : 0.5
    }
    
}

//
//  CollectionView.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 21/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import UIKit

class CollectionViewPhoto: UICollectionViewCell {
    
    //MARK: - Variables and Outlets
    
    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        
        imagePhoto.image = nil
    }
    
    override var isSelected: Bool {
        
        didSet {
            
            if self.isSelected {
                
                if alpha == 1 {
                    
                    self.alpha = 0.5
                } else {
                    self.alpha = 1
                }
            }
        }
    }
}


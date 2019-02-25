//
//  CollectionView.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 21/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation
import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - CollectionView Protocol Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let itens = fetchedResultsControllerPhoto.sections?[section].numberOfObjects
        
        if itens! > 0 {
            
            return itens!
            
        } else {
            
            return numberofItens
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionView", for: indexPath) as! CollectionViewPhoto
        
        if listOfUrlPhotos.count != 0 {
            
            let urlImage = listOfUrlPhotos[indexPath.row]
            
//            imageUrlString = urlImage
            
            if let imageFromCache = self.imageCache.object(forKey: urlImage.absoluteString as NSString)  {
                
                cell.imagePhoto.image = imageFromCache
            }
            
            DispatchQueue.main.async {
                
                cell.activityIndicator.startAnimating()
            }
            
            request.getPicture(url: urlImage) {(image: UIImage) in
                
                DispatchQueue.main.async {
                    
                    cell.imagePhoto.image = image
                    cell.activityIndicator.stopAnimating()
                }
            }
            
        } else if fetchedResultsControllerPhoto.fetchedObjects != nil {
            
            let collectionPhoto = fetchedResultsControllerPhoto.object(at: indexPath)
            
            if let image = collectionPhoto.image {
                
                cell.imagePhoto.image = UIImage(data: image)
            }
        }
        
        return cell
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }       
        
        if cell.alpha == 0.5 {

            listToRemove.append(indexPath)
            
        } else {
            
            for (index, item) in listToRemove.enumerated() {
                
                if item == indexPath {
                    
                    listToRemove.remove(at: index)
                }
            }
        }
        
        if listToRemove.count != 0 {
            setupView(isRequestTollBar: false)
        } else {
            setupView(isRequestTollBar: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberColum = 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumLineSpacing * CGFloat(numberColum - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberColum))
        
        return CGSize(width: size, height: size)
    }
}

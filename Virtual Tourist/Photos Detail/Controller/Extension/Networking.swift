//
//  Networking.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 13/07/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation
import UIKit

extension PhotoAlbumViewController {
    
    func updatePhotos(number: Int, completion: @escaping() -> ()) {
        
        removePhotos(removeAll: true, index: nil) {
            self.numberofItens = 0
            self.listOfUrlPhotos.removeAll()
        }
        
        let itensKey = ["method", "api_key", "lat", "lon", "format", "nojsoncallback", "per_page", "page"]
        let itensValue = ["flickr.photos.search", "a7f061c6180c62d2962c979ad77eee18", "\(coordinate.latitude)", "\(coordinate.longitude)", "json", "1", "15", "\(number)"]
        
        let url = request.buildURLQuery(itemsKey: itensKey, itemsValue: itensValue)
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        request.requestJSON(controller: self, passedURL: url) { [weak self] (listPhotos: PhotosList) in
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            if listPhotos.photos.photo.count != 0 {
                
                for item in listPhotos.photos.photo {
                    
                    guard let urlPhoto = URL(string:"https://farm\(item.farm).staticflickr.com/\(item.server)/\(item.id)_\(item.secret)_m.jpg") else { return }
                    
                    self?.listOfUrlPhotos.append(urlPhoto)
                    
                    self?.request.getData(url: urlPhoto, type: { (data) in
                        
                        self?.savePhotos(data)
                    })
                }
                
            } else {
                
                let controller = UIAlertController(title: "Ops", message: "Im sorry theres no pictures, try another point on the map.", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self?.present(controller, animated: true, completion: nil)
                
            }
            
            completion()
        }
    }
}

//
//  Requests.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 16/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Requests: UIViewController {

    //MARK: - URL constructor
    
    func buildURLQuery(itemsKey: [String], itemsValue: [String]) -> URL {
        
        var urlComponent = URLComponents()
        
        urlComponent.scheme = "https"
        urlComponent.host = "api.flickr.com"
        urlComponent.path = "/services/rest"
        
        var queryItems = [URLQueryItem]()
        
        for (_itemKey, _itemValue) in zip(itemsKey, itemsValue){
            
            let queryItem = URLQueryItem(name: _itemKey, value: _itemValue)
            queryItems.append(queryItem)
            
        }
        
        urlComponent.queryItems = queryItems
        
        return urlComponent.url!
    }
    
    //MARK: - Generic Decodable Request
    
    func requestJSON<T: Decodable>(controller: UIViewController, passedURL: URL, completion: @escaping (T) -> ()) {
        
        URLSession.shared.dataTask(with: passedURL) { (data, resp, error) in
            
            if error != nil { // Handle error…
                
                self.alert(externalController: controller, title: "Oops", msg: "Check your connection", numberOfButtons: 1, titleButtonOne: "ok", titleButtonTwo: nil, hasCompletion: false, completionOne: { () -> ()? in
                    return
                }, completionTwo: { () -> ()? in
                    return
                })
                
                return
                
            }
            
            // Wrong credentials
            guard let statusCode = (resp as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                self.alert(externalController: self, title: "Oops", msg: "Check your connection", numberOfButtons: 1, titleButtonOne: "ok", titleButtonTwo: nil, hasCompletion: false, completionOne: { () -> ()? in
                    return
                }, completionTwo: { () -> ()? in
                    return
                })
                
                return
            }
            
            do {
                
                guard let localData = data else { return }
                
                let _ = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
                let obj = try JSONDecoder().decode(T.self, from: localData)
                
                completion(obj)
                
            } catch {
                
                print(error)
            }
            
        } .resume()        
    }
    
    //MARK: - simple request URL

    func getPicture(url: URL, type completion: @escaping(UIImage) -> ()) {
        
        URLSession.shared.dataTask(with: url) { (data, resp, error) in
            
            guard error == nil else {
                
                fatalError(error.debugDescription)
            }
            
            guard let localData = data else { return }
            
            guard let image = UIImage(data: localData) else { return }
            
            completion(image)
            
            }.resume()
    }
    
    //MARK: - simple request URL
    
    func getData(url: URL, type completion: @escaping(Data) -> ()) {
        
        URLSession.shared.dataTask(with: url) { (data, resp, error) in
            
            guard error == nil else {
                
                fatalError(error.debugDescription)
            }
            
            guard let localData = data else { return }
            
            completion(localData)
            
            }.resume()
    }
}


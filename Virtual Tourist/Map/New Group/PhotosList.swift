//
//  PhotosList.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 16/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation

//MARK: - Photos Struct Model

struct PhotosList: Decodable {
    var photos: Photos
    var stat: String
}

struct Photos: Decodable{
    
    var page: Int
    var pages: Int
    var perpage: Int
    var total: String
    var photo: [ArrayPhotos]
}

struct ArrayPhotos: Decodable {
    
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
    var ispublic: Int
    var isfriend: Int
    var isfamily: Int
}

//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-05.
//

import Foundation
struct Photo: Codable {
    let photos: PhotosDetail
    let stat: ErrorMessage
    
    enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
}

struct PhotosDetail: Codable {
    let page: Int
    let pages: Int
    let total: Int
    let perpage: Int
    let photo: [SinglePhototDetail]
    
    enum CodingKeys: String, CodingKey{
        case page, pages, total, perpage, photo
    }
}

struct SinglePhototDetail: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
    }
}


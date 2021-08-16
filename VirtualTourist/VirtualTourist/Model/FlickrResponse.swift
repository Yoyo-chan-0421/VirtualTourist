//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-05.
//

import Foundation
struct Photo: Codable {
    let photos: PhotosDetail
    let stat: String
}

struct PhotosDetail: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [SinglePhototDetail]
    
}

struct SinglePhototDetail: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    let urlM: String
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case urlM = "url_m"
    }
}


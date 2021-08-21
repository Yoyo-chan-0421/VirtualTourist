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
    
    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case stat = "stat"
    }
}

struct PhotosDetail: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [SinglePhototDetail]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case photo = "photo"
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
}


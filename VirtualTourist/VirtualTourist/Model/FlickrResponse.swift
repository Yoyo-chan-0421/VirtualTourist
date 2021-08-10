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
    let perpage: Int
    let pages: Int
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
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url_m: String
}


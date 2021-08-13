//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-05.
//

import Foundation
import UIKit
class FlickrClient{
    struct Auth{
        static var apiKey = "ac450e1398c36f692650881ccf011933"
        static var secret = "26f5611af0a171e7"
    }
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/?method="
        case getPictureByLatAndLong(Double, Double, Int)
       case imageURL(String, String, String)
        
        var stringValue: String{
            switch self {
            case .getPictureByLatAndLong(let lat, let lon, let page): return Endpoints.base + "&api_key=\(Auth.apiKey)&lat=\(lat)&lon=\(lon)&accuracy=16&page=\(page)&format=json"
            case .imageURL(let server, let id, let secret): return "https://live.staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }

    class func requestImageLatAndLong(lat: Double, long: Double, completionHandler: @escaping (Photo?, Error?) -> Void ){
        let page = Int.random(in: 1..<200)
        let task = URLSession.shared.dataTask(with: Endpoints.getPictureByLatAndLong(lat, long, page).url) { data, response, error in
            guard let data = data else{
                completionHandler(nil, error)
                return
            }
            print(data)
            let decoder = JSONDecoder()
            do{
                let imageData = try decoder.decode(Photo.self, from: data)
                completionHandler(imageData, nil)
                print(imageData)
            }catch{
                completionHandler(nil, error)
                print(error)
                }
           
        }
        task.resume()
    }
    
    class func requestUrl(imageInfor: URL, singleImage: SinglePhototDetail, completionHandler: @escaping (UIImage?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: Endpoints.imageURL(singleImage.server, singleImage.id, singleImage.secret).url, completionHandler: { (data, response, error) in
            guard let data = data else{
                completionHandler(nil, error)
                return
            }
            let loadImage = UIImage(data: data)
            completionHandler(loadImage, nil)
        })
        task.resume()
    }
    
}

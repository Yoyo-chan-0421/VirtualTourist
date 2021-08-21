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
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search&nojsoncallback=1"
        case getPictureByLatAndLong(Double, Double, Int)
       case imageURL(String, String, String)
        
        var stringValue: String{
            switch self {
            case .getPictureByLatAndLong(let lat, let lon, let page): return Endpoints.base + "&api_key=\(FlickrClient.Auth.apiKey)&lat=\(lat)&lon=\(lon)&accuracy=16&page=\(page)&per_page=18&format=json"
            case .imageURL(let server, let id, let secret): return "https://live.staticflickr.com/\(server)/\(id)_\(secret)_c.jpg"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
//        https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=ac450e1398c36f692650881ccf011933&lat=7.4496097078722014&lon=5.297527418517835&accuracy=16&page=153&format=json
    }

    class func requestImageLatAndLong(lat: Double, long: Double, completionHandler: @escaping ([SinglePhototDetail?], Error?) -> Void ){
        let page = Int.random(in: 1..<10)
        let task = URLSession.shared.dataTask(with: Endpoints.getPictureByLatAndLong(lat, long, page).url) { data, response, error in
            guard let data = data else{
                DispatchQueue.main.async {
                    completionHandler([], error)
                }
               
                return
            }
            print(data)
            let decoder = JSONDecoder()
            do{
                let imageData = try decoder.decode(Photo.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(imageData.photos.photo, nil)
                }
               
                print(data)
              print(imageData)
            }catch{
                completionHandler([], error)
                print(error)
                }
        }
        task.resume()
    }
    
    class func requestUrl(imageInfor: URL, completionHandler: @escaping (Data?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: imageInfor) { data, response, error in
            guard let data = data else{
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                   
                return
            }
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
           
        }
        task.resume()
    }
    
}

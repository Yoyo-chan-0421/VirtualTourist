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
       
        
        var stringValue: String{
            switch self {
            case .getPictureByLatAndLong(let lat, let lon, let page): return Endpoints.base + "&api_key=\(Auth.apiKey)&lat=\(lat)&lon=\(lon)&accuracy=16&page=\(page)&format=json"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }

    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else{
                completionHandler(nil, error)
                return
            }
            let decoder = JSONDecoder()
            let range = (12..<(data.count - 1))
            print(range)
            let newData = data.subdata(in: range)
            do{
                let response = try decoder.decode(Photo.self, from: newData)
                completionHandler(response as? ResponseType, nil)
            }catch{
                do{
                    let errorResponse = try decoder.decode(ErrorMessage.self, from: newData) as Error
                    completionHandler(nil, errorResponse)
                }catch{
                    completionHandler(nil, error )
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    
    class func getImages(lat: Double, lon: Double, completionHandler: @escaping (PhotosDetail?, Error?) -> Void) {
        let page = Int.random(in: 1..<200)
        taskForGetRequest(url: Endpoints.getPictureByLatAndLong(lat, lon, page).url, responseType: Photo.self) { (response, error) in
            if let response = response{
                completionHandler(response.photos, nil)
            }else{
                completionHandler(nil, error)
            }
        }
    }
    
    class func downloadAndShow(url: URL, completionHandler: @escaping (Data?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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

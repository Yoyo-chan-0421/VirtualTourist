//
//  ImageCollectionView+CollectionDelegate.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-29.
//

import Foundation
import UIKit
extension ImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func getImageCompletion(picture: Photo?, error: Error?){
        if imageArray.count != 0 {
            for photot in imageArray {
                print(photot)
                if photot.image != nil{
                    let image = FlickrImages(context: dataController.viewContext)
                    image.pin = self.pin
                    self.imageArray.append(image)
                }
            }
        }else{
            
        }
        do{
            try dataController.viewContext.save()
        }catch{
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
        FlickrClient.getImage(lat: pin.latitude, long: pin.longitude, completionHandler: getImageCompletion(picture:error:))
       
      return cell
    }
    
}


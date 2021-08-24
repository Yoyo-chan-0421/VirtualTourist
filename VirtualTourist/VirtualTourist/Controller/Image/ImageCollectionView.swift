//
//  ImageCollectionView.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-05.

//MARK: Todos
// TODO:  show image if there is any in core data


import Foundation
import UIKit
import MapKit
import CoreData
class ImageCollectionView: UIViewController, NSFetchedResultsControllerDelegate {
    var pin: Pin!
    var pins = [Pin]()
    var flickrimage = FlickrImages()
    var imageArray = [FlickrImages]()
    var dataController: DataController!
    var fetchResultsController: NSFetchedResultsController<FlickrImages>!
    var singlePhotoDetail: SinglePhototDetail!
    var urlArray: [URL] = []
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var noImage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls)
        mapView.delegate = self
        mapViewEnable()
        print("collection\(String(describing: pins))")
        print(imageArray.count)
        addAnnotation()
        collectionView.reloadData()
        setUpFetchedResultsController()
        noImage.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
        setUpFetchedResultsController()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        do{
            imageArray = try dataController.viewContext.fetch(fetchResultsController.fetchRequest)
            if imageArray.count == 0 {
                print("Downloading image because there is no image save in core data")
                activityView.startAnimating()
                FlickrClient.requestImageLatAndLong(lat: pin.latitude, long: pin.longitude, completionHandler: handleImageByLatAndLongResponse(data:error:))
                print("downloading image")
            }else if imageArray.count != 0 {
                print("There is image in core data")
                let indexPath = IndexPath.init(row: 0, section: 0)
                print(indexPath.count)
                let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
                if let imagView = cell.imageView{
                    imagView.image = UIImage(data: flickrimage.image!)
                    setUpFetchedResultsController()
                }
              
            }
        }catch{
            print(error)
        }
        collectionView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func newCollectionButtonisPressed(_ sender: Any) {
        newCollectionButton.isEnabled = false
        for imageArrays in imageArray{
            dataController.viewContext.delete(imageArrays)
            try? dataController.viewContext.save()
        }
        imageArray = []
        urlArray = []
        
        FlickrClient.requestImageLatAndLong(lat: pin.latitude, long: pin.longitude, completionHandler: handleImageByLatAndLongResponse(data:error:))
        newCollectionButton.isEnabled = true
    }
    
    
        func setUpFetchedResultsController(){
        let fetchRequest:NSFetchRequest<FlickrImages> = FlickrImages.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchResultsController = NSFetchedResultsController<FlickrImages>(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        do{
            try fetchResultsController.performFetch()
        }catch{
            print(error)
        }
    }
    func delete(indexPath: IndexPath){
        dataController.viewContext.delete(imageArray[indexPath.row])
        imageArray.remove(at: indexPath.row)
        urlArray.remove(at: indexPath.row)
        collectionView.reloadData()
        try? dataController.viewContext.save()
    }
    
    func handleImageByLatAndLongResponse(data:[SinglePhototDetail?], error: Error?){
        if error != nil{
            print(error as Any)
        }else{
            activityView.startAnimating()

            if data.count != 0 {
                for data in data{
                    let picture = FlickrImages(context: self.dataController.viewContext)
                    picture.pin = self.pin
                    imageArray.append(picture)
                    let imageURL = FlickrClient.Endpoints.imageURL(data!.server, data!.id, data!.secret)
                    urlArray.append(imageURL.url)
                    activityView.stopAnimating()
                    activityView.isHidden = true
                }
//                do{
//                    let imageData = try dataController.viewContext.fetch(fetchResultsController.fetchRequest)
//                    if imageData.count == 0 {
//                        activityView.startAnimating()
//                        FlickrClient.requestImageLatAndLong(lat: pin.latitude, long: pin.longitude, completionHandler: handleImageByLatAndLongResponse(data:error:))
//                        print("downloading image")
//                    }else if imageData.count != 0 {
//                        setUpFetchedResultsController()
//                        if let img = flickrimage{
//                        cell.imageView.image = UIImage(data: img.image!)
//                        }
//                    }
//
//
//                }catch{
//                    print(error)
//                }
//                collectionView.reloadData()
            
            }else{
                noImage.isHidden = false
                newCollectionButton.isEnabled = true
                activityView.stopAnimating()
                activityView.isHidden = true
                print("no image")
            }
        }
        collectionView.reloadData()
        try? dataController.viewContext.save()
    }
}



extension ImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delete(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
        let picture = imageArray[indexPath.count]
        let url = urlArray[indexPath.row]
//        cell.imageView.image = UIImage(named: "placeHolder")

        if let data = picture.image{
            cell.imageView.image = UIImage(data: data)
            
        }else{

            cell.imageView.image = UIImage(named: "placeHolder")
            FlickrClient.requestUrl(imageInfor: url) { data, error in
                if let data = data {
                    cell.imageView.image = UIImage(data: data)
                    self.imageArray[indexPath.row].image = data
                    self.dataController.autoSave()

                    try? self.dataController.viewContext.save()
                }
            }
        }
        return cell
    }
}





extension ImageCollectionView: MKMapViewDelegate{
    func addAnnotation(){
        let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let regionCoordinates = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(regionCoordinates, animated: true)
        putAnnotation()
    }
    func putAnnotation(){
        var annotation = [MKPointAnnotation]()
        let latitude = CLLocationDegrees((pin.value(forKeyPath: "latitude") as? Double) ?? 0.0)
        let longitude = CLLocationDegrees((pin.value(forKeyPath: "longitude") as? Double) ?? 0.0)
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotations = MKPointAnnotation()
        annotations.coordinate = center
        annotation.append(annotations)
        self.mapView.addAnnotation(annotations)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reusedId = "pin"
        var pinShow = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
        
        if pinShow == nil{
            pinShow = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinShow?.pinTintColor = UIColor(named: "pinColor")
            pinShow?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinShow?.annotation = annotation
        }
        return pinShow
    }
    
    func mapViewEnable(){
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = true
        mapView.isUserInteractionEnabled = true
    }
}


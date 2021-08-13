//
//  ImageCollectionView.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-05.

//MARK: Todos
// TODO: 1.Succeed in downloading image
// TODO: 2.Add new generate image button
// TODO: 3.Make the method for the new generate image button
// TODO: 4.Add the placeholder image and place it when the image is downloading
// TODO: 5.Add the no Image label when there is no label
// TODO: 6.Add the activity view indicator before the no image label is shown
// TODO: 7.Add flowlayout for collectionView


import Foundation
import UIKit
import MapKit
import CoreData
class ImageCollectionView: UIViewController, NSFetchedResultsControllerDelegate {
    var pin: Pin!
    var pins = [Pin]()
    var image: FlickrImages!
    var imageArray = [FlickrImages]()
    var dataController: DataController!
    var fetchResultsController: NSFetchedResultsController<FlickrImages>!
    var isThereImage: Bool!
    var singlePhotoDetail: SinglePhototDetail!
    var cell: CollectionViewCell!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //        print("image array count\(imageArray.count)")
        //        print("collection mapview \(mapView!)")
        mapViewEnable()
        
        print("collection\(String(describing: pins))")
        print(imageArray.count)
        addAnnotation()
        collectionView.reloadData()
        print(FlickrClient.Endpoints.getPictureByLatAndLong(pin.latitude, pin.longitude, Int.random(in: 1..<200)).url)
        FlickrClient.requestImageLatAndLong(lat: pin.latitude, long: pin.longitude, completionHandler: handleImageByLatAndLongResponse(data:error:))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        generateNewCollection()
        print("pressed")
    }
    func generateNewCollection(){
        ImageModel.imageData = []
        collectionView.reloadData()
        self.dataController.viewContext.performAndWait{
            let pin = dataController.viewContext.object(with: self.pin.objectID) as! Pin
            pin.flickrImages = []
            try? dataController.viewContext.save()
            print("generating image")
        }
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
    
    func delete(indexPath: NSIndexPath){
        let delete = fetchResultsController.object(at:  indexPath as IndexPath)
        dataController.viewContext.delete(delete)
        do{
            try dataController.viewContext.save()
        }catch{
            print(error)
        }
    }
    func handleImageByLatAndLongResponse(data: Photo?, error: Error?){
        if error == nil {
        FlickrClient.requestUrl(imageInfor: FlickrClient.Endpoints.imageURL(ImageModel.imageURL!.server, ImageModel.imageURL!.id, ImageModel.imageURL!.secret).url, singleImage: ImageModel.imageURL!, completionHandler: handleImageURlResponse(image:error:))
        }else{
            print(error as Any)
        }
    }
    func handleImageURlResponse(image: UIImage?, error: Error?) -> Void{
        DispatchQueue.main.async {
            self.cell.imageView.image = image
        }
    }
}
extension ImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
   
    return cell
    }
}


//if let data = self.fetchResultsController.object(at: indexPath).image{
//        cell.imageView.image = UIImage(data: data)
//        }else{




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


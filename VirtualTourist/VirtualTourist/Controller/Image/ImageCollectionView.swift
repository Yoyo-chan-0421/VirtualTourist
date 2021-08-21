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
    var flickrimage = FlickrImages()
    var imageArray = [FlickrImages]()
    var dataController: DataController!
    var fetchResultsController: NSFetchedResultsController<FlickrImages>!
    var singlePhotoDetail: SinglePhototDetail!
    var urlArray: [URL] = []
    var cell = CollectionViewCell()
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
        checkIfThereIsAlreadyImage()
    }
    //                print(FlickrClient.Endpoints.getPictureByLatAndLong(pin.latitude, pin.longitude, Int.random(in: 1..<10)).url)
    //        print(FlickrClient.Endpoints.imageURL(ImageModel.imageURL?.server ?? "", ImageModel.imageURL?.id ?? "", ImageModel.imageURL?.secret ?? "").url)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
        setUpFetchedResultsController()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
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
    
    
    fileprivate func checkIfThereIsAlreadyImage() {
        if fetchResultsController.fetchedObjects?.count == 0{
            print("no image")
            activityView.startAnimating()
            FlickrClient.requestImageLatAndLong(lat: pin.latitude, long: pin.longitude, completionHandler: handleImageByLatAndLongResponse(data:error:))
        }else if fetchResultsController.fetchedObjects!.count > 0{
            print("There is already images")
            activityView.isHidden = true
            setUpFetchedResultsController()
            try? dataController.viewContext.save()
            let image = UIImage(data: flickrimage.image!)
            cell.imageView.image = image
            
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


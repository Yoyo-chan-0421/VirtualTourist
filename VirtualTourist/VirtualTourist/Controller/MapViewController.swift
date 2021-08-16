//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-05.
// FIXME: Fix the zoom when place pin
import Foundation
import UIKit
import MapKit
import CoreData
class MapViewController: UIViewController {
	//MARK: Properties
	var dataController: DataController!
	var pins:[Pin] = []
	let userDefault = UserDefaults.standard
	var fetchResultController:NSFetchedResultsController<Pin>!
	var pin: Pin!
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	// MARK: Outlets
	@IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longTapped: UILongPressGestureRecognizer!
	@IBOutlet weak var segmentControl: UISegmentedControl!
    
	
	
	//MARK: Overrides
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print(mapView.region)
		fetchRequest()
		mapView.delegate = self
		setUpFetchedResultsController()
		zoomToUserDefault()
		print(" map \(pins)")
		whatIsEnabled()

	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		firstTimeOpeningSetting()
	}
	
	
	
	//MARK: ACTIONS
    @IBAction func segmentChanged(_ sender: Any) {
		switch segmentControl.selectedSegmentIndex {
		case 0:
			mapView.mapType = .mutedStandard
		case 1:
			mapView.mapType = .satellite
		case 2:
			mapView.mapType = .hybridFlyover
		default:
			break
		}
    }
	fileprivate func firstTimeOpeningSetting() {
		if appDelegate.launchedBefore == false {
			print("this is the first launch")
			appDelegate.hasLaunchedBefore()
			firstTimeMapSetting()
		}
	}
	func firstTimeMapSetting(){
		mapView.mapType = .mutedStandard
		let coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
		let span = MKCoordinateSpan(latitudeDelta:100.0, longitudeDelta: 100.0)
		let region = MKCoordinateRegion(center: coordinate, span: span)
		self.mapView.setRegion(region, animated: true)
	}
    @IBAction func longPressing(_ sender: Any) {
     
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longpressed(press:)))
        mapView.addGestureRecognizer(longpress)
        longpress.numberOfTouchesRequired = 1
    }
	
	//MARK: FETCH
	fileprivate func fetchRequest() {
		let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
		if let result = try? dataController.viewContext.fetch(fetchRequest){
			var thisAnnotation = [MKPointAnnotation]()
			pins = result
			
			for pins in result{
				let annotation = MKPointAnnotation()
				annotation.coordinate.latitude = pins.latitude
				annotation.coordinate.longitude = pins.longitude
				thisAnnotation.append(annotation)
			}
			DispatchQueue.main.async {
				self.mapView.showAnnotations(thisAnnotation, animated: true)
			}
		}
		
	}
	
	fileprivate func setUpFetchedResultsController() {
		let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		//fetchedResultsController.delegate = self
		
		fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchResultController.delegate = self as? NSFetchedResultsControllerDelegate
		do {
			try fetchResultController.performFetch()
		} catch {
			fatalError("The fetch could not be performed: \(error.localizedDescription)")
		}
	}
	
	//MARK: Add Pins And Zoom
	//adds the annotation/pin
    func addAnnotation(cllLocation: CLLocationCoordinate2D){
		let annotation = MKPointAnnotation()
		annotation.coordinate = cllLocation
		self.mapView.addAnnotation(annotation)
		self.mapView.showAnnotations(self.mapView.annotations, animated: true)
		let pin = Pin(context: dataController.viewContext)
		pin.latitude = annotation.coordinate.latitude
		pin.longitude = annotation.coordinate.longitude
		pins.append(pin)
		try?dataController.viewContext.save()
		
        print("added Pin")
		
	}
	
	//zooms in where the pin was placed
	
	func zoomToUserDefault(){
		let coordinate = CLLocationCoordinate2D(latitude: userDefault.double(forKey: "lat"), longitude: userDefault.double(forKey: "long"))
		let span = MKCoordinateSpan(latitudeDelta: userDefault.double(forKey: "latDelta"), longitudeDelta: userDefault.double(forKey: "longDelta"))
		let region = MKCoordinateRegion(center: coordinate, span: span)
		DispatchQueue.main.async {
			self.mapView.setRegion(region, animated: true)
		}
	}
	// Where it is longpressed
    @objc func longpressed(press: UIGestureRecognizer){
		if press.state == .began{
            let wherePressed = press.location(in: mapView)
        let onTheMap = mapView.convert(wherePressed, toCoordinateFrom: mapView)
            addAnnotation(cllLocation: onTheMap)
		}
	}
	// MARK: User Defaults
	
	func UserDefaultValues(){
		userDefault.setValue(mapView.centerCoordinate.latitude, forKey: "lat")//Makes set the user default where to zoom in on latitude
		userDefault.setValue(mapView.centerCoordinate.longitude, forKey: "long")//Makes set the user default where to zoom in on longitude
		userDefault.setValue(5.0, forKey: "latDelta")
		userDefault.setValue(5.0, forKey: "longDelta")
	}
	
	
}
//MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate{
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let reusedId = "pin"
		var pinShow = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
		
		if pinShow == nil{
			pinShow = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
			pinShow!.canShowCallout = true
			pinShow?.pinTintColor = UIColor(named: "pinColor")
			pinShow?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		}else{
			pinShow?.annotation = annotation
		}
		return pinShow
	}
	//Makes the pin clickable
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
			
		let imageView = storyboard?.instantiateViewController(identifier: "ImageCollectionView") as? ImageCollectionView
		guard let pinSelected = view.annotation else {
			return
		}
		for pins in pins{
			if pins.latitude == pinSelected.coordinate.latitude && pins.longitude == pinSelected.coordinate.longitude{
				imageView?.dataController = dataController
				imageView?.pin = pins
			}
			present(imageView!, animated: true, completion: nil)
		}
		}
	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		UserDefaultValues()
//		zoomToUserDefault()
	}
	func whatIsEnabled(){
		mapView.isScrollEnabled = true
		mapView.isZoomEnabled = true
		mapView.isPitchEnabled = true
		mapView.isRotateEnabled = true
		mapView.isUserInteractionEnabled = true
	}
	
	
}






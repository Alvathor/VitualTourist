//
//  MainVC.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 15/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MainVC: UIViewController {

    //MARK: - Variables and Outlets
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var bottomAlert: UIView!
    
    var dataController: DataController!    
    var fetchedResultsControllerPin: NSFetchedResultsController<Pin>!
    var longGesture: UILongPressGestureRecognizer!
    let request = Requests()
    var photos: PhotosList!
    var passedCoordinate: CLLocationCoordinate2D!
    var deleteEnable =  false
    
    //MARK: - View and memmory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSegue(withIdentifier: "toOverview", sender: self)
        
        registerAndGesture()
        
        setupFetchedResultsControllerPin { (done) in
            
            if done {
                
               self.updateMap()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        centerMap()
        setupFetchedResultsControllerPin { (_) in}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsControllerPin = nil
    }
    
    //MARK: - Controller Functions
    
    fileprivate func centerMap() {
        
        guard let centerLatitude = UserDefaults.standard.value(forKey: "centerLatitude") as? CLLocationDegrees else { return }
        guard let centerLongitude = UserDefaults.standard.value(forKey: "centerLongitude") as? CLLocationDegrees else { return }
        
        guard let spanLatitude = UserDefaults.standard.value(forKey: "spanLatitude") as? CLLocationDegrees else { return }
        guard let spanLongitude = UserDefaults.standard.value(forKey: "spanLongitude") as? CLLocationDegrees else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let span = MKCoordinateSpan(latitudeDelta: spanLatitude, longitudeDelta: spanLongitude)
        
        let lastRegion = MKCoordinateRegion(center: coordinate, span: span)
    
        myMap.setRegion(lastRegion, animated: true)
        myMap.reloadInputViews()
    
    }
    
    fileprivate func showAlertBottom(_ show: Bool) {
        
        UIView.animate(withDuration: 0.3) {
            if show {
                 self.view.transform = CGAffineTransform(translationX: 0, y: -100)
            } else {
                 self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            
        }
    }
    
    fileprivate func setupFetchedResultsControllerPin(completion: @escaping(Bool) -> ()) {
        
        let fetcheRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        fetcheRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsControllerPin = NSFetchedResultsController(fetchRequest: fetcheRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        
        fetchedResultsControllerPin.delegate = self
        
        do {
            
            try fetchedResultsControllerPin.performFetch()
            completion(true)
            
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    fileprivate func updateMap() {
        
        guard let mypins = fetchedResultsControllerPin.fetchedObjects else { return }
       
        DispatchQueue.main.async {
            
            for pins in mypins {
                
                let coordinate = CLLocationCoordinate2D(latitude: pins.latitude, longitude: pins.longitude)
                let myAnnotation = MKPointAnnotation()
                myAnnotation.title = "Open photos"
                myAnnotation.coordinate = coordinate
                
                self.myMap.addAnnotation(myAnnotation)
                self.myMap.reloadInputViews()
            }
        }
    }
    
    fileprivate func registerAndGesture() {
        
        myMap.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin(longGesture:)))
        longGesture.minimumPressDuration = 0.6
        
        myMap.addGestureRecognizer(longGesture)
    }

    @objc func addPin(longGesture: UIGestureRecognizer) {
        
        if longGesture.state == .began {
          
            let touchPoint = longGesture.location(in: myMap)
            let myCoordinate = myMap.convert(touchPoint, toCoordinateFrom: myMap)
            let location = CLLocation(latitude: myCoordinate.latitude, longitude: myCoordinate.longitude)
            let myAnnotation = MKPointAnnotation()
            let span = MKCoordinateSpan(latitudeDelta: location.altitude, longitudeDelta: location.altitude)
            
            myAnnotation.title = "Open Photos"
            
            myAnnotation.coordinate = myCoordinate
            
            myMap.addAnnotation(myAnnotation)
            
            savePin(location, span)
        }
    }
    
    func removePin(_ coordinate: CLLocationCoordinate2D) {
        
        let myPin = fetchedResultsControllerPin.fetchedObjects
        
        for item in myPin! {
        
            if item.latitude == coordinate.latitude && item.longitude == coordinate.longitude {
                
                dataController.viewContext.delete(item)
            }
        }
        
        try? dataController.viewContext.save()
    }
    
    fileprivate func savePin(_ location: CLLocation, _ span: MKCoordinateSpan) {
        
        let myPin = Pin(context: dataController.viewContext)
        
        myPin.creationDate = Date()
        myPin.latitude = location.coordinate.latitude
        myPin.longitude = location.coordinate.longitude
        myPin.latitudeDelta = span.latitudeDelta
        myPin.longitudeDelta = span.longitudeDelta
        
        try? dataController.viewContext.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? PhotoAlbumViewController else { return }
        destination.dataController = dataController
        destination.coordinate = passedCoordinate
        
        guard let mypins = fetchedResultsControllerPin.fetchedObjects else { return }
        for pin in mypins {
            if pin.latitude == passedCoordinate.latitude && pin.longitude == passedCoordinate.longitude {
                destination.pin = pin
            }
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func infoAction(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "toOverview", sender: self)
    }
    
    @IBAction func deletePin(_ sender: UIBarButtonItem) {
        
        if sender.tag == 0 {
            showAlertBottom(true)
            sender.tag = 1
            deleteEnable = true
        } else {
            showAlertBottom(false)
            sender.tag = 0
            deleteEnable = false
        }
    }
}

//MARK: - FetchedDelegate

extension MainVC : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        myMap.reloadInputViews()
    }
    
}

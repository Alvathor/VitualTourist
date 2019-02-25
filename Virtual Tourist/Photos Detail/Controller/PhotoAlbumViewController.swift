
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 15/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    //MARK: - Variables and Outlets
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var requestToolBar: UIToolbar!
    @IBOutlet weak var removeTollBar: UIToolbar!
    
    var coordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var pin: Pin!
    var listOfUrlPhotos = [URL]()
    var fetchedResultsControllerPhoto: NSFetchedResultsController<Photo>!
    var request = Requests()
    var blockOPerations: [BlockOperation] = []
    let imageCache = NSCache<NSString, UIImage>()
    var imageUrlString: URL?
    var numberofItens = 0
    var listOfData = [Data]()
    var listToRemove = [IndexPath]()
    
    //MARK: - Memmory and view loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView(isRequestTollBar: true)
        
        myCollectionView.register(UINib(nibName: "CollectionViewPhoto", bundle: nil), forCellWithReuseIdentifier: "collectionView")
        
        centerMap()
        
        fetcheResults()
    }
    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation in blockOPerations {
            operation.cancel()
        }
        
        blockOPerations.removeAll(keepingCapacity: false)
        fetchedResultsControllerPhoto = nil
    }
    
    func setupView(isRequestTollBar: Bool) {
        
        if isRequestTollBar {
            
            UIView.animate(withDuration: 0.3) {
                
                self.requestToolBar.transform = CGAffineTransform(translationX: 0, y: 0)
                self.removeTollBar.transform = CGAffineTransform(translationX: 0, y: self.removeTollBar.frame.size.height)
            }
            
        } else {
            
            UIView.animate(withDuration: 0.3) {
                
                self.requestToolBar.transform = CGAffineTransform(translationX: 0, y: self.requestToolBar.frame.size.height)
                self.removeTollBar.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
    //MARK: - FetcheResultsController
    
    fileprivate func setupFetchedResultsControllerPhotos(completion: @escaping() -> ()) {
        
        let fetcheRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "toPin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        fetcheRequest.predicate = predicate
        fetcheRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsControllerPhoto = NSFetchedResultsController(fetchRequest: fetcheRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Photo-\(String(describing: pin.creationDate))")
        fetchedResultsControllerPhoto.delegate = self
        
        do {
            
            try fetchedResultsControllerPhoto.performFetch()
            completion()
            
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Self Functions
    
    fileprivate func centerMap() {        
        
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1500, 1500)
        
        myMap.setRegion(region, animated: true)
        
        let myAnnotation = MKPointAnnotation()
        
        myAnnotation.coordinate = coordinate
        
        myMap.addAnnotation(myAnnotation)
    }
    
    fileprivate func fetcheResults() {
        
        setupFetchedResultsControllerPhotos {
            
            if self.fetchedResultsControllerPhoto.fetchedObjects?.count == 0 {
                
                self.updatePhotos(number: 1, completion: {
                    
                    DispatchQueue.main.async {
                        
                        self.numberofItens = self.listOfUrlPhotos.count
                        self.myCollectionView.reloadData()
                    }
                })
            }
        }
    }
    
    func removePhotos(removeAll: Bool, index: IndexPath?, completion: @escaping() -> ()) {
        
        var album = fetchedResultsControllerPhoto.fetchedObjects
        
        if removeAll {
            
            album?.forEach({ (photo) in

                dataController.viewContext.delete(photo)
            })
            
        } else {

            guard let _index = index else { return }
            guard let obj = album?.remove(at: _index.row) else { return }
            
            dataController.viewContext.delete(obj)
        }
        
        try? dataController.viewContext.save()
        
        completion()
    }
    
    func savePhotos(_ localData: Data) {
        
        let createAlgum = Photo(context: dataController.viewContext)
        createAlgum.creationDate = Date()
        createAlgum.image = localData
        createAlgum.toPin = pin
        
        try? dataController.viewContext.save()
    }
    
    @IBAction func requestSetOfPhotos(_ sender: UIBarButtonItem) {
        
            updatePhotos(number: sender.tag) {
                
                sender.tag += 1
            }
    }
    
    @IBAction func actionRemovePhotos(_ sender: UIBarButtonItem) {
        
        listToRemove.forEach { (indexPath) in
            
            removePhotos(removeAll: false, index: indexPath, completion: {
                
                DispatchQueue.main.async {
                    
                    self.myCollectionView.reloadData()
                    self.listToRemove.removeAll()
                    self.setupView(isRequestTollBar: true)
                }               
            })
        }
    }
}

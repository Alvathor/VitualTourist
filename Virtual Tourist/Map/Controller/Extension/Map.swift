//
//  MainVC.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 15/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation
import MapKit

extension MainVC: MKMapViewDelegate {
    
    //MARK: - Mapkit Protocol Functions
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "centerLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "centerLongitude")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "spanLatitude")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "spanLongitude")
        
        UserDefaults.standard.synchronize()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pin = myMap.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            
            pin.animatesWhenAdded = true
            pin.titleVisibility = .adaptive
            pin.subtitleVisibility = .adaptive
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return pin
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if !deleteEnable {
            guard let pinCoordinate = view.annotation?.coordinate else { return }
            passedCoordinate =  pinCoordinate
            performSegue(withIdentifier: "toPhotoAlbum", sender: self)
        }
       
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if deleteEnable {
            for annotation in myMap.selectedAnnotations {
                myMap.removeAnnotation(annotation)
                removePin(annotation.coordinate)
            }
            
            myMap.reloadInputViews()
        }
    }

}

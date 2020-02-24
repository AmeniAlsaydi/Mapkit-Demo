//
//  ViewController.swift
//  Mapkit-Demo
//
//  Created by Amy Alsaydi on 2/24/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchTextField: UITextField!
    
    private var userTrackingButton: MKUserTrackingButton!

    
    private let locationSession = CoreLocationSession()
    
    private var isShowingNewAnnotations = false
    
    private var annotations = [MKPointAnnotation]() // MKAnnotation is the parent class
 
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self // set this vc as delegate
        mapView.showsUserLocation = true // show user
        
        // configure tracking button
        userTrackingButton = MKUserTrackingButton(frame: CGRect(x: 20, y: 20, width: 40, height: 40))
        mapView.addSubview(userTrackingButton)
        userTrackingButton.mapView = mapView
        
        // add annotations to map view
        mapView.delegate = self
        loadMap()
    }
    
    private func loadMap() {
        let annotations = makeAnnotations()
        mapView.addAnnotations(annotations)
        
    }
    
    private func makeAnnotations() -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for location in Location.getLocations() {
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            annotation.coordinate = location.coordinate
            annotations.append(annotation)
        }
        isShowingNewAnnotations = true
        self.annotations = annotations
        
        return annotations
        
    }
    private func convertPlaceNameToCoordinate(_ placename: String) {
        locationSession.convertPlaceNameToCoordinate(addressString: placename) { (result) in
            switch result {
            case .failure(let error):
                print("geocoding error: \(error)")
            case .success(let coordinate):
                // set map view at given coordinate
                // moves mao to the given coordinate
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1600, longitudinalMeters: 1600) // the region from the cordinate givien
                self.mapView.setRegion(region, animated: true)
                
    
            }
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let searchText = textField.text,
            !searchText.isEmpty else {
                return true 
        }
        convertPlaceNameToCoordinate(searchText)
        
        return true
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // get annotation
        
        guard let annotation = view.annotation else { return }
        
        guard let location = (Location.getLocations().filter { $0.title == annotation.title }).first else { return }
        
        print("\(location.title) was selected ")
        
        guard let detailVC = storyboard?.instantiateViewController(identifier: "LocationDetailViewController", creator: { coder in
            return LocationDetailViewController(coder: coder, location: location)
            
        }) else {
            fatalError("could not downcast to LocationDetailViewController")
        }
        detailVC.modalPresentationStyle = .overCurrentContext
        detailVC.modalTransitionStyle = .crossDissolve
        present(detailVC, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "annotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.glyphImage = UIImage(named: "duck")
            annotationView?.glyphTintColor = .cyan
            annotationView?.markerTintColor = .blue
            annotationView?.glyphText = "AMENI"
            
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isShowingNewAnnotations {
            mapView.showAnnotations(annotations, animated: false)
        }
        isShowingNewAnnotations = false
    }
}

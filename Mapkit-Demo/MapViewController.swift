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
    
    private let locationSession = CoreLocationSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self // set this vc as delegate
        mapView.showsUserLocation = true // show user 
        
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

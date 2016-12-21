//
//  MapViewController.swift
//  TightKnit
//
//  Created by Adam Zarn on 12/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var location: CLLocation! {
        didSet {
            myMapView.centerCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let screenSize = UIScreen.main.bounds
        myMapView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        myMapView.region.span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCoreLocationPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            checkCoreLocationPermission()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("Unauthorized to use location service")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func fabricButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


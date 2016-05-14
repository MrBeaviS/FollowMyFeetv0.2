
//
//  ViewController.swift
//  FollowMyFeet
//
//  Created by Michael Beavis on 7/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentUserLocation: CLLocation?
    var destionationLocation: CLLocation?
    var providedLocation: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.map.showsUserLocation = true
        
        
        //Will access the users location and update when there is a change (Will only work if the user agrees to use location settings
        self.map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        
        //        //Create Long/Lat variables of type CLLocationDegrees
        //        let latitude : CLLocationDegrees = -34.405404
        //        let longitude : CLLocationDegrees = 150.878409
        //
        //        //Delta is difference of latitutudes/longtitudes from one side of screen to another
        //        let latDelta : CLLocationDegrees = 0.01 //0.01 is zoomed in, 0.1 is fairly zoomed out
        //        let longDelta : CLLocationDegrees = 0.01
        //
        //        //combination of 2 deltas, 2 changes between degrees
        //        let span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        //
        //        let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        //
        //        let region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        //
        //        map.setRegion(region, animated: true)
        
        //
        //        //create anotation AKA "Pin"
        //        let annotation = MKPointAnnotation()
        //
        //        //set location, title and subtitle of annotation
        //        annotation.coordinate = location
        //        annotation.title = "UOW"
        //        annotation.subtitle = "AKA Hell!!!"
        //
        //        //add to map
        //        map.addAnnotation(annotation)
        
        //allow user to long press on map
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.action(_:)))
        
        //1 seconds
        uilpgr.minimumPressDuration = 1
        
        map.addGestureRecognizer(uilpgr)
        
    }
    
    //action finction recieves var gestureRecogniser
    func action(gestureRecogniser : UIGestureRecognizer){
        print("gesture Recognised")
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        
        var overlaysToRemove = [MKOverlay]()
        
        // All overlays on the map
        let overlays = self.map.overlays
        
        for overlay in overlays
        {
            if overlay.title! == "route"
            {
                overlaysToRemove.append(overlay)
            }
        }
        
        self.map.removeOverlays(overlaysToRemove)
        
        //location of longpress relative to the map
        let touchPoint = gestureRecogniser.locationInView(self.map)
        
        let newCoordinate : CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        
        let annotation = MKPointAnnotation()
        
        //set location, title and subtitle of annotation
        annotation.coordinate = newCoordinate
        annotation.title = "New Place"
        annotation.subtitle = "Cool...."
        destionationLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        getDirections()
        //add to map
        map.addAnnotation(annotation)
        
        
    }
    
    func getDirections() {
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (currentUserLocation?.coordinate.latitude)!, longitude: (currentUserLocation?.coordinate.longitude)!), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (destionationLocation?.coordinate.latitude)!, longitude: (destionationLocation?.coordinate.longitude)!), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .Any
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler {
            response, error in
            guard let unwrappedResponse = response else { print(error); return }
            
            for route in unwrappedResponse.routes {
                route.polyline.title = "route"
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect,edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 2.0
        return renderer
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        currentUserLocation = locations[0]
        
        //extracts the user lat/long
        let latitude = currentUserLocation!.coordinate.latitude
        let longitude = currentUserLocation!.coordinate.longitude
        
        let latDelta : CLLocationDegrees = 0.025 //0.01 is zoomed in, 0.1 is fairly zoomed out
        let longDelta : CLLocationDegrees = 0.025
        
        //combination of 2 deltas, 2 changes between degrees
        let span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.map.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        if (providedLocation){
            getDirections()
        }else {
            print("NOPE")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
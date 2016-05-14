
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
    var data: dataAccess = dataAccess.sharedInstance
    var locs: [Location] = []
    var providedLocation: Bool = false
    var providedPath: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test " + String(providedLocation))
        // Do any additional setup after loading the view, typically from a nib.
        let overlays = map.overlays
        map.removeOverlays(overlays)
        let annotationsToRemove = map.annotations.filter { $0 !== map.userLocation }
        map.removeAnnotations( annotationsToRemove )
        self.map.showsUserLocation = true
        print("map " + String(locs.capacity))
        if providedPath{
            locs.append(locs[0])
            for i in locs{
                placePins(i)
                //data.testDelete(i)
            }
        }
        
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
        let touchPoint = gestureRecogniser.locationInView(self.map)
        
        let newCoordinate : CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        
        pinCreate(newCoordinate)
        
        
    }
    
    func pinCreate(newCoordinate: CLLocationCoordinate2D){
        var annotationName: String?
        var annotationInfo: String?
        let addLocationAlert = UIAlertController(title:  "Add a new Location",message: "Location Details", preferredStyle: UIAlertControllerStyle.Alert)
        addLocationAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Location Name"
        }
        addLocationAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Location Info"
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
            addLocationAlert.dismissViewControllerAnimated(true, completion: nil)
        }
        let createLocationButton = UIAlertAction(title: "Create Location", style: .Default) { (alert: UIAlertAction!) -> Void in
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            if let text = addLocationAlert.textFields![0].text where !text.isEmpty {
                annotationName = text
            }
            if let text = addLocationAlert.textFields![1].text where !text.isEmpty {
                annotationInfo = text
            }
            annotation.title = annotationName
            annotation.subtitle = annotationInfo
            self.map.addAnnotation(annotation)
            self.data.createLocation(newCoordinate, latDelta: 0.01, longDelta: 0.01, name: annotationName!, info: annotationInfo!)
        }
        let createAndAddButton = UIAlertAction(title: "Create Location And Add To Path", style: .Default) { (alert: UIAlertAction!) -> Void in
        }
        addLocationAlert.addAction(cancelButton)
        addLocationAlert.addAction(createLocationButton)
        addLocationAlert.addAction(createAndAddButton)
        presentViewController(addLocationAlert, animated:true, completion: nil)
        
    }
    
    func placePins(loc: Location){
        let annotation = MKPointAnnotation()
        let latitude: CLLocationDegrees = loc.latitude as! CLLocationDegrees
        let longitude: CLLocationDegrees = loc.longitude as! CLLocationDegrees
        //set location, title and subtitle of annotation
        let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.coordinate = location
        annotation.title = loc.name
        annotation.subtitle = loc.info
        map.addAnnotation(annotation)
    }
    
    func getPathDirections() {
        
        let request = MKDirectionsRequest()
        for i in 0..<locs.count-1 {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[i].latitude!), longitude: Double(locs[i].longitude!)), addressDictionary: nil))
            
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[i+1].latitude!), longitude: Double(locs[i+1].longitude!)), addressDictionary: nil))
            
            
            request.requestsAlternateRoutes = true
            request.transportType = .Any
            let directions = MKDirections(request: request)
            
            directions.calculateDirectionsWithCompletionHandler {
                response, error in
                guard let unwrappedResponse = response else { print(error); return }
                
                unwrappedResponse.routes[0].polyline.title = "route"
                self.map.addOverlay(unwrappedResponse.routes[0].polyline)
                self.map.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect,edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
                
            }
        }
    }
    
    func getDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (currentUserLocation?.coordinate.latitude)!, longitude: (currentUserLocation?.coordinate.longitude)!), addressDictionary: nil))
        
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[0].latitude!), longitude: Double(locs[0].longitude!)), addressDictionary: nil))
        
        request.requestsAlternateRoutes = true
        request.transportType = .Walking
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler {
            response, error in
            guard let unwrappedResponse = response else { print(error); return }
            
            unwrappedResponse.routes[0].polyline.title = "route"
            self.map.addOverlay(unwrappedResponse.routes[0].polyline)
            self.map.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect,edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            
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
        if providedLocation {
            print("location")
            getDirections()
        }
        if providedPath {
            print("path")
            getPathDirections()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
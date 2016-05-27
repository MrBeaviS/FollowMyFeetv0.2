
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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let locationManager = CLLocationManager()
    var currentUserLocation: CLLocation?
    var destionationLocation: CLLocation?
    var data: dataAccess = dataAccess.sharedInstance
    var locs: [Location] = []
    
    var shortestPathArray = Array<MKRoute>()
    var providedLocation: Bool = false
    var providedPath: Bool = false
    
    //searchBar
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //search Bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
//        tableView.tableHeaderView = searchController.searchBar
        
        self.map.showsUserLocation = true
        clearMap()
        loadAnnotations()
        
        //Will access the users location and update when there is a change (Will only work if the user agrees to use location settings


        self.map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //allow user to long press on map
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.action(_:)))
        
        //1 seconds
        uilpgr.minimumPressDuration = 1
        
        map.addGestureRecognizer(uilpgr)
        
    }
    
    func searchPOI(searchLoc : String?) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchLoc
        request.region = map.region
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, error in
            guard let response = response else {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                return
            }
            
            for mItems in response.mapItems {

                let annotation = MKPointAnnotation()
                
                annotation.title = mItems.name
//                annotation.subtitle = mItems.phoneNumber
                let latitude : CLLocationDegrees = (mItems.placemark.location?.coordinate.latitude)!
                let longitude : CLLocationDegrees = (mItems.placemark.location?.coordinate.longitude)!
                let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                annotation.coordinate = location
                self.map.addAnnotation(annotation)
                
            }
        }
    }
    
    //action finction recieves var gestureRecogniser
    func action(gestureRecogniser : UIGestureRecognizer){
        let touchPoint = gestureRecogniser.locationInView(self.map)
        let newCoordinate : CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        pinCreate(newCoordinate)
    }
    
    func clearMap(){
        let overlays = map.overlays
        map.removeOverlays(overlays)
        let annotationsToRemove = map.annotations.filter { $0 !== map.userLocation }
        map.removeAnnotations( annotationsToRemove )
    }
    
    func loadAnnotations(){
       
            for i in 0..<locs.count{
                placePins(locs[i])
            }    
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
        addLocationAlert.addAction(createAndAddButton(addLocationAlert, newCoordinate: newCoordinate))
        addLocationAlert.addAction(cancelButton)
        addLocationAlert.addAction(createLocationButton)
        presentViewController(addLocationAlert, animated:true, completion: nil)
    }
    
    
    func createAndAddButton(addLocationAlert: UIAlertController, newCoordinate: CLLocationCoordinate2D) -> UIAlertAction {
        var annotationName: String?
        var annotationInfo: String?
        let button = UIAlertAction(title: "Create Location And Add To Path", style: .Default) { (alert: UIAlertAction!) -> Void in
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
            let temp = self.data.createLocation(newCoordinate, latDelta: 0.01, longDelta: 0.01, name: annotationName!, info: annotationInfo!)
            self.locs.append(temp)
            self.clearMap()
            self.loadAnnotations()
            self.getDirections()
            self.getPathDirections()
        }
        return button
        
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
        print("getting path directions")
        var paths = Array<Array<MKRoute>>()
        let rows = locs.count
        let columns = rows
        for _ in 0..<columns {
            paths.append(Array(count:rows,repeatedValue: MKRoute()))
        }
        for i in 0...locs.count-1{
            for x in  0...locs.count-1{
                let request = MKDirectionsRequest()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[i].latitude!), longitude: Double(locs[i].longitude!)), addressDictionary: nil))
                
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[x].latitude!), longitude: Double(locs[x].longitude!)), addressDictionary: nil))
                request.requestsAlternateRoutes = true
                request.transportType = .Walking
                let directions = MKDirections(request: request)
                
                directions.calculateDirectionsWithCompletionHandler {
                    response, error in
                    guard let unwrappedResponse = response else { print(error); return }
                    paths[i][x] = unwrappedResponse.routes[0]
                    if i == rows-1 && x == rows-1 {
                        self.shortestPathArray = self.determineOptimalPath(paths)
                        print( self.shortestPathArray.count)
                        for path in self.shortestPathArray{
                            self.drawPaths(path)
                        }
                    }
                }
            }
        }
    }
    
    func determineOptimalPath(distances:Array<Array<MKRoute>>) -> Array<MKRoute>{
        print("getting optimal path")
        var tempRoute = MKRoute()
        var visted: [Bool] = []
        for _ in 0..<locs.count{
            visted.append(false)
        }
        var temp:Int = 0
        var shortestPath: Double = 999999999
        var previousNode: Int = 0
        while shortestPathArray.count != locs.count{
            for x in  0..<locs.count{
                if distances[previousNode][x].distance < shortestPath && distances[previousNode][x].distance != 0 {
                    if !visted[x] && previousNode != x{
                        shortestPath = distances[previousNode][x].distance
                        tempRoute = distances[previousNode][x]
                        temp = x
                    }
                }
            }
            visted[previousNode] = true
            previousNode = temp
            shortestPathArray.append(tempRoute)
            shortestPath = 999999999
        }
        shortestPathArray.append(distances[previousNode][0])
        return shortestPathArray
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
            self.drawPaths(unwrappedResponse.routes[0])
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        //renderer.strokeColor = getRandomColor()
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 2.0
        return renderer
    }
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func drawPaths(path: MKRoute){
        path.polyline.title = "route"
        self.map.addOverlay(path.polyline)
        self.map.setVisibleMapRect(path.polyline.boundingMapRect,edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
        
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
        
        
        if providedLocation{
            print("location")
            getDirections()
        }else if providedPath {
            print("path")
            print(locs.count)
            getDirections()
            getPathDirections()
            providedPath=false
        }
        
//        searchPOI("Coffee")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
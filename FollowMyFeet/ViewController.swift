
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
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //allows user to save a path to core data
    @IBAction func saveButtonAction(sender: UIButton!) {
        if locs.count > 2{
            var pathName: String?
            var pathInfo: String?
            let addPathAlert = UIAlertController(title:  "Add a Path",message: "Path Details", preferredStyle: UIAlertControllerStyle.Alert)
            addPathAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "Enter Path Name"
            }
            addPathAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "Enter Path Info"
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .Default) { (alert: UIAlertAction!) -> Void in
                addPathAlert.dismissViewControllerAnimated(true, completion: nil)
            }
            let createPathButton = UIAlertAction(title: "Create Path", style: .Default) { (alert: UIAlertAction!) -> Void in
                if let text = addPathAlert.textFields![0].text where !text.isEmpty {
                    pathName = text
                }
                if let text = addPathAlert.textFields![1].text where !text.isEmpty {
                    pathInfo = text
                }
                self.data.createPath(pathName!, info: pathInfo!, loc: self.locs)
            }
            addPathAlert.addAction(cancelButton)
            addPathAlert.addAction(createPathButton)
            presentViewController(addPathAlert, animated:true, completion: nil)
        }
    }
    
    
    let locationManager = CLLocationManager()
    var currentUserLocation: CLLocation?
    var destionationLocation: CLLocation?
    var data: dataAccess = dataAccess.sharedInstance
    var locs: [Location] = []
    let searchRadius: CLLocationDistance = 2000
    var shortestPathArray = Array<MKRoute>()
    var providedLocation: Bool = false
    var providedPath: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.map.showsUserLocation = true
        locationButton.layer.cornerRadius = 0.5 * locationButton.bounds.size.width
        locationButton.layer.borderWidth = 0.8
        locationButton.layer.borderColor = UIColor.blackColor().CGColor
        saveButton.layer.cornerRadius = 0.5 * saveButton.bounds.size.width
        saveButton.layer.borderWidth = 0.8
        saveButton.layer.borderColor = UIColor.blackColor().CGColor
        clearMap()
        loadAnnotations()
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
    
    //action finction recieves var gestureRecogniser
    func action(gestureRecogniser : UIGestureRecognizer){
        let touchPoint = gestureRecogniser.locationInView(self.map)
        let newCoordinate : CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        pinCreate(newCoordinate)
    }
    
    //function triggered when a search is completed
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.clearMap()
        self.view.endEditing(true)
        searchInMap(searchBar.text!)
    }
    
    //does a search request for pois
    func searchInMap(searchQuery: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchQuery
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: currentUserLocation!.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler {
            response, error in
            for item in response!.mapItems {
                self.placePOIPins(item)
            }
        }     
    }
    
    //defines the line style that is displayed as a path
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = getRandomColor()
        //renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 2.0
        return renderer
    }
    
    
    //creates a custom annotation view allowing the use of a button
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("AnnotationView Id")
        
        if view == nil{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView Id")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.ContactAdd)
        if annotation is MKUserLocation {
            return nil
        }else {
            return view
        }
    }
    
    //the function that controlls the repsonviness of the button in each annoation view
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.ContactAdd {
            var saveLoc: Bool = true
            let currentPin = view.annotation
            for location in locs {
                if location.latitude == currentPin?.coordinate.latitude {
                    if location.longitude == currentPin?.coordinate.longitude {
                        saveLoc = false
                    }
                }
            }
            if saveLoc {
                let temp = self.data.createLocation((currentPin?.coordinate)!, latDelta: 0.01, longDelta: 0.01, name: ((currentPin?.title)!)!, info: (currentPin?.subtitle!)!)
                self.locs.append(temp)
            }
            
        }
    }
    
    //handles the location ablities
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
        //TO DO: fix the bug if only two locations selected.
        if locs.count != 0 {
            if providedLocation{
                getDirections(latitude, longitude: longitude)
            }else if providedPath {
                getOptimalFromUserLoc(latitude, longitude: longitude)
                if locs.count > 2 {
                    getPathDirections()
                }else {
                    getDirections(locs[1].latitude as! CLLocationDegrees, longitude: locs[1].longitude as! CLLocationDegrees)
                }
                providedPath=false
            }
        }
    }
    
    
    //clears the maps of annotations and paths
    func clearMap(){
        let overlays = map.overlays
        map.removeOverlays(overlays)
        let annotationsToRemove = map.annotations.filter { $0 !== map.userLocation }
        map.removeAnnotations( annotationsToRemove )
    }
    
    
    
    //creates a new annotation
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
            let temp = self.data.createLocation(newCoordinate, latDelta: 0.01, longDelta: 0.01, name: annotationName!, info: annotationInfo!)
            self.locs.append(temp)
        }
        addLocationAlert.addAction(cancelButton)
        addLocationAlert.addAction(createLocationButton)
        presentViewController(addLocationAlert, animated:true, completion: nil)
    }
    
    
    
    //loads the list of annotations
    func loadAnnotations(){
        for i in 0..<locs.count{
            placeUserPins(locs[i])
        }
    }
    
    //places the poi pins (could possibly reduce this and placeUserPins in to one but havent had time)
    func placePOIPins(data: MKMapItem){
        let annotation = MKPointAnnotation()
        let latitude: CLLocationDegrees = data.placemark.location!.coordinate.latitude
        let longitude: CLLocationDegrees = data.placemark.location!.coordinate.longitude
        //set location, title and subtitle of annotation
        let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.coordinate = location
        annotation.title = data.name
        annotation.subtitle = data.phoneNumber
        map.addAnnotation(annotation)
    }
    
    //places the individual annotation pins at tehre location
    func placeUserPins(loc: Location){
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
    
    //gets the path for all the current clocations
    //paths are limited by MapKit due to the number of requets can be made quickly the limit
    //at the moment is 8 locations
    func getPathDirections() {
        print(locs.count)
        var paths = Array<Array<MKRoute>>()
        let rows = locs.count
        let columns = rows
        for _ in 0..<columns {
            paths.append(Array(count:rows,repeatedValue: MKRoute()))
        }
        for i in 0..<locs.count-1{
            for x in  1..<locs.count{
                if x >= i {
                    let request = MKDirectionsRequest()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[i].latitude!), longitude: Double(locs[i].longitude!)), addressDictionary: nil))
                    
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[x].latitude!), longitude: Double(locs[x].longitude!)), addressDictionary: nil))
                    request.transportType = .Walking
                    let directions = MKDirections(request: request)
                    directions.calculateDirectionsWithCompletionHandler {
                        response, error in
                        guard let unwrappedResponse = response else { print(error); return }
                        paths[i][x] = unwrappedResponse.routes[0]
                        paths[x][i] = unwrappedResponse.routes[0]
                        if i == rows-2 && x == rows-1 {
                            self.shortestPathArray = self.determineOptimalPath(paths)
                            for path in self.shortestPathArray{
                                self.drawPaths(path)
                                
                            }
                            self.zoomToFitMapAnnotations()
                        }
                    }
                }
            }
        }
    }
    
    //determines the most optimal path between all the locations
    func determineOptimalPath(distances:Array<Array<MKRoute>>) -> Array<MKRoute>{
        var tempRoute = MKRoute()
        var visted: [Bool] = []
        for _ in 0...locs.count{
            visted.append(false)
        }
        var temp:Int = 0
        var shortestPath: Double = Double.infinity
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
            shortestPath = Double.infinity
        }
        shortestPathArray.append(distances[previousNode][0])
        return shortestPathArray
    }
    
    //a function that when a path is being created determines which is the closest location from the user
    func getOptimalFromUserLoc(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        var path: MKRoute?
        for i in 0..<locs.count-1{
            let request = MKDirectionsRequest()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (latitude), longitude: (longitude)), addressDictionary: nil))
            
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(locs[i].latitude!), longitude: Double(locs[i].longitude!)), addressDictionary: nil))
            
            request.requestsAlternateRoutes = true
            request.transportType = .Walking
            let directions = MKDirections(request: request)
            
            directions.calculateDirectionsWithCompletionHandler {
                response, error in
                guard let unwrappedResponse = response else { print(error); return }
                if path == nil{ path = unwrappedResponse.routes[0] }
                if unwrappedResponse.routes[0].distance < path?.distance{
                    path = unwrappedResponse.routes[0]
                }
                if i == self.locs.count-2 {self.drawPaths(path!)}
                
            }
        }
        
    }
    
    //get the directions from the current users location to the first location
    func getDirections(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (latitude), longitude: (longitude)), addressDictionary: nil))
        
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
    
    
    
    //generates a random colour
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    //draws the individual paths on the map
    func drawPaths(path: MKRoute){
        path.polyline.title = "route"
        self.map.addOverlay(path.polyline)
        
    }
    
//    due to how mapkit handles line drawing this function determines a bounding box that 
//    includes all annotations then zooms to ensure they can all be seen
    func zoomToFitMapAnnotations() {
        let aMapView: MKMapView = self.map
        if aMapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in self.map.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = aMapView.regionThatFits(region)
        self.map.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
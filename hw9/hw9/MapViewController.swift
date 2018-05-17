//
//  MapViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/14/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import Alamofire_SwiftyJSON

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var fromLocation: UITextField!
    @IBOutlet weak var travelMode: UISegmentedControl!
    var origin:CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    //Stop Editing on Return Key Tap
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fromLocation.resignFirstResponder()
        return false
    }
    func initMap(){
        mapView.clear()
        let detailCtr = self.tabBarController as! DetailViewController
        // create map
        mapView.camera = GMSCameraPosition.camera(withLatitude: detailCtr.detail.lat, longitude: detailCtr.detail.lon, zoom: 12.0)
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: detailCtr.detail.lat, longitude: detailCtr.detail.lon)
        marker.map = mapView
    }
    @IBAction func touchFrom(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func chengMode(_ sender: Any) {
        if (fromLocation.text?.trimmingCharacters(in:.whitespaces).isEmpty)! == false{
            showRoute(mode:travelMode.titleForSegment(at: travelMode.selectedSegmentIndex)!)
        }
        else{
            initMap()
        }
    }
    func showRoute(mode:String){
        let detailCtr = self.tabBarController as! DetailViewController
        let destCoord = "\(detailCtr.detail.lat!),\(detailCtr.detail.lon!)"
        let originCoord = "\(origin.latitude),\(origin.longitude)"
        let url = "http://571hw9backend.us-east-2.elasticbeanstalk.com/ajax/search/result/direction"
        let parameters:Dictionary<String,String> = ["origin":originCoord,"destination":destCoord,"mode":mode.lowercased()]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseSwiftyJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                if response.result.value != nil{
                    self.mapView.clear()
                    let swiftJson = response.result.value
                    //draw route
                    let steps = swiftJson!["routes"][0]["legs"][0]["steps"]
                    for i in 0..<steps.count{
                        let points = steps[i]["polyline"]["points"].string
                        let path = GMSPath.init(fromEncodedPath: points!)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 3
                        polyline.map = self.mapView
                    }
                    //add marker for origin and destination
                    let detailCtr = self.tabBarController as! DetailViewController
                    let originMarker = GMSMarker()
                    originMarker.position = CLLocationCoordinate2D(latitude: (self.origin?.latitude)!, longitude: (self.origin?.longitude)!)
                    originMarker.map = self.mapView
                    let destMarker = GMSMarker()
                    destMarker.position = CLLocationCoordinate2D(latitude: detailCtr.detail.lat, longitude: detailCtr.detail.lon)
                    destMarker.map = self.mapView
                    //set map area
                    let bounds = swiftJson!["routes"][0]["bounds"]
                    let northeast = CLLocationCoordinate2D(latitude:bounds["northeast"]["lat"].double!, longitude:bounds["northeast"]["lng"].double!)
                    let southwest = CLLocationCoordinate2D(latitude:bounds["southwest"]["lat"].double!, longitude:bounds["southwest"]["lng"].double!)
                    let mapBound = GMSCoordinateBounds(coordinate: northeast,coordinate: southwest)
                    self.mapView!.animate(with: GMSCameraUpdate.fit(mapBound, withPadding: 30.0))
                }
                else{
                    print("error")
                }
        }
    }
}
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromLocation.text = place.formattedAddress
        origin = place.coordinate
        showRoute(mode:travelMode.titleForSegment(at: travelMode.selectedSegmentIndex)!)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

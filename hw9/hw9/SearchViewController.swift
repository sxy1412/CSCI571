//
//  SearchViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/13/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import EasyToast
import McPicker
import GooglePlaces
import CoreLocation

class SearchViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var inputKeyword: UITextField!
    @IBOutlet weak var inputCategory: McTextField!
    @IBOutlet weak var inputDistance: UITextField!
    @IBOutlet weak var inputLocation: UITextField!
    
    var emptyKeyword:Bool! = true
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D? = nil
    var selectedLocation:CLLocationCoordinate2D? = nil
    let categories:[[String]] = [["Default","Airport","Aquarium","Art Gallery","Bakery","Bar","Beauty Salon","Bowling Alley","Bus Station","Cafe","Campground","Car Rental","Casino","Lodging","Movie Theater","Museum","Night Club","Park","Parking","Resturant","Shopping Mall","Stadium","Subway Station","Taxi Stand","Train Station","Transit Station","Travel Agency","Zoo"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        inputKeyword.delegate = self
        inputDistance.delegate = self
        inputLocation.delegate = self
        inputCategory.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //hide keyboard when clicks outside of the keyboard area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == inputCategory {
            return false; //do not show keyboard nor cursor
        }
        return true
    }
    //Stop Editing on Return Key Tap
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputKeyword.resignFirstResponder()
        inputLocation.resignFirstResponder()
        inputDistance.resignFirstResponder()
        return false
    }
    
    @IBAction func changeKeyword(_ sender: Any) {
        let keyword:String? = inputKeyword.text
        if (keyword?.trimmingCharacters(in:.whitespaces).isEmpty)!{
            emptyKeyword = true
        }
        else{
            emptyKeyword = false
        }
    }
    @IBAction func showCategoryPicker(_ sender: McTextField) {
        inputCategory.resignFirstResponder()
        McPicker.show(data: categories) {  [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.inputCategory.text = name
            }
        }
    }
    
    @IBAction func touchFrom(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func touchClear(_ sender: Any) {
        inputKeyword.text = ""
        inputCategory.text = "Default"
        inputDistance.text = ""
        inputLocation.text = "Your location"
        emptyKeyword = true
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if emptyKeyword{
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: 1, dismissOnTap: true)
            return false
        }
        else{
            return true
        }
    }
    //Pass data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! SearchResultViewController
        var location = currentLocation
        if inputLocation.text != "Your location"{
            location = selectedLocation
        }
        let loc = String(location!.latitude)+","+String(location!.longitude)
        let category = inputCategory.text?.replacingOccurrences(of: " ", with: "_").lowercased()
        let keyword = inputKeyword.text
        var distance = "1609"
        if inputDistance.text != ""{
            distance = String(Double(inputDistance.text!)!*1609)
        }
        dest.receivedData = ["keyword":keyword,"type":category,"radius":distance,"location":loc] as! Dictionary<String, String>
    }
}
extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        inputLocation.text = place.formattedAddress
        selectedLocation = place.coordinate
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

extension SearchViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = (locations.last?.coordinate)!
    }
}

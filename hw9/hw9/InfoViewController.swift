//
//  InfoViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/14/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner
import Cosmos

class InfoViewController: UIViewController {
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var priceLevelView: UIView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var googlePageView: UIView!
    @IBOutlet weak var addressText: UITextView!
    @IBOutlet weak var phoneText: UITextView!
    @IBOutlet weak var priceText: UITextView!
    @IBOutlet weak var ratingCosmosView: CosmosView!
    @IBOutlet weak var websiteText: UITextView!
    @IBOutlet weak var googlePageText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("info view")
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //get all data including photo reference and reviews
    func requestData(){
        SwiftSpinner.show("Searching Details......")
        let detailCtr = self.tabBarController as! DetailViewController
        let placeID = detailCtr.receiveId!
        let parameters:Dictionary<String,String> = ["placeid":placeID]
        let url = "http://571hw9backend.us-east-2.elasticbeanstalk.com/ajax/search/result/detail"
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseSwiftyJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                if response.result.value != nil{
                    let swiftJson = response.result.value
                    let result = swiftJson!["result"]
                    detailCtr.detail = detailPlace(name: result["name"].string, id: placeID,icon:result["icon"].string, address: result["formatted_address"].string, lat:result["geometry"]["location"]["lat"].double, lon:result["geometry"]["location"]["lng"].double, priceLevel: nil, phoneNumber: nil, rating: nil, website: nil, googlePage: nil, photosRef:[], reviews:[])
                    self.addressText.text = detailCtr.detail.address
                    if result["international_phone_number"].exists(){
                        detailCtr.detail.phoneNumber = result["international_phone_number"].string
                        self.phoneText.text = detailCtr.detail.phoneNumber
                    }
                    else{
                        self.phoneText.text = ""
                        self.phoneNumberView.frame.size.height = 0
                    }
                    if result["price_level"].exists(){
                        detailCtr.detail.priceLevel = result["price_level"].int
                        var price:String = ""
                        for i in 0..<detailCtr.detail.priceLevel!{
                            price += "$"
                        }
                        self.priceText.text = price
                    }
                    else{
                        self.priceText.text = ""
                        self.priceLevelView.frame.size.height = 0
                    }
                    if result["rating"].exists(){
                        detailCtr.detail.rating = result["rating"].double
                        self.ratingCosmosView.rating = detailCtr.detail.rating!
                    }
                    else{
                        self.ratingCosmosView.rating = 0
                        self.ratingView.frame.size.height = 0
                        self.ratingCosmosView.frame.size.height = 0
                    }
                    if result["website"].exists(){
                        detailCtr.detail.website = result["website"].string
                        self.websiteText.text = detailCtr.detail.website
                    }
                    else{
                        self.websiteText.text = ""
                    }
                    if result["url"].exists(){
                        detailCtr.detail.googlePage = result["url"].string
                        self.googlePageText.text = detailCtr.detail.googlePage
                    }
                    else{
                        self.googlePageText.text = ""
                        self.googlePageView.frame.size.height = 0
                    }
                    if result["photos"].exists(){
                        for i in 0..<result["photos"].count{
                            detailCtr.detail.photosRef?.append(result["photos"][i]["photo_reference"].string!)
                        }
                    }
                    if result["reviews"].exists(){
                        for i in 0..<result["reviews"].count{
                            var review = ReviewObj(name: result["reviews"][i]["author_name"].string!, photoURL: result["reviews"][i]["profile_photo_url"].string!, reviewURL:result["reviews"][i]["author_url"].string!,rating: result["reviews"][i]["rating"].double!, text: result["reviews"][i]["text"].string, time: result["reviews"][i]["time"].double!)
                            detailCtr.detail.reviews.append(review)
                        }
                    }
                }
                else{
                    self.view.showToast("No Record.", position: .bottom, popTime: 1, dismissOnTap: true)
                }
                print("request of place detail finished")
                self.adjustLayout()
                SwiftSpinner.hide()
        }
    }
    func adjustLayout(){
        self.addressText.sizeToFit()
        self.addressView.sizeToFit()
        if self.googlePageText.text == ""{
            self.googlePageView.frame.size.height = 0
            self.googlePageText.frame.size.height = 0
        }
        else{
            self.googlePageText.sizeToFit()
            self.googlePageView.sizeToFit()
        }
        if self.websiteText.text == ""{
            self.websiteView.frame.size.height = 0
            self.websiteText.frame.size.height = 0
        }
        else{
            self.websiteText.sizeToFit()
            self.websiteView.sizeToFit()
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.phoneNumberView.frame = CGRect(origin:CGPoint(x:self.addressView.frame.origin.x, y:self.addressView.frame.origin.y + self.addressText.frame.size.height), size: CGSize(width:self.phoneNumberView.frame.size.width, height:self.phoneNumberView.frame.size.height))
            self.priceLevelView.frame = CGRect(origin:CGPoint(x:self.phoneNumberView.frame.origin.x, y:self.phoneNumberView.frame.origin.y + self.phoneNumberView.frame.size.height), size: CGSize(width:self.priceLevelView.frame.size.width, height:self.priceLevelView.frame.size.height))
            self.ratingView.frame = CGRect(origin:CGPoint(x:self.priceLevelView.frame.origin.x, y:self.priceLevelView.frame.origin.y + self.priceLevelView.frame.size.height), size: CGSize(width:self.ratingView.frame.size.width, height:self.ratingView.frame.size.height))
            self.websiteView.frame = CGRect(origin:CGPoint(x:self.ratingView.frame.origin.x, y:self.ratingView.frame.origin.y + self.ratingView.frame.size.height), size: CGSize(width:self.websiteView.frame.size.width, height:self.websiteView.frame.size.height))
            self.googlePageView.frame = CGRect(origin:CGPoint(x:self.websiteView.frame.origin.x, y:self.websiteView.frame.origin.y + self.websiteText.frame.size.height), size: CGSize(width:self.googlePageView.frame.size.width, height:self.googlePageView.frame.size.height))
        })
    }


}

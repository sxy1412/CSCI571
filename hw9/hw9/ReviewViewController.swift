//
//  ReviewViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/14/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner

class ReviewViewController: UIViewController,UITableViewDataSource,UITableViewDelegate  {
    @IBOutlet weak var reviewSource: UISegmentedControl!
    @IBOutlet weak var reviewTable: UITableView!
    @IBOutlet weak var reviewSortBy: UISegmentedControl!
    @IBOutlet weak var reviewOrder: UISegmentedControl!
    var order:[Int] = []
    var heightOfCell:[CGFloat] = []
    var reviews:[ReviewObj] = []
    var yelpReviews:[ReviewObj] = []
    var yelpIsRequested:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let detailCtr = self.tabBarController as! DetailViewController
        reviews = detailCtr.detail.reviews
        sortKey(array: getOrderKey(key:reviewSortBy.selectedSegmentIndex), order: reviewOrder.selectedSegmentIndex)
        reviewTable.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func changeSource(_ sender: Any) {
        let detailCtr = self.tabBarController as! DetailViewController
        switch reviewSource.selectedSegmentIndex
        {
        case 0://Reviews from Google
            reviews = detailCtr.detail.reviews
            sortKey(array: getOrderKey(key:reviewSortBy.selectedSegmentIndex), order: reviewOrder.selectedSegmentIndex)
            reviewTable.reloadData()
            break
        case 1://Reviews from Yelp
            if yelpIsRequested {
                reviews = yelpReviews
                sortKey(array: getOrderKey(key:reviewSortBy.selectedSegmentIndex), order: reviewOrder.selectedSegmentIndex)
                reviewTable.reloadData()
            }
            else{
                yelpIsRequested = true
                SwiftSpinner.show("Loading Yelp reviews...")
                let addressComponents = getAddressComponents(string: detailCtr.detail.address)
                let parameters = ["city":addressComponents[1],"state":addressComponents[0],"name":detailCtr.detail.name,"address1":addressComponents[2],"address2":addressComponents[3]] as! Dictionary<String,String>
                let url = "http://cs571-nodejs-env.us-east-2.elasticbeanstalk.com/ajax/search/yelp"
                Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
                    .responseSwiftyJSON { response in
                        print("Request: \(String(describing: response.request))")   // original url request
                        print("Response: \(String(describing: response.response))") // http url response
                        let swiftJson = response.result.value!
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        for i in 0..<swiftJson.count{
                            let name:String! = swiftJson[i]["user"]["name"].string
                            let photoURL:String! = swiftJson[i]["user"]["image_url"].string
                            let rating: Double! = swiftJson[i]["rating"].double
                            let text:String? = swiftJson[i]["text"].string
                            let date = dateFormatter.date(from: swiftJson[i]["time_created"].string!)
                            let time:Double! = date?.timeIntervalSince1970
                            let url:String! = swiftJson[i]["url"].string
                            let reviewObj = ReviewObj(name: name, photoURL: photoURL, reviewURL:url, rating: rating, text: text, time: time)
                            self.yelpReviews.append(reviewObj)
                        }
                        self.reviews = self.yelpReviews
                        self.sortKey(array: self.getOrderKey(key:self.reviewSortBy.selectedSegmentIndex), order: self.reviewOrder.selectedSegmentIndex)
                        self.reviewTable.reloadData()
                        SwiftSpinner.hide()
                }
            }
            break
        default:
            break
        }
    }
    @IBAction func changeSortKey(_ sender: Any) {
        let array = getOrderKey(key:reviewSortBy.selectedSegmentIndex)
        sortKey(array: array, order: reviewOrder.selectedSegmentIndex)
        reviewTable.reloadData()
        if reviewSortBy.selectedSegmentIndex != 0{
            reviewOrder.isEnabled = true
        }
        else{
            reviewOrder.isEnabled = false
        }
    }
    @IBAction func changeSortOrder(_ sender: Any) {
        self.order = order.reversed()
        reviewTable.reloadData()
    }
    func getOrderKey(key:Int)->[Double]{
        var keyArray:[Double] = []
        switch key
        {
        case 0://sorted by default
            break;
        case 1://sorted by rating
            for i in 0..<reviews.count{
                keyArray.append(reviews[i].rating)
            }
            break;
        case 2://sorted by date
            for i in 0..<reviews.count{
                keyArray.append(reviews[i].time)
            }
            break;
        default:
            break;
        }
        return keyArray
    }
    func getAddressComponents(string:String)->[String]{//0:state 1:city 2:address2 3:address1
        var address = string.split(separator: ",")
        var address_array:[String] = []
        var temp = address[address.count-2].split(separator: " ")
        address_array.append(String(temp[0]))
        address_array.append(String(address[address.count-3]));
        address_array.append(address[address.count-3]+","+address[address.count-2])
        if(address.count>3){
            var address1 = "";
            for i in 0..<(address.count-3){
                address1 += address[i]+",";
            }
            let index = address1.index(address1.endIndex, offsetBy: -1)
            address_array.append(String(address1[..<index]));
        }
        else{
            address_array.append("none");
        }
        return address_array;
    }
    func sortKey(array original:[Double],order:Int){
        self.order = []
        var originalArray = original
        if original != []{
            var array = original
            array.sort()
            var index:[Int] = []
            for i in 0..<array.count{
                let loc = originalArray.index(of: array[i])
                index.append(loc!)
                originalArray[loc!] = -1
            }
            if order == 0 {//Ascending
                self.order = index
            }
            else{//Descending
                self.order = index.reversed()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviews.count == 0 {
            tableView.isHidden = true
        }
        else{
            tableView.isHidden = false
        }
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reviewTable.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        let index:Int!
        if self.order == []{
            index = indexPath.row         }
        else{
            index = self.order[indexPath.row]
        }
        cell.review.text = reviews[index].text
        cell.star.rating = reviews[index].rating
        cell.userName.text = reviews[index].name
        if let urlx =  reviews[index].photoURL {
            let url =  URL(string:urlx)
            if let data = NSData(contentsOf: url!) {
                cell.userImage.image = UIImage(data: data as Data)
            }
        }
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.clipsToBounds = true
        let time = Date(timeIntervalSince1970: reviews[index].time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.reviewDate.text = dateFormatter.string(from:time)
        cell.review.sizeToFit()
        cell.review.textContainer.maximumNumberOfLines = 4
        cell.review.textContainer.lineBreakMode = .byTruncatingTail
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userURL = URL(string: reviews[indexPath.row].reviewURL)
        UIApplication.shared.open(userURL!)
    }

}

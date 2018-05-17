//
//  SearchResultViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/12/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner
import CoreData

struct PageRecordStruct {
    var names:[String]
    var ids:[String]
    var addresses:[String]
    var icons:[String]
    var nextToken:String
}

class SearchResultViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var prevBtn: UIBarButtonItem!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    @IBOutlet weak var tip: UILabel!
    var pageRecords:[PageRecordStruct]=[]
    var receivedData:Dictionary<String,String> = [:]
    var names:[String] = []
    var ids:[String] = []
    var addresses:[String] = []
    var icons:[String] = []
    var selectedTableRowNum:Int = 0
    var nextToken:String = ""
    var pageNumber:Int = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove tittle for backbarbutton
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        context = appDelegate.persistentContainer.viewContext
        SwiftSpinner.show("Searching...")
        if receivedData["keyword"] != nil{
            let parameters = receivedData
            let url = "http://cs571-nodejs-env.us-east-2.elasticbeanstalk.com/ajax/search/result"
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
                .responseSwiftyJSON { response in
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    if response.result.value != nil{
                        let swiftJson = response.result.value
                        if swiftJson!["next_page_token"].exists(){
                            self.nextToken = swiftJson!["next_page_token"].string!
                        }
                        else{
                            self.nextToken  = ""
                            self.nextBtn.isEnabled = false
                        }
                        let results = swiftJson!["results"]
                        if results.count == 0{
                            self.resultTable.isHidden = true
                        }
                        else{
                            for i in 0..<results.count{
                                self.names.append(results[i]["name"].string!)
                                self.icons.append(results[i]["icon"].string!)
                                self.addresses.append(results[i]["vicinity"].string!)
                                self.ids.append(results[i]["place_id"].string!)
                            }
                        }
                    }
                    else{
                        self.view.showToast("No Record.", position: .bottom, popTime: 2, dismissOnTap: true)
                    }
                    SwiftSpinner.hide()
                    self.resultTable.reloadData()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resultTable.reloadData()
    }

    @IBAction func touchNext(_ sender: Any) {
        pageNumber += 1
        print("ask for page \(pageNumber)")
        print("current stored page: \(pageRecords.count)")
        if pageNumber <= pageRecords.count-1{
            names = pageRecords[pageNumber].names
            ids = pageRecords[pageNumber].ids
            icons = pageRecords[pageNumber].icons
            addresses = pageRecords[pageNumber].addresses
            nextToken = pageRecords[pageNumber].nextToken
            if nextToken == "" {
                nextBtn.isEnabled = false
            }
            prevBtn.isEnabled = true
            resultTable.reloadData()
        }
        else{
            SwiftSpinner.show("Loading next page...")
            let pageRecord = PageRecordStruct(names: names,ids: ids,addresses: addresses,icons: icons,nextToken:nextToken)
            pageRecords.append(pageRecord)
            let parameters:Dictionary<String,String> = ["token":nextToken]
            let url = "http://cs571-nodejs-env.us-east-2.elasticbeanstalk.com/ajax/search/result/next"
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
                .responseSwiftyJSON { response in
                    print("Request: \(String(describing: response.request))")   // original url request
//                    print("Response: \(String(describing: response.response))") // http url response
                    if response.result.value != nil{
                        let swiftJson = response.result.value
                        if swiftJson!["next_page_token"].exists(){
                            self.nextToken = swiftJson!["next_page_token"].string!
                        }
                        else{
                            self.nextToken = ""
                            self.nextBtn.isEnabled = false
                        }
                        let results = swiftJson!["results"]
                        self.names = []
                        self.ids = []
                        self.icons = []
                        self.addresses = []
                        for i in 0..<results.count{
                            self.names.append(results[i]["name"].string!)
                            self.icons.append(results[i]["icon"].string!)
                            self.addresses.append(results[i]["vicinity"].string!)
                            self.ids.append(results[i]["place_id"].string!)
                        }
                    }
                    else{
                        self.view.showToast("No Record.", position: .bottom, popTime: 5, dismissOnTap: true)
                    }
                    SwiftSpinner.hide()
//                    print("names:\(self.names)")
                    self.prevBtn.isEnabled = true
                    self.resultTable.reloadData()
            }
            
        }
    }
    @IBAction func touchPrev(_ sender: Any) {
        if pageRecords.count == pageNumber{
            let pageRecord = PageRecordStruct(names: names,ids: ids,addresses: addresses,icons: icons,nextToken:nextToken)
            pageRecords.append(pageRecord)
        }
        pageNumber -= 1
        print("ask for page \(pageNumber)")
        print("current stored page: \(pageRecords.count)")
        names = pageRecords[pageNumber].names
        ids = pageRecords[pageNumber].ids
        icons = pageRecords[pageNumber].icons
        addresses = pageRecords[pageNumber].addresses
        nextToken = pageRecords[pageNumber].nextToken
        if pageNumber == 0{
            prevBtn.isEnabled = false
        }
        nextBtn.isEnabled = true
        resultTable.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("show \(names.count) records")
        return names.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTableRowNum=indexPath.row
        performSegue(withIdentifier: "showDetailFromSearch", sender: self)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! ResultTableViewCell
        cell.name.text = names[indexPath.row]
        cell.address.text = addresses[indexPath.row]
        if let url = URL(string: icons[indexPath.row]) {
            if let data = NSData(contentsOf: url) {
                cell.icon.image = UIImage(data: data as Data)
            }
        }
        //handle favorite button
        let placeFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritePlace")
        placeFetch.predicate = NSPredicate(format: "id = %@", ids[indexPath.row])
        placeFetch.returnsObjectsAsFaults = false
        placeFetch.fetchLimit = 1
        cell.favorite.tag = indexPath.row
        do {
            let result = try context.fetch(placeFetch) as! [NSManagedObject]
            if result == []{
                cell.favorite.setImage(UIImage(named:"favorite-empty"), for: .normal)
            }
            else {
                cell.favorite.setImage(UIImage(named:"favorite-filled"), for: .normal)
            }
        } catch {
            print("Failed fetching")
        }
        cell.favorite.addTarget(self, action: #selector(touchFavoriteBtn), for:UIControlEvents.touchDown)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! DetailViewController
        dest.receiveName = names[selectedTableRowNum]
        dest.receiveId = ids[selectedTableRowNum]
    }
    @objc func touchFavoriteBtn (sender:UIButton){
        let placeFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritePlace")
        placeFetch.predicate = NSPredicate(format: "id = %@", ids[sender.tag])
        placeFetch.returnsObjectsAsFaults = false
        placeFetch.fetchLimit = 1
        do{
            let result = try context.fetch(placeFetch) as! [NSManagedObject]
            if result == []{
                let index = sender.tag
                let entity = NSEntityDescription.entity(forEntityName: "FavoritePlace", in: context)
                let newPlace = NSManagedObject(entity: entity!, insertInto: context)
                newPlace.setValue(ids[index], forKey: "id")
                newPlace.setValue(names[index], forKey: "name")
                newPlace.setValue(addresses[index], forKey: "address")
                newPlace.setValue(icons[index], forKey: "icon_url")
                do {
                    try context.save()
                    sender.setImage(UIImage(named:"favorite-filled"), for: .normal)
                    self.view.showToast("\(names[index]) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                } catch {
                    print("Failed saving")
                }
            }
            else{
                context.delete(result[0])
                do {
                    try context.save()
                    sender.setImage(UIImage(named:"favorite-empty"), for: .normal)
                    self.view.showToast("\(names[sender.tag]) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                } catch {
                    print("Failed deleting")
                }
            }
        }catch{
            print("Failed fetching")
        }
        

    }
}


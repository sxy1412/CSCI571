//
//  DetailViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/14/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import CoreData
import EasyToast
struct ReviewObj{
    var name:String!
    var photoURL:String!
    var reviewURL:String!
    var rating: Double!
    var text:String?
    var time:Double!
}
struct detailPlace{
    let name:String!
    let id:String!
    let icon:String!
    let address:String!
    let lat:Double!
    let lon:Double!
    var priceLevel:Int?
    var phoneNumber:String?
    var rating:Double?
    var website:String?
    var googlePage:String?
    var photosRef:[String]?
    var reviews:[ReviewObj]
}
class DetailViewController: UITabBarController {
    var receiveName:String!
    var receiveId:String!
    var detail:detailPlace!
    var favoriteButton:UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareButton = UIBarButtonItem(image: UIImage(named: "forward-arrow"), style: .plain, target: self, action: #selector(touchShareBtn))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let placeFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritePlace")
        placeFetch.predicate = NSPredicate(format: "id = %@", receiveId)
        placeFetch.returnsObjectsAsFaults = false
        placeFetch.fetchLimit = 1
        do{
            let result = try context.fetch(placeFetch) as! [NSManagedObject]
            if result == []{
                favoriteButton = UIBarButtonItem(image: UIImage(named:"favorite-empty"), style: .plain, target: self, action: #selector(touchFavoriteBtn))
            }
            else{
                favoriteButton = UIBarButtonItem(image: UIImage(named:"favorite-filled"), style: .plain, target: self, action: #selector(touchFavoriteBtn))
            }
        }
        catch{
            print("fetch failed")
        }
        
        self.navigationItem.rightBarButtonItems = [favoriteButton, shareButton] as! [UIBarButtonItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let name = receiveName{
            self.navigationItem.title = name
        }
    }
    @objc func touchShareBtn(){
        print("press share")
        let twitter="https://twitter.com/intent/tweet?text=Check+out+\(detail.name!)+located+at+\(detail.address!).+Website:&hashtags=TravelAndEntertainmentSearch&url=\(detail.website!)"
        let twitterURL = URL(string: twitter.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        UIApplication.shared.open(twitterURL!)
    }
    @objc func touchFavoriteBtn(){
        print("press favorite")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let placeFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritePlace")
        placeFetch.predicate = NSPredicate(format: "id = %@", detail.id)
        placeFetch.returnsObjectsAsFaults = false
        placeFetch.fetchLimit = 1
        do {
            let result = try context.fetch(placeFetch) as! [NSManagedObject]
            if result == []{
                let entity = NSEntityDescription.entity(forEntityName: "FavoritePlace", in: context)
                let newPlace = NSManagedObject(entity: entity!, insertInto: context)
                newPlace.setValue(detail.id, forKey: "id")
                newPlace.setValue(detail.name, forKey: "name")
                newPlace.setValue(detail.address, forKey: "address")
                newPlace.setValue(detail.icon, forKey: "icon_url")
                do {
                    try context.save()
                    self.view.showToast("\(detail.name!) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                    favoriteButton?.image = UIImage(named:"favorite-filled")
                } catch {
                    print("Failed saving")
                }
            }
            else {
                context.delete(result[0])
                do {
                    try context.save()
                    self.view.showToast("\(detail.name!) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                    favoriteButton?.image = UIImage(named:"favorite-empty")
                } catch {
                    print("Failed deleting")
                }
            }
        } catch {
            print("Failed fetching")
        }
    }

}

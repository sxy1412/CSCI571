//
//  FavoriteViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/13/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import CoreData
import EasyToast

class FavoriteViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var favoriteTable: UITableView!
    var selectedTableRowNum:Int = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    var favoritePlace:[FavoritePlace] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        context = appDelegate.persistentContainer.viewContext
        let placeFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritePlace")
        do{
            let result = try context.fetch(placeFetch) as! [NSManagedObject]
            favoritePlace = result as! [FavoritePlace]
            favoriteTable.reloadData()
        }catch{
            print("failed fetching")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoritePlace.count == 0 {
            tableView.isHidden = true
        }
        else {
            tableView.isHidden = false
        }
        return favoritePlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteTableViewCell
        cell.name.text = favoritePlace[indexPath.row].name
        cell.address.text = favoritePlace[indexPath.row].address
        if let url = URL(string: favoritePlace[indexPath.row].icon_url!) {
            if let data = NSData(contentsOf: url) {
                cell.icon.image = UIImage(data: data as Data)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTableRowNum=indexPath.row
        performSegue(withIdentifier: "showDetailFromFavorite", sender: self)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") {
            action, index in
            let name = self.favoritePlace[indexPath.row].name
            self.context.delete(self.favoritePlace[indexPath.row])
            do {
                try self.context.save()
                self.view.showToast("\(name!) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: true)
            } catch {
                print("Failed deleting")
            }
            self.favoritePlace.remove(at: indexPath.row)
            tableView.reloadData()
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! DetailViewController
        dest.receiveName = favoritePlace[selectedTableRowNum].name
        dest.receiveId = favoritePlace[selectedTableRowNum].id
    }

}

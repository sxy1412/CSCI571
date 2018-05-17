//
//  PhotoViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/14/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import Alamofire

class PhotoViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    var numOfImages:Int!
    
    @IBOutlet weak var photoCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let detailCtr = self.tabBarController as! DetailViewController
        if detailCtr.detail.photosRef != []{
            collectionView.isHidden = false
            return (detailCtr.detail.photosRef?.count)!
        }
        else{
            collectionView.isHidden = true
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let detailCtr = self.tabBarController as! DetailViewController
        let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        let maxwidth = Int(UIScreen.main.bounds.width*1.5)
        let parameters:Dictionary<String,String> = ["photoreference":detailCtr.detail.photosRef![indexPath.row],"key":"AIzaSyA4vparXAjZG08pHMh4PiV87-9uXLV03-Y","maxwidth":maxwidth.description]
        let url = "https://maps.googleapis.com/maps/api/place/photo"
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseData { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                cell.photo.image = UIImage(data: response.result.value!)
        }
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  SegmentedViewController.swift
//  hw9
//
//  Created by Xinyi Shen on 4/13/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var favoriteView: UIView!
    @IBOutlet weak var searchView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.isHidden = false
        favoriteView.isHidden = true
        // Remove tittle for backbarbutton
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            searchView.isHidden = false
            favoriteView.isHidden = true
        case 1:
            searchView.isHidden = true
            favoriteView.isHidden = false
        default:
            break;
        }
    }

}

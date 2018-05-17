//
//  FavoritePlace+CoreDataProperties.swift
//  hw9
//
//  Created by Xinyi Shen on 4/19/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//
//

import Foundation
import CoreData


extension FavoritePlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePlace> {
        return NSFetchRequest<FavoritePlace>(entityName: "FavoritePlace")
    }

    @NSManaged public var address: String?
    @NSManaged public var icon_url: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?

}

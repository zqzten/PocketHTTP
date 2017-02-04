//
//  PHVariable+CoreDataProperties.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/31.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import Foundation
import CoreData

extension PHVariable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PHVariable> {
        return NSFetchRequest<PHVariable>(entityName: "PHVariable");
    }

    @NSManaged public var name: String
    @NSManaged public var value: String

}

//
//  PHRequest+CoreDataProperties.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/27.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import Foundation
import CoreData

extension PHRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PHRequest> {
        return NSFetchRequest<PHRequest>(entityName: "PHRequest");
    }

    @NSManaged public var method: String
    @NSManaged public var baseURL: String
    @NSManaged public var headers: [[String]]
    @NSManaged public var parameters: [[String]]
    @NSManaged public var body: [[String]]
    @NSManaged public var name: String?
    @NSManaged public var time: Date?

}

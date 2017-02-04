//
//  PHRequest+CoreDataClass.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/26.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import Foundation
import CoreData

enum PHMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
    case HEAD
    case OPTIONS
    static let allValues = [GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS]
}

@objc(PHRequest)
public class PHRequest: NSManagedObject {

    var url: String { return makeURL(onBase: baseURL, withPara: parameters) }
    
}

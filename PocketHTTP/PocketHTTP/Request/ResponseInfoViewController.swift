//
//  ResponseInfoViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/30.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit

class ResponseInfoViewController: UITableViewController {

    var responseInfo: HTTPURLResponse!
    lazy var orderedHeaders: [(key: String, value: String)] = {
        var orderedHeaders = [(key: String, value: String)]()
        for (key, value) in self.responseInfo.allHeaderFields {
            orderedHeaders.append((key: key as! String, value: value as! String))
        }
        return orderedHeaders
    }()

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : orderedHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Status Code" : "Response Headers"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel!.text = String(responseInfo.statusCode)
            cell.detailTextLabel!.text = HTTPURLResponse.localizedString(forStatusCode: responseInfo.statusCode)
        } else {
            cell.textLabel!.text = orderedHeaders[indexPath.row].key
            cell.detailTextLabel!.text = orderedHeaders[indexPath.row].value
        }
        return cell
    }
    
}

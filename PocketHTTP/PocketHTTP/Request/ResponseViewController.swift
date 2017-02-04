//
//  ResponseViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/28.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class ResponseViewController: UIViewController {
    
    @IBOutlet weak var styleControl: UISegmentedControl!

    var resultWebView: WKWebView!
    var response: DataResponse<Data>!
    var useDarkTheme: Bool { return UserDefaults.standard.bool(forKey: "UseDarkTheme") }
    
    @IBAction func changeStyle(_ sender: UISegmentedControl) {
        loadResult()
    }
    
    func loadResult() {
        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
        switch styleControl.selectedSegmentIndex {
        case 0:
            var contentString: String
            var contentData = response.result.value!
            // try to make pretty JSON
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: response.result.value!, options: [])
                contentData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            } catch {}
            contentString = String(data: contentData, encoding: .utf8)!
            // escape HTML characters
            contentString = contentString.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "&", with: "&amp;")
            // apply code highlight
            let css = useDarkTheme ? "darcula" : "default"
            let background = useDarkTheme ? "#2b2b2b" : "#F0F0F0"
            let htmlString = "<!DOCTYPE html>\r\n<html style='font-size:2rem; background:\(background)'>\r\n<head>\r\n<meta charset='utf-8'>\r\n<link rel='stylesheet' href='\(css).css'>\r\n<script src='highlight.pack.js'></script>\r\n<script>hljs.initHighlightingOnLoad();</script>\r\n</head>\r\n<body>\r\n<pre style='margin: 0 0 0 0'><code>\r\n\(contentString)\r\n</code></pre>\r\n</body>\r\n</html>"
            resultWebView.loadHTMLString(htmlString, baseURL: baseURL)
        case 1:
            resultWebView.load(response.result.value!, mimeType: "text/plain", characterEncodingName: "UTF-8", baseURL: baseURL)
        case 2:
            resultWebView.load(response.result.value!, mimeType: "text/html", characterEncodingName: "UTF-8", baseURL: baseURL)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.addSubview(resultWebView)
        loadResult()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResponseInfo" {
            let controller = segue.destination as! ResponseInfoViewController
            controller.responseInfo = response.response
        }
    }

}

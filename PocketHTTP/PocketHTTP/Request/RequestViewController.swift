//
//  RequestViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/26.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import Alamofire

class RequestViewController: UITableViewController {
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext!
    private lazy var userDefaults = UserDefaults.standard
    private var sessionManager: SessionManager!
    
    var request: PHRequest? {
        // load stored request
        didSet {
            if let request = request {
                baseURL = request.baseURL
                method = PHMethod(rawValue: request.method)!
                parameters = request.parameters
                headers = request.headers
                body = request.body
                tableView.reloadData()
            }
        }
    }
    private var response: DataResponse<Data>!
    
    fileprivate var urlTextField: UITextField { return tableView.cellForRow(at: IndexPath(row: 0, section: 0))!.viewWithTag(1002) as! UITextField }
    private var textFieldNeedRecover = false
    fileprivate var lastActiveTextField: UITextField?
    var variableToInsert: PHVariable!
    
    fileprivate var baseURL = ""
    fileprivate var method = PHMethod.GET
    fileprivate var parameters = [["", ""]] {
        didSet {
            // update URL simultaneously
            urlTextField.text = makeURL(onBase: baseURL, withPara: parameters)
        }
    }
    fileprivate var headers = [["", ""]]
    fileprivate var body = [["", ""]]
    
    @IBAction private func send() {
        // end URL editing
        urlTextField.resignFirstResponder()
        
        // validate URL
        guard let url = URL(string: applyEvironmentVariables(urlTextField.text!)) else {
            promptError(withText: "Invalid URL")
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            promptError(withText: "Invalid URL")
            return
        }
        
        // save request to history
        let request = PHRequest(context: managedObjectContext)
        request.baseURL = baseURL
        request.method = method.rawValue
        request.parameters = parameters
        request.headers = headers
        request.body = body
        request.time = Date()
        do {
            let limit = userDefaults.integer(forKey: "HistoryLimit")
            if limit != 0 {
                let fetchRequest: NSFetchRequest<PHRequest> = PHRequest.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == nil")
                if try managedObjectContext.count(for: fetchRequest) > limit {
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
                    fetchRequest.fetchLimit = 1
                    let historyToDelete = try managedObjectContext.fetch(fetchRequest)
                    managedObjectContext.delete(historyToDelete[0])
                }
            }
            try managedObjectContext.save()
        } catch {
            fatalError("Could not save data: \(error)")
        }
        
        let requestingHUD = HUDView.indicatorHUD(inView: navigationController!.view, animated: true)
        
        let configuration = URLSessionConfiguration.default
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        if userDefaults.bool(forKey: "UseDeviceUserAgent") {
            var deviceUserAgent: String? = nil
            var finished = false
            let webView = WKWebView(frame: CGRect.zero)
            webView.evaluateJavaScript("navigator.userAgent") { result in
                deviceUserAgent = result.0 as? String
                finished = true
            }
            while !finished {
                RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantFuture)
            }
            if let deviceUserAgent = deviceUserAgent {
                defaultHeaders["User-Agent"] = deviceUserAgent
            } else {
                print("Failed to get current device's User-Agent")
            }
        }
        configuration.httpAdditionalHeaders = defaultHeaders
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        var headersDict = convertToDict(headers)
        if userDefaults.bool(forKey: "SendNoCacheHeader") {
            headersDict["Cache-Control"] = "no-cache"
        }
        
        sessionManager.request(url, method: HTTPMethod(rawValue: method.rawValue)!, parameters: convertToDict(body), headers: headersDict).responseData() { response in
            requestingHUD.hide()
            // handle request error
            if let error = response.error {
                print(error)
                let alert = UIAlertController(title: "Request Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            // show response
            self.response = response
            self.performSegue(withIdentifier: "ShowResponse", sender: nil)
        }
    }
    
    @IBAction private func methodPickerDidPickMethod(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! MethodPickerViewController
        method = controller.selectedMethod
        tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.textLabel!.text = method.rawValue
    }
    
    @IBAction private func responseViewerDidViewResponse(_ segue: UIStoryboardSegue) {}
    
    @IBAction private func environmentViewerDidPickVariable(_ segue: UIStoryboardSegue) {
        if let textField = lastActiveTextField {
            textField.text! += "{{\(variableToInsert.name)}}"
            if textField == urlTextField {
                sendButton.isEnabled = true
            }
        }
    }
    
    @IBAction private func environmentViewerDidViewEnvironment(_ segue: UIStoryboardSegue) {}
    
    private func applyEvironmentVariables(_ raw: String) -> String {
        var applied = raw
        let regex = try! NSRegularExpression(pattern: "\\{\\{.+\\}\\}", options: [])
        let matches = regex.matches(in: raw, options: [], range: NSRange(location: 0, length: raw.characters.count))
        let fetchRequest: NSFetchRequest<PHVariable> = PHVariable.fetchRequest()
        for match in matches {
            let matchedRange = raw.index(raw.startIndex, offsetBy: match.range.location)..<raw.index(raw.startIndex, offsetBy: match.range.location + match.range.length)
            let matchedString = raw[matchedRange]
            fetchRequest.predicate = NSPredicate(format: "name == %@", matchedString[matchedString.index(matchedString.startIndex, offsetBy: 2)..<matchedString.index(matchedString.endIndex, offsetBy: -2)])
            do {
                let result = try managedObjectContext.fetch(fetchRequest)
                if result.count > 0 {
                    applied.replaceSubrange(matchedRange, with: result[0].value)
                }
            } catch {
                fatalError("Could not fetch data: \(error)")
            }
        }
        print(applied)
        return applied
    }
    
    private func convertToDict(_ parameters: [[String]]) -> [String: String] {
        var dict = [String: String]()
        for parameter in parameters {
            if parameter[0] != "" || parameter[1] != "" {
                dict[applyEvironmentVariables(parameter[0])] = applyEvironmentVariables(parameter[1])
            }
        }
        return dict
    }
    
    private func promptError(withText text: String) {
        let errorHUD = HUDView.hud(inView: navigationController!.view, animated: true, withText: text, andImage: #imageLiteral(resourceName: "Error"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            errorHUD.hide()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // recover editing state
        if textFieldNeedRecover, let textField = lastActiveTextField {
            textField.becomeFirstResponder()
            textFieldNeedRecover = false
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "URL"
        case 1: return "Method"
        case 2: return "Parameters"
        case 3: return "Headers"
        case 4: return "Body"
        default: return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 1
        case 2: return parameters.count
        case 3: return headers.count
        case 4: return body.count
        default: return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "URLCell", for: indexPath)
            (cell.viewWithTag(1002) as! UITextField).text = makeURL(onBase: baseURL, withPara: parameters)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell", for: indexPath)
            cell.textLabel!.text = method.rawValue
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath)
            (cell.viewWithTag(1000) as! UITextField).text = parameters[indexPath.row][0]
            (cell.viewWithTag(1001) as! UITextField).text = parameters[indexPath.row][1]
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath)
            (cell.viewWithTag(1000) as! UITextField).text = headers[indexPath.row][0]
            (cell.viewWithTag(1001) as! UITextField).text = headers[indexPath.row][1]
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath)
            (cell.viewWithTag(1000) as! UITextField).text = body[indexPath.row][0]
            (cell.viewWithTag(1001) as! UITextField).text = body[indexPath.row][1]
            return cell
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 2:
            return parameters.count > 1
        case 3:
            return headers.count > 1
        case 4:
            return body.count > 1
        default:
            return false
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            if editingStyle == .delete {
                parameters.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case 3:
            if editingStyle == .delete {
                headers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case 4:
            if editingStyle == .delete {
                body.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            return
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickMethod" {
            let controller = segue.destination as! MethodPickerViewController
            controller.selectedMethod = method
        }
        if segue.identifier == "ShowResponse" {
            let controller = (segue.destination as! UINavigationController).viewControllers[0] as! ResponseViewController
            controller.response = response
        }
        if segue.identifier == "ShowEnvironment" {
            textFieldNeedRecover = true
            let controller = (segue.destination as! UINavigationController).viewControllers[0] as! EnvironmentViewController
            controller.managedObjectContext = managedObjectContext
        }
    }

}

extension RequestViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // append additional blank field when last field is selected
        let indexPath = tableView.indexPath(for: textField.superview!.superview as! UITableViewCell)!
        switch indexPath.section {
        case 2:
            if indexPath.row == parameters.count - 1 {
                parameters.append(["", ""])
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .automatic)
            }
        case 3:
            if indexPath.row == headers.count - 1 {
                headers.append(["", ""])
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .automatic)
            }
        case 4:
            if indexPath.row == body.count - 1 {
                body.append(["", ""])
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .automatic)
            }
        default:
            break;
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // save editing state
        lastActiveTextField = textField
        
        // update parameter variables
        let indexPath = tableView.indexPath(for: textField.superview!.superview as! UITableViewCell)!
        switch indexPath.section {
        case 0:
            // update parameters simultaneously
            let newURL = splitURL(textField.text!)
            baseURL = newURL.baseURL
            parameters = newURL.parameters
            tableView.reloadData()
            lastActiveTextField = urlTextField
        case 2:
            parameters[indexPath.row][textField.tag - 1000] = textField.text!
        case 3:
            headers[indexPath.row][textField.tag - 1000] = textField.text!
        case 4:
            body[indexPath.row][textField.tag - 1000] = textField.text!
        default:
            break;
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        if tableView.indexPath(for: textField.superview!.superview as! UITableViewCell)?.section == 0 {
            sendButton.isEnabled = newText.length > 0
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1000: textField.superview!.superview!.viewWithTag(1001)!.becomeFirstResponder()
        case 1001, 1002: textField.resignFirstResponder()
        default: break
        }
        return true
    }
    
}

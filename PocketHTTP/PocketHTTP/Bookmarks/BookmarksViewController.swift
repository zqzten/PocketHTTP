//
//  BookmarksViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/27.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit
import CoreData

class BookmarksViewController: UITableViewController {

    @IBOutlet private weak var typeControl: UISegmentedControl!
    
    var requestViewController: RequestViewController!
    var managedObjectContext: NSManagedObjectContext!
    
    private lazy var fetchedHistoryController: NSFetchedResultsController<PHRequest> = {
        let fetchRequest: NSFetchRequest<PHRequest> = PHRequest.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == nil")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        let fetchedHistoryController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedHistoryController.delegate = self
        return fetchedHistoryController
    }()
    private lazy var fetchedFavoritesController: NSFetchedResultsController<PHRequest> = {
        let fetchRequest: NSFetchRequest<PHRequest> = PHRequest.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name != nil")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let fetchedFavoritesController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedFavoritesController.delegate = self
        return fetchedFavoritesController
    }()
    
    fileprivate var activeFetchedResultsController: NSFetchedResultsController<PHRequest> {
        return typeControl.selectedSegmentIndex == 0 ? fetchedHistoryController : fetchedFavoritesController
    }
    private var inactiveFetchedResultsController: NSFetchedResultsController<PHRequest> {
        return typeControl.selectedSegmentIndex == 0 ? fetchedFavoritesController : fetchedHistoryController
    }
    
    @IBAction private func changeType(_ sender: UISegmentedControl) {
        inactiveFetchedResultsController.delegate = nil
        activeFetchedResultsController.delegate = self
        performFetch(with: activeFetchedResultsController)
        tableView.reloadData()
    }
    
    private func performFetch(with fetchedResultsController: NSFetchedResultsController<PHRequest>) {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Could not fetch data: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Could not save data: \(error)")
        }
    }
    
    fileprivate func configureCell(_ cell: UITableViewCell, withRequest request: PHRequest) {
        if typeControl.selectedSegmentIndex == 0 {
            cell.textLabel!.text = request.url
            cell.detailTextLabel!.text = request.method
        } else {
            cell.textLabel!.text = request.name
            cell.detailTextLabel!.text = request.url
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        performFetch(with: activeFetchedResultsController)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeFetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        let request = activeFetchedResultsController.object(at: indexPath)
        configureCell(cell, withRequest: request)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        requestViewController.request = activeFetchedResultsController.object(at: indexPath)
        requestViewController.sendButton.isEnabled = true
        tabBarController!.selectedIndex = 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let request = activeFetchedResultsController.object(at: indexPath)
        
        // delete action
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _ in
            self.managedObjectContext.delete(request)
            self.saveContext()
        }
        
        if typeControl.selectedSegmentIndex == 0 {
            // favor action
            let favorAction = UITableViewRowAction(style: .normal, title: "Favor") { _ in
                let alert = UIAlertController(title: "Name your favorite", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.tableView.isEditing = false
                }
                let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                    tableView.isEditing = false
                    // copy a history as favorite
                    let favorite = PHRequest(context: self.managedObjectContext)
                    for (key, _) in request.entity.propertiesByName {
                        favorite.setValue(request.value(forKey: key), forKey: key)
                    }
                    favorite.time = nil
                    favorite.name = alert.textFields![0].text!
                    self.saveContext()
                }
                alert.addAction(cancelAction)
                alert.addAction(saveAction)
                alert.addTextField(configurationHandler: nil)
                self.present(alert, animated: true, completion: nil)
            }
            favorAction.backgroundColor = .orange
            return [deleteAction, favorAction]
        } else {
            // rename action
            let renameAction = UITableViewRowAction(style: .normal, title: "Rename") { _ in
                let alert = UIAlertController(title: "Rename your favorite", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.tableView.isEditing = false
                }
                let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                    self.tableView.isEditing = false
                    request.name = alert.textFields![0].text!
                    self.saveContext()
                }
                alert.addAction(cancelAction)
                alert.addAction(saveAction)
                alert.addTextField() { textField in textField.text = request.name }
                self.present(alert, animated: true, completion: nil)
            }
            renameAction.backgroundColor = systemBlue()
            return [deleteAction, renameAction]
        }
    }

}

extension BookmarksViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withRequest: activeFetchedResultsController.object(at: indexPath!))
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

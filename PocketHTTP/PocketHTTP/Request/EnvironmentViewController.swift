//
//  EnvironmentViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/31.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit
import CoreData

class EnvironmentViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<PHVariable> = {
        let fetchRequest: NSFetchRequest<PHVariable> = PHVariable.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    @IBAction func variableEditorDidEditVariable(_ segue: UIStoryboardSegue) {}
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Could not save data: \(error)")
        }
    }
    
    fileprivate func configureCell(_ cell: UITableViewCell, withVariable variable: PHVariable) {
        cell.textLabel!.text = variable.name
        cell.detailTextLabel!.text = variable.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Could not fetch data: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VariableCell", for: indexPath)
        configureCell(cell, withVariable: fetchedResultsController.object(at: indexPath))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let variable = fetchedResultsController.object(at: indexPath)
        
        // delete action
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _ in
            self.managedObjectContext.delete(variable)
            self.saveContext()
        }
        
        // edit action
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _ in
            self.performSegue(withIdentifier: "EditVariable", sender: variable)
            tableView.isEditing = false
        }
        editAction.backgroundColor = systemBlue()
        return [deleteAction, editAction]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedVariable" {
            let controller = segue.destination as! RequestViewController
            controller.variableToInsert = fetchedResultsController.object(at: tableView.indexPath(for: sender as! UITableViewCell)!)
        }
        if segue.identifier == "EditVariable" {
            let controller = (segue.destination as! UINavigationController).viewControllers[0] as! VariableEditingViewController
            controller.managedObjectContext = managedObjectContext
            if let variable = sender as? PHVariable {
                controller.variable = variable
            }
        }
    }

}

extension EnvironmentViewController: NSFetchedResultsControllerDelegate {
    
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
            configureCell(tableView.cellForRow(at: indexPath!)!, withVariable: fetchedResultsController.object(at: indexPath!))
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

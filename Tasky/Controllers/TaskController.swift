//
//  TaskController.swift
//  Tasky
//
//  Created by Cristian villanueva on 5/10/20.
//  Copyright © 2020 Cristian villanueva. All rights reserved.
//

import UIKit

class TaskController: UITableViewController {
    
    var taskStorage: TaskStorage! {
        didSet {
            // get data
            taskStorage.tasks = TasksUtility.fetch() ?? [[Task](), [Task]()]
            
            
            // reload table view
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        // setting up our alert controller
        let alertController = UIAlertController(title: "Add task", message: nil, preferredStyle: .alert)
        
        
        // set up the actions
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            // grab text field text
            guard let name = alertController.textFields?.first?.text else {return}
            
            // create task
            let newTask = Task.init(name: name)
            
            // add task
            self.taskStorage.add(newTask, at: 0)
            
            // reload data in table view
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
            // save
            TasksUtility.save(self.taskStorage.tasks)
        }
        
        addAction.isEnabled = false
        let cancelACtion = UIAlertAction(title: "Cancel", style: .cancel)
        
        // add the text field to alertController
        alertController.addTextField { textField in
            textField.placeholder = "Enter task name!"
            textField.addTarget(self, action: #selector(self.handleTextChanged), for: .editingChanged)
        }
        
        // add the actions to the alertController
        alertController.addAction(addAction)
        alertController.addAction(cancelACtion)
        
        
        // present
        present(alertController, animated: true)
        
        
    }
    
    // objc allows the function to be available in objective C in the objective C runtime
    @objc private func handleTextChanged(_ sender: UITextField){
        //grab alert controller and add action
        guard let alertController = presentedViewController as? UIAlertController,
            let addAction = alertController.actions.first,
            let text = sender.text
            else {return}
        
        // Enable add action based on if text is empty or contains white space
        addAction.isEnabled = !(text.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
}





// MARK: - DataSource for tables

extension TaskController {
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-Do" : "Done"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        taskStorage.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows are we wanting? this should return that
        return taskStorage.tasks[section].count
    }

    
    @available(iOS 2.0, *)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //this will be called every time table view reloads
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = taskStorage.tasks[indexPath.section][indexPath.row].name
        return cell
    }

    
}



// MARK: - Delegate
extension TaskController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil){ (action, sourceView, completionHandler) in
            
            // determine if task is done
            
            guard let isDone = self.taskStorage.tasks[indexPath.section][indexPath.row].isDone else {return}
            
            
            // remove task from apporopriate array
            self.taskStorage.remove(at: indexPath.row, isDone: isDone)
            
            // Reload table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // save
            TasksUtility.save(self.taskStorage.tasks)
            
            // indicate that the action was performed
            completionHandler(true)
            
            
            
        }
        
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.2011526751, blue: 0.276107363, alpha: 1)
        
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [deleteAction]) : nil
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let doneAction = UIContextualAction(style: .normal, title: nil) {(action, sourceView, completionHandler) in

            // toggle that the task is done
            self.taskStorage.tasks[0][indexPath.row].isDone = true
            
            // remove task from array containing todo tasks
            let doneTask = self.taskStorage.remove(at: indexPath.row)
            
            
            // reload table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // add the task to the done array
            self.taskStorage.add(doneTask, at: 0, isDone: true)
            
            // reload table view
            tableView.insertRows(at: [IndexPath.init(row: 0, section: 1)], with: .automatic)
            
            // save
            TasksUtility.save(self.taskStorage.tasks)
            
            //indicate that the action was performed
            completionHandler(true)
            
        }
        
        doneAction.image = UIImage(named: "done")
        doneAction.backgroundColor = #colorLiteral(red: 0.5021091723, green: 1, blue: 0.3843798948, alpha: 1)
        
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
}

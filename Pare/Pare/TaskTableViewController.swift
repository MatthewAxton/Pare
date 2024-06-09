//
//  TaskTableViewController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 8/6/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tasks = [Task]()
    var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        databaseController = (UIApplication.shared.delegate as! AppDelegate).databaseController
        fetchTasks()
    }

    func fetchTasks() {
        databaseController?.fetchTasks { tasks, error in
            if let error = error {
                print("Error fetching tasks: \(error)")
                return
            }
            self.tasks = tasks ?? []
            self.tableView.reloadData()
        }
    }

    @IBAction func addTask(_ sender: Any) {
        performSegue(withIdentifier: "showAddTask", sender: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = (task.isCompleted ?? false) ? "Completed" : "Incomplete"
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddTask",
           let destinationVC = segue.destination as? AddTaskViewController {
            destinationVC.delegate = self
        }
    }
}

extension TaskViewController: AddTaskDelegate {
    func didAddTask(_ task: Task) {
        tasks.append(task)
        tableView.reloadData()
    }
    
    
}

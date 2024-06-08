//
//  AddTaskViewController.swift
//  Pare
//
//  Created by Matthew Axton Susilo on 8/6/2024.
//

import UIKit

protocol AddTaskDelegate: AnyObject {
    func didAddTask(_ task: Task)
}

class AddTaskViewController: UIViewController {

    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskCompletionSwitch: UISwitch!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    
    
    weak var delegate: AddTaskDelegate?
    var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        databaseController = (UIApplication.shared.delegate as! AppDelegate).databaseController
    }

    @IBAction func saveTask(_ sender: Any) {
        guard let name = taskNameTextField.text, !name.isEmpty else {
            print("Task name cannot be empty")
            return
        }
        
        let isCompleted = taskCompletionSwitch.isOn
        let date = taskDatePicker.date

        let task = Task(name: name, isCompleted: isCompleted, date: date)

        databaseController?.addTask(task) { error in
            if let error = error {
                print("Error adding task: \(error)")
                return
            }
            self.delegate?.didAddTask(task)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

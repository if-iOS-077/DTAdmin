//
//  TestDetailsViewController.swift
//  DTAdmin
//
//  Created by ITA student on 11/6/17.
//  Copyright © 2017 if-ios-077. All rights reserved.
//

import UIKit

class TestDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let dataModel = DataModel.dataModel
    var id = "3"
    @IBOutlet weak var testDetailsTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTestDetails()
        currentDataForPickers()
    }
    
    func getTestDetails() {
        DataManager.shared.getTestDetails(byTest: self.id) { (details, error) in
            if error == nil, let testDetails = details {
                self.dataModel.testDetailArray = testDetails
                self.testDetailsTableView.reloadData()
            } else {
                self.showWarningMsg(error ?? NSLocalizedString("Incorect type data", comment: "Incorect type data"))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.testDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let prototypeCell = tableView.dequeueReusableCell(withIdentifier: "testDetailsCell", for: indexPath) as? TestDetailsTableViewCell
        guard let cell = prototypeCell else { return UITableViewCell() }
        let array = dataModel.testDetailArray[indexPath.row]
        cell.testDetailId.text = array.id
        cell.testDetailTestId.text = array.testId
        cell.testDetailLevel.text = array.level
        cell.testDetailTasks.text = array.tasks
        cell.testDetailRate.text = array.rate
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit", handler: { action, indexPath in
            guard let testDetailCreateUpdateViewController = UIStoryboard(name: "TestDetails", bundle: nil).instantiateViewController(withIdentifier: "TestDetailCreateUpdateViewController") as? TestDetailCreateUpdateViewController else  { return }
            self.currentDataForPickers()
            testDetailCreateUpdateViewController.testDetailsInstance = self.dataModel.testDetailArray[indexPath.row]
            testDetailCreateUpdateViewController.canEdit = true
            testDetailCreateUpdateViewController.resultModification = { updateResult in
                self.dataModel.testDetailArray[indexPath.row] = updateResult
                self.testDetailsTableView.reloadData()
            }
            self.navigationController?.pushViewController(testDetailCreateUpdateViewController, animated: true)
        })
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexPath in
            let alert = UIAlertController(title: "WARNING", message: "Do you want to delete this test detail?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                guard let id = self.dataModel.testDetailArray[indexPath.row].id else { return }
                if indexPath.row < self.dataModel.testDetailArray.count {
                    DataManager.shared.deleteEntity(byId: id, typeEntity: Entities.testDetail) { (deleted, error) in
                        if let error = error {
                            self.showWarningMsg(error)
                        } else {
                            self.dataModel.testDetailArray.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .top)
                            self.testDetailsTableView.reloadData()
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        })
        return [delete, edit]
    }
    
    func currentDataForPickers() {
        dataModel.levelArrayForFiltering = []
        dataModel.taskArrayForFiltering = []
        for i in self.dataModel.testDetailArray {
            guard let levels = Int(i.level) else { return }
            self.dataModel.levelArrayForFiltering.append(levels)
            guard let tasks = Int(i.tasks) else { return }
            self.dataModel.taskArrayForFiltering.append(tasks)
        }
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        currentDataForPickers()
        if dataModel.taskArrayForFiltering.reduce(0, +) >= dataModel.max {
            self.showWarningMsg(NSLocalizedString("Sum of tasks for the test can't be more then 10", comment: "Sum of tasks should be from 1 to 10"))
        } else {
            guard let testDetailCreateUpdateViewController = UIStoryboard(name: "TestDetails", bundle: nil).instantiateViewController(withIdentifier: "TestDetailCreateUpdateViewController") as? TestDetailCreateUpdateViewController else { return }
            self.navigationController?.pushViewController(testDetailCreateUpdateViewController, animated: true)
            currentDataForPickers()
            testDetailCreateUpdateViewController.resultModification = { newTestDetail in
                self.dataModel.testDetailArray.append(newTestDetail)
                self.testDetailsTableView.reloadData()
            }
        }
    }
    
    /* - - - LogIn for testing - - - */
    @IBAction func loginButtonTapped(_ sender: Any) {
        //test data
        let loginText = "admin"
        let passwordText = "dtapi_admin"
        
        CommonNetworkManager.shared().logIn(username: loginText, password: passwordText) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                StoreHelper.saveUser(user: user)
                DispatchQueue.main.async {
                    print("user is logged")
                }
            }
        }
        
    }
    
}

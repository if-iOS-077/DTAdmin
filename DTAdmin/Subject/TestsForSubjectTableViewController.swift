//
//  TestsForSubjectTableViewController.swift
//  DTAdmin
//
//  Created by ITA student on 10/25/17.
//  Copyright © 2017 if-ios-077. All rights reserved.
//

import UIKit

class TestsForSubjectTableViewController: UITableViewController {
    
    var test = [Test]()
    var subjectId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Subject tests"
        guard let id = subjectId else { return }
        print(id)
        
        showTests(id: id)
    }
    
    @IBAction func addTest(_ sender: UIBarButtonItem) {
        //add new test
    }
    
    func showTests(id: String) {
        Test.showTests(sufix: id, completion: { (results:[Test]?) in
            
            if let data = results {
                self.test = data
                for item in self.test {
                    print("Name " + item.testName)
                    print("Tasks " + item.tasks)
                    print("timeForTest" + item.timeForTest)
                    print("attempts" + item.attempts)
                    print("enabled" + item.enabled)
                    print("id " + item.testId)
                    
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return test.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        cell.textLabel?.text = test[indexPath.row].testName
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {_,_ in
            //delete test record
        }
        let update = UITableViewRowAction(style: .normal, title: "Update") {_,_ in
            //update test record
        }
        update.backgroundColor = UIColor.blue
        return [delete, update]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let wayToShowTestInfo = UIStoryboard(name: "Subjects", bundle: nil).instantiateViewController(withIdentifier: "showTestInfo") as? ShowTestInfoViewController
        {
            wayToShowTestInfo.test = self.test[indexPath.row]
            print(test[indexPath.row].testId)
            self.navigationController?.pushViewController(wayToShowTestInfo, animated: true)
        }
    }

}

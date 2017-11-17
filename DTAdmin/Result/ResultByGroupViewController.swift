//
//  ResultByGroupViewController.swift
//  DTAdmin
//
//  Created by Yurii Krupa on 11/8/17.
//  Copyright © 2017 if-ios-077. All rights reserved.
//

import UIKit

class ResultByGroupViewController: ParentViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    var group: GroupStructure? {
        didSet {
            guard let group = self.group else {
                showWarningMsg("Wrong group structure")
                return
            }
            self.prepareView(group: group)
        }
    }
    
    var tests: [TestStructure]?
    lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(loadDataFromAPI), for: .valueChanged)
        resultsTableView.refreshControl = refreshControl
        
    }
    
    private func prepareView(group: GroupStructure) {
        self.startActivity()
        self.title = NSLocalizedString("Results by \(group.groupName)", comment: "Title for results table list view")
        self.refreshControl.beginRefreshing()
        self.loadDataFromAPI()
    }
    
    @objc private func loadDataFromAPI() {
        guard let groupId = self.group?.groupId else { return }
        var testsIds = [String]()
        var subjectsIds = [String]()
        
        DataManager.shared.getResultTestIds(byGroup: groupId) { (error, testIds) in
            if let error = error {
                self.stopActivity()
                self.showWarningMsg(error)
            } else {
                guard let testIds = testIds else {
                    self.stopActivity()
                    self.showWarningMsg("Error occured during data handle")
                    return
                }
                for i in testIds {
                    testsIds.append(i["test_id"]!)
                }
                
                DataManager.shared.getTestsBy(ids: testsIds, completionHandler: { (error, tests) in
                    if let error = error {
                        self.stopActivity()
                        self.showWarningMsg(error)
                    } else {
                        guard var tests = tests else {
                            self.showWarningMsg("Wrong API response")
                            self.stopActivity()
                            return
                        }
                        self.tests = tests
                        for i in tests {
                            subjectsIds.append(i.subjectId)
                        }
                        
                        DataManager.shared.getSubjectsBy(ids: subjectsIds, completionHandler: { (error, subjects) in
                            for i in 0..<tests.count {
                                let testSubj = subjects?.filter({ $0.id == tests[i].subjectId })
                                tests[i].subjectName = testSubj?.first?.name
                            }
                            DispatchQueue.main.async {
                                self.tests = tests
                                self.resultsTableView.reloadData()
                                self.refreshControl.endRefreshing()
                                self.stopActivity()
                            }
                        })
                    }
                })
                
            }
        }
    }
    
}

extension ResultByGroupViewController: UITableViewDelegate {
}

extension ResultByGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tests != nil ? tests!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reusableResultCell") as? ResultsTableTestViewCell else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "This group haven't passed tests yet!"
            return cell
        }
        cell.testIdLabel.text = tests?[indexPath.row].id
        cell.testNameLabel.text = tests?[indexPath.row].name
        cell.testSubjectNameLabel.text = tests?[indexPath.row].subjectName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "PDFPrinter", bundle: nil)
        guard let previewViewController = storyboard.instantiateViewController(withIdentifier: "PrintReportByGroupTest")
            as? PreviewViewController else { return }
        guard let test = self.tests?[indexPath.row], let group = self.group else {
            return
        }
        previewViewController.title = NSLocalizedString("Printer", comment: "")
        let quizParameters: [String: [String: String]] =
            ["Subject": ["id": test.subjectId, "name": test.subjectName!],
             "Group": ["id": group.groupId!, "name": group.groupName],
             "Quiz": ["id": test.id!, "name": test.name]]
        previewViewController.quizParameters = quizParameters
        
        self.navigationController?.pushViewController(previewViewController, animated: true)
    }
    
}

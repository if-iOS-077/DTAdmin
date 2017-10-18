//
//  AdminVC.swift
//  DTAdmin
//
//  Created by ITA student on 10/15/17.
//  Copyright © 2017 Yurii Krupa. All rights reserved.
//

import UIKit

class AdminVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var adminsListTBV: UITableView!
    
    
    var adminsList: [UserModel.Admins]?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return adminsList != nil ? adminsList!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: make cell more informative
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableAdminCell")!
        cell.textLabel?.text = adminsList![indexPath.row].username
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: send to next view -> adminsList[indexPath.row]
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteOpt = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            //TODO: delete selected admin
        }
        deleteOpt.backgroundColor = UIColor.red
        return [deleteOpt]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        MARK: DEBUG - Using for first login into system
//        NetworkManager().logIn(username: "admin", password: "dtapi_admin") { (admin, cookie) in
//            print(admin, cookie)
//            UserDefaults.standard.setUserName(name: admin.username)
//            UserDefaults.standard.setCookie(cookie)
//            UserDefaults.standard.setLoggedIn(to: true)
//       }
//        MARK: DEBUG - Using for geting list of admin
        NetworkManager().createAdmin(username: "Veselun", password: "1qaz2wsx", email: "Veselun@tuhes.com.ua")
        sleep(10)
        NetworkManager().getAdmins { (admins) in
            print(UserDefaults.standard.getCookie())
            print(admins)
                self.adminsList = admins
                self.adminsListTBV.reloadData()
        }
    }
    
}

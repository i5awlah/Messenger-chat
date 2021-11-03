//
//  NewConversationViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    var myusers = [ChatAppUser]()
    var userNames = [String]()
    
    //let tableData = ["One","Two","Three","Twenty-One"]
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    let cellID = "userCell"
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    
    
    override func viewDidLoad() {
        
        print("all user: ", userNames)
        super.viewDidLoad()
        view.addSubview(tableView)
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        tableView.reloadData()
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return userNames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
            return cell
        }
        else {
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0..<userNames.count {
            if filteredTableData[indexPath.row] == userNames[i] {
                
                let emailR = DatabaseManger.shared.safeEmail(emailAddress: myusers[i].emailAddress)
                let emailS = DatabaseManger.shared.safeEmail(emailAddress: UserDefaults.standard.value(forKey: "email") as! String)

                resultSearchController.dismiss(animated: false, completion: nil)

                let vc = ChatViewController(with: myusers[i].emailAddress, id: "conversation_\(emailR)_\(emailS)")
                vc.isNewConversation = true
                vc.title = myusers[i].firstName
                vc.modalPresentationStyle = .fullScreen
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    
}

extension NewConversationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("kk")
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (userNames as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
    
    
}

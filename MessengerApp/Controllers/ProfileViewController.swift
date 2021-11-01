//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase
import FacebookLogin

class ProfileViewController: UIViewController {
    
    var data = ["Log Out"]
    private let cellId = "profileCell"
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        return tv
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getUserData()
    }
    
    func setupUI() {
        view.backgroundColor = .orange
        title = "Profile"
        
        view.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func getUserData() {
        DatabaseManger.shared.getUser() { userInfo in
            print("Welcome: \(userInfo.firstName)")
            self.data.append(userInfo.firstName)
            self.tableView.reloadData()
        }
    }
    
    func logout() {
        
        // logout the user
        // show alert
        let actionSheet = UIAlertController(title: "Are you sure to Log Out?", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            // action that is fired once selected
            guard let strongSelf = self else {
                return
            }
            print("logout ...")
            do {
                if DatabaseManger.shared.isLoggedIn() {
                    // Show the ViewController with the logged in user
                    print("**PP** login with facebook")
                    LoginManager().logOut()
                }
                
                
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: false)
            }
            catch {
                print("failed to logout")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)

    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // unhighlight the cell
        
        if indexPath.row == 0 {
            logout()
        }
        
    }
    
}

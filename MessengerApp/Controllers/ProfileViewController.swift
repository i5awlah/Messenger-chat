//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase
import FacebookLogin
import Kingfisher

struct section {
    let title: String
    let options: [settingsOption]
}
struct settingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

class ProfileViewController: UIViewController {
    
    var models = [section]()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        iv.image = UIImage(named: "profileImage")
//        iv.layer.borderColor = UIColor.black.cgColor
//        iv.layer.borderWidth = 3
        iv.roundedImage()
        return iv
    }()
    
    private lazy var fullNameLabel = CustomLabel(text: "Welcome Back!", font: UIFont.boldSystemFont(ofSize: 20), textAlignment: .center, textColor: .black, numberOfLines: 1)
    private lazy var emailLabel = CustomLabel(text: "", font: .Regular, textAlignment: .center, textColor: .lightGray, numberOfLines: 1)
    
    private var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(customCell.self, forCellReuseIdentifier: customCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureModals()
        getUserData()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        title = "Profile"
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let mainView = UIView()
        mainView.backgroundColor = .white
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainView)
        
        mainView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mainView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.heightAnchor.constraint(equalToConstant: 280).isActive = true

        mainView.add(subview: profileImageView) { (v, p) in [
            v.topAnchor.constraint(equalTo: p.topAnchor, constant: 15),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 200)
        ]}
        
        mainView.add(subview:emailLabel) { (v, p) in [
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.bottomAnchor.constraint(equalTo: p.bottomAnchor, constant: -15)
        ]}
        mainView.add(subview:fullNameLabel) { (v, p) in [
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.bottomAnchor.constraint(equalTo: p.bottomAnchor, constant: -35)
        ]}
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func configureModals() {
        self.models.append(section(title: "Setting", options: [
            settingsOption(title: "Change Mode", icon: UIImage(systemName: "paintpalette.fill"), iconBackgroundColor: .systemGray) {
                self.changeMode()
            }
        ]))
        
        self.models.append(section(title: "Log out", options: [
            settingsOption(title: "Log out", icon: UIImage(systemName: "key.fill"), iconBackgroundColor: .systemRed) {
                self.logout()
            }
        ]))
    }
    
    func getUserData() {
        DatabaseManger.shared.getUser() { userInfo in
            print("Welcome: \(userInfo.firstName)")
            self.fullNameLabel.text = "\(userInfo.firstName) \(userInfo.lastName)"
            self.emailLabel.text = userInfo.emailAddress
            self.tableView.reloadData()
            
            let userPath = "images/" + "\(userInfo.safeEmail)_profilepicture.png"
            StorageManager.shared.downloadURL(for: userPath) { result in
                switch result {
                    case .success(let url):
                        print("This is: \(url)")
                        self.profileImageView.kf.setImage(with: url)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
            }
            
        }
        
    }
    
    func changeMode() {
        if self.view.overrideUserInterfaceStyle == .dark {
            self.view.overrideUserInterfaceStyle = .light
        } else {
            self.view.overrideUserInterfaceStyle = .dark
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: customCell.identifier, for: indexPath) as? customCell else {
            return UITableViewCell()
        }
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
}

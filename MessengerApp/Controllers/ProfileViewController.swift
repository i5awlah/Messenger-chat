//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    private lazy var logoutButton: CustomButton = {
        let btn = CustomButton(title: "Log out")
        btn.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        title = "Profile"
        
        view.add(subview: logoutButton) { (v, p) in [
            v.topAnchor.constraint(lessThanOrEqualTo: p.safeAreaLayoutGuide.topAnchor, constant: 50),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 300)
        ]}
    }
    
    @objc func logoutButtonPressed() {
        print("logoutButtonPressed")
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
        catch {
        }
    }

}

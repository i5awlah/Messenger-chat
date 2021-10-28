//
//  ConversationViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        if !isLoggedIn {
            // present login view controller
            if let loginVC = self.storyboard?.instantiateViewController(identifier: "loginVC") as? LoginViewController {
                self.navigationController?.pushViewController(loginVC, animated: false)
            }
            }
        }

}

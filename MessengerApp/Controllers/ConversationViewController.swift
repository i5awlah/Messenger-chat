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
        view.backgroundColor = .green
        title = "Chats"
        print("Conversation viewDidLoad")
        
        validateAuth()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Conversation viewDidAppear")
        
        //validateAuth()
        }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            // present login view controller
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
        else {
            print("current user is: \(FirebaseAuth.Auth.auth().currentUser?.email)")
        }
    }

}

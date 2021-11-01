//
//  ConversationViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD

class ConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
        
        private let tableView: UITableView = {
            let table = UITableView()
            table.isHidden = true // first fetch the conversations, if none (don't show empty convos)
            table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            return table
        }()
        
        private let noConversationsLabel: UILabel = {
            let label = UILabel()
            label.text = "No conversations"
            label.textAlignment = .center
            label.textColor = .gray
            label.font = .systemFont(ofSize: 21, weight: .medium)
            return label
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        title = "Chats"
        print("Conversation viewDidLoad")
        
        validateAuth()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Conversation viewDidAppear")
        
        //validateAuth()
        }
    
    @objc private func didTapComposeButton(){
            // present new conversation view controller
            // present in a nav controller
            
            let vc = NewConversationViewController()
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC,animated: true)
        }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            tableView.frame = view.bounds
        }
    
    private func setupTableView(){
            tableView.delegate = self
            tableView.dataSource = self
        }
        
        private func fetchConversations(){
            // fetch from firebase and either show table or label
            
            tableView.isHidden = false
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

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // when user taps on a cell, we want to push the chat screen onto the stack
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let vc = ChatViewController()
//        vc.title = "Jenny Smith"
//        vc.navigationItem.largeTitleDisplayMode = .never
//        navigationController?.pushViewController(vc, animated: true)
    }
}

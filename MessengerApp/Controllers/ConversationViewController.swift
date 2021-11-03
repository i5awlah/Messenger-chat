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
    
    public var allUsers = [ChatAppUser]()
    public var allUserNames = [String]()
    public var myConversation = [Conversation]()
    
    private let spinner = JGProgressHUD(style: .dark)
        
        private let tableView: UITableView = {
            let table = UITableView()
            table.isHidden = true // first fetch the conversations, if none (don't show empty convos)
            table.register(messageCell.self, forCellReuseIdentifier: messageCell.identifier)
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
        view.backgroundColor = .systemGreen
        title = "Chats"
        print("Conversation viewDidLoad")
        
        validateAuth()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.add(subview: noConversationsLabel) { v, p in [
            v.centerYAnchor.constraint(equalTo: p.centerYAnchor),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor)
        ]}
        setupTableView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Conversation viewDidAppear")
        tableView.reloadData()
        }
    
    func getUserData() {
        DatabaseManger.shared.getUser() { userInfo in
            
            let defaults = UserDefaults.standard
            defaults.set(userInfo.emailAddress, forKey: "email")
            defaults.set("\(userInfo.firstName) \(userInfo.lastName)", forKey: "name")
            defaults.set("images/" + "\(userInfo.safeEmail)_profilepicture.png", forKey: "image")

            self.getConversations()
        }
        
    }
    
    public func getConversations() {
        print("getConversations")
        let safeEmailUser = DatabaseManger.shared.safeEmail(emailAddress: UserDefaults.standard.value(forKey: "email") as! String)

        DatabaseManger.shared.getAllConversations(for: safeEmailUser) { result in
            switch result {
                case .success(let conversations):
                    
                    for i in 0..<conversations.count {
                        
                        let name = conversations[i].name
                        let id = conversations[i].id
                        let otherUserEmail = conversations[i].otherUserEmail
                        let data = conversations[i].latestMessage.date
                        let isRead = conversations[i].latestMessage.isRead
                        let text = conversations[i].latestMessage.text
                        
                        self.myConversation.append(Conversation(id: id, name: name, otherUserEmail: otherUserEmail,
                                                           latestMessage: LatestMessage(date: data, text: text, isRead: isRead)))
                    }
                    self.noConversationsLabel.isHidden = true
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    public func getAllUser() {
        spinner.show(in: self.tableView)
        DatabaseManger.shared.getAllUsers() { result in
            switch result {
                case .success(let value):
                    
                    for i in 0..<value.count {
                        //self.allUsers.append(ChatAppUser(firstName: value[i]["name"]!, lastName: "", emailAddress: value[i]["email"]!, profilePictureUrl: ""))
                        self.allUserNames.append(value[i]["name"]!)
                        self.allUsers.append(ChatAppUser(firstName: value[i]["name"]!, lastName: "", emailAddress: value[i]["email"]!, profilePictureUrl: ""))
                        
                    }
                    print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            self.spinner.dismiss()
        }
    }
    @objc private func didTapComposeButton(){
            // present new conversation view controller
            // present in a nav controller
            
            let vc = NewConversationViewController()
            vc.userNames = allUserNames
            vc.myusers = allUsers
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
            getUserData()
            getAllUser()
            
        }
    }

}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myConversation.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCell.identifier, for: indexPath) as! messageCell
        //cell.textLabel?.text = "\(myConversation[indexPath.row].name) * \(myConversation[indexPath.row].latestMessage.text)"
        cell.configure(with: "\(myConversation[indexPath.row].name)", textMSG: "\(myConversation[indexPath.row].latestMessage.text)", otherUserEmail: myConversation[indexPath.row].otherUserEmail)
        return cell 
    }
    
    // when user taps on a cell, we want to push the chat screen onto the stack
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = ChatViewController(with: myConversation[indexPath.row].otherUserEmail,
                                    id: myConversation[indexPath.row].id)

        vc.title = myConversation[indexPath.row].name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.00
    }
}

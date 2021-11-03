//
//  DatabaseManager.swift
//  MessengerApp
//
//  Created by KM on 29/10/2021.
//

import Foundation
import Firebase
import FirebaseDatabase
import FacebookLogin
// singleton creation below
// final - cannot be subclassed
final class DatabaseManger {
    
    static let shared = DatabaseManger()
    
    // reference the database below
    
    private let database = Database.database().reference()
    
    // create a simple write function
    
    
    

}
// MARK: - account management
extension DatabaseManger {
    
    // have a completion handler because the function to get data out of the database is asynchrounous so we need a completion block
    
    
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        // will return true if the user email does not exist
        
        // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        // let's observe a single event (query the database once)
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-").lowercased()
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // snapshot has a value property that can be optional if it doesn't exist
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            // if we are able to do this, that means the email exists already!
            
            completion(true) // the caller knows the email exists already
        }
    }
    
    /// Insert new user to database
//    public func insertUser(with user: ChatAppUser){
//        database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName])
//    }
    
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
            // adding completion block here so once it's done writing to database, we want to upload the image
            
            // once user object is creatd, also append it to the user's collection
            database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName]) { error, _ in
                guard error  == nil else {
                    print("failed to write to database")
                    completion(false)
                    return
                }
                
                self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                    // snapshot is not the value itself
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        // if var so we can make it mutable so we can append more contents into the array, and update it
                        // append to user dictionary
                        let newElement = [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                        usersCollection.append(newElement)
                        
                        self.database.child("users").setValue(usersCollection) { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                        
                    }else{
                        // create that array
                        let newCollection: [[String: String]] = [
                            [
                                "name": user.firstName + " " + user.lastName,
                                "email": user.safeEmail
                            ]
                        ]
                        self.database.child("users").setValue(newCollection) { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    }
                }
            }
        }
        
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
            
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    public func isLoggedIn() -> Bool {
            let accessToken = AccessToken.current
            let isLoggedIn = accessToken != nil && !(accessToken?.isExpired ?? false)
            return isLoggedIn
        }
    
    public func getUser(completion: @escaping (ChatAppUser) -> Void) {
        let userEmail = Firebase.Auth.auth().currentUser?.email
        var safeEmail = userEmail!.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["first_name"] as? String ?? ""
            let lastName = value?["last_name"] as? String ?? ""
            let user = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: userEmail!)
            completion(user)
            // ...
        }) { error in
            print(error.localizedDescription)
        }
        
    }
    
    func getUserProfile(token: AccessToken?, userId: String?, completion: @escaping (ChatAppUser) -> Void) {
        let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture, email"])
        graphRequest.start { _, result, error in
            if error == nil {
                let data: [String: AnyObject] = result as! [String: AnyObject]
                var facebookUser = ChatAppUser(firstName: "", lastName: "", emailAddress: "",profilePictureUrl: "")

                // Facebook First Name
                if let facebookFirstName = data["first_name"] as? String {
                    facebookUser.firstName = facebookFirstName
                }
                // Facebook Last Name
                if let facebookLastName = data["last_name"] as? String {
                    facebookUser.lastName = facebookLastName
                }
                // Facebook Profile Pic URL

                
                if let pictureData: [String : Any] = data["picture"] as? [String : Any]
                 {
                    print("###", pictureData)
                     if let data : [String: Any] = pictureData["data"] as? [String: Any]
                      {
                        facebookUser.profilePictureUrl = data["url"] as! String
                        print("^^^^^^^^^^^^^^^^^^^")
                       }
                 }
                
              
                //let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
                //print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
                //facebookUser.profilePictureUrl = facebookProfilePicURL
                
                // Facebook Email
                if let facebookEmail = data["email"] as? String {
                    facebookUser.emailAddress = facebookEmail
                }
                completion(facebookUser)
                
            } else {
                print("Error: Trying to get user's info")
            }
        }
    }
}
struct ChatAppUser {
    var firstName: String
    var lastName: String
    var emailAddress: String
    var profilePictureUrl: String?
    
    // create a computed property safe email
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-").lowercased()
        return safeEmail
    }
}


// MARK: - Sending Messages / conversations
extension DatabaseManger {
    
    /*  "conversation_id" {
     "messages": [
     {
     "id": String,
     "type": text, photo, video
     "content": String,
     "date": Date(),
     "sender_email": String,
     "isRead": true/false,
     }
     ]
     }
     
     
     conversation => [
     [
     "conversation_id":
     "other_user_email":
     "latest_message": => {
     "date": Date()
     "latest_message": "message"
     "is_read": true/false
     }
     
     ],
     
     ]
     
     */
    
    public func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-").lowercased()
        return safeEmail
    }
    
    /// creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        // put conversation in the user's conversation collection, and then 2. once we create that new entry, create the root convo with all the messages in it
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
              else {
            return
        }
        let safeEmail = DatabaseManger.shared.safeEmail(emailAddress: currentEmail) // cant have certain characters as keys
        
        // find the conversation collection for the given user (might not exist if user doesn't have any convos yet)
        
        let ref = database.child("\(safeEmail)")
        // use a ref so we can write to this as well
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            // what we care about is the conversation for this user
            guard var userNode = snapshot.value as? [String: Any] else {
                // we should have a user
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
            
            //
            let recipient_newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email": safeEmail, // us, the sender email
                "name": currentName,  // self for now, will cache later
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
            // update recipient conversation entry
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationId)
                }else {
                    // reciepient user doesn't have any conversations, we create them
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            }
            
            
            // update current user conversation entry
            print("@@@@ \(userNode["conversations"])")
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exits for current user, you should append
                print("I AM HERE")
                print("**conversations: \(conversations)**")
                // points to an array of a dictionary with quite a few keys and values
                // if we have this conversations pointer, we would like to append to it
                
                conversations.append(newConversationData)
                
                userNode["conversations"] = conversations // we appended a new one
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }else {
                // create this conversation
                // conversation array doesn't exist
                
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
                
            }
            
        }
        
    }
    
    private func finishCreatingConversation(name: String, conversationID:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        //        {
        //            "id": String,
        //            "type": text, photo, video
        //            "content": String,
        //            "date": Date(),
        //            "sender_email": String,
        //            "isRead": true/false,
        //        }
        
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManger.shared.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name,
        ]
        
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    /// Fetches and returns all conversations for the user with
    
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapshot in
            // new conversation created? we get a completion handler called
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                // create model
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            
            completion(.success(conversations))
            
        }
    }
    
    
    /// gets all messages from a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapshot in
            // new conversation created? we get a completion handler called
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                let isRead = dictionary["is_read"] as? Bool,
                let messageID = dictionary["id"] as? String,
                let content = dictionary["content"] as? String,
                let senderEmail = dictionary["sender_email"] as? String,
                let type = dictionary["type"] as? String,
                let dateString = dictionary["date"] as? String,
                let date = ChatViewController.dateFormatter.date(from: dateString)
                else {
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
                
            }
            
            completion(.success(messages))
            
        }
    }
    
    ///// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // return bool if successful
        
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManger.shared.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name,
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
                
            }
        
        }
    
    }
}


    struct Conversation {
        var id: String
        var name: String
        var otherUserEmail: String
        var latestMessage: LatestMessage
    }

    struct LatestMessage {
        var date: String
        var text: String
        var isRead: Bool
    }
    




/////////////////////////////////

//let newConversationData: [String:Any] = [
//    "id": conversationId,
//    "other_user_email": otherUserEmail,
//    "name": name,
//    "latest_message": [
//        "date": dateString,
//        "message": message,
//        "is_read": false,
//        
//    ],
//    
//]
//
////
//let recipient_newConversationData: [String:Any] = [
//    "id": conversationId,
//    "other_user_email": safeEmail, // us, the sender email
//    "name": currentName,  // self for now, will cache later
//    "latest_message": [
//        "date": dateString,
//        "message": message,
//        "is_read": false,
//        
//    ],
//    
//]
//// update recipient conversation entry
//
//self?.database.child("\(otherUserEmail)/conversations/iiiidddd").setValue([recipient_newConversationData])
//self?.database.child("\(email)/conversations/iiiidddd").setValue([newConversationData])


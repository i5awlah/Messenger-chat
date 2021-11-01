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
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName])
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
                var facebookUser = ChatAppUser(firstName: "", lastName: "", emailAddress: "")

                // Facebook First Name
                if let facebookFirstName = data["first_name"] as? String {
                    facebookUser.firstName = facebookFirstName
                }
                // Facebook Last Name
                if let facebookLastName = data["last_name"] as? String {
                    facebookUser.lastName = facebookLastName
                }
                // Facebook Profile Pic URL
                let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
                print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
                
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
    //let profilePictureUrl: String
    
    // create a computed property safe email
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-").lowercased()
        return safeEmail
    }
}



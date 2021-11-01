//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase
import FacebookLogin
import Kingfisher

class LoginViewController: UIViewController {
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        iv.image = UIImage(named: "profileImage")
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 3
        iv.roundedImage()
        return iv
    }()
    
    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "messengerLogo")
        return iv
    }()

    private lazy var emailImageView = CustomImageView(ivType: .email)
    private lazy var passwordImageView = CustomImageView(ivType: .password)
    
    private lazy var emailTextField = CustomTextField(tfType: .email)
    private lazy var passwordTextField = CustomTextField(tfType: .password)
    
    
    private lazy var loginButton: CustomButton = {
        let btn = CustomButton(title: "Log In")
        btn.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return btn
    }()
    

    private lazy var signupLabel: CustomLabel = {
        let lbl = CustomLabel(text: "", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)
        let attributedString = NSMutableAttributedString(string: "Don't have an account? ")
        attributedString.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)] ))
        lbl.attributedText = attributedString
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signupButtonPressed)))
        return lbl
    }()
    
    
    private let emailContainerView = UIView()
    private let passwordContainerView = UIView()
    private let loginContainerView = UIView()

    private lazy var socialLabel = CustomLabel(text: "Social Login", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)
    private lazy var facebookButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "facebookLogo"), for: .normal)
        btn.addTarget(self, action: #selector(facebookButtonPressed), for: .touchUpInside)
        return btn
    }()
    let loginFacebookButton = FBLoginButton()
    
    private lazy var googleButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "googleLogo"), for: .normal)
        btn.addTarget(self, action: #selector(googleButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    // ********************************************** viewDidLoad **********************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("login viewDidLoad")
        
        loginFacebookButton.permissions = ["public_profile", "email"]
        loginFacebookButton.delegate = self
        
        
        
          
        
        if Firebase.Auth.auth().currentUser != nil {
            if let email = Firebase.Auth.auth().currentUser?.email {
                print("there is a user \(email)")
            }
        }
    }
    
    func setupUI() {
        view.backgroundColor = .Background
        
        // logo image
        view.add(subview: logoImageView) { (v, p) in [
            v.topAnchor.constraint(lessThanOrEqualTo: p.safeAreaLayoutGuide.topAnchor, constant: 50),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 300)
        ]}
        
        // Email, Password and login Button
        let dataStackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        dataStackView.axis = .vertical
        dataStackView.distribution = .fillEqually
        dataStackView.spacing = 30
        view.addSubview(dataStackView)
        dataStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dataStackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            dataStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            dataStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
        ])
        Helper.createTextFieldWithAnchor(tf: emailTextField, iv: emailImageView, view: emailContainerView)
        Helper.createTextFieldWithAnchor(tf: passwordTextField, iv: passwordImageView, view: passwordContainerView)
        
        // Don't have an account? Sign Up
        view.add(subview: signupLabel) { v, p in [
            v.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 7),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor)
        ]}

        // social login 
        let socialLoginStackView = UIStackView(arrangedSubviews: [facebookButton, googleButton])
        socialLoginStackView.axis = .horizontal
        socialLoginStackView.distribution = .fillEqually
        socialLoginStackView.spacing = 10
        view.addSubview(socialLoginStackView)

        socialLoginStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            socialLoginStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            socialLoginStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facebookButton.widthAnchor.constraint(equalToConstant: 50),
            googleButton.widthAnchor.constraint(equalToConstant: 50),
            socialLoginStackView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        view.add(subview: socialLabel){ (v, p) in [
            v.bottomAnchor.constraint(equalTo: socialLoginStackView.topAnchor, constant: -10),
            v.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]}
        
        let lineViewL = UIView()
        lineViewL.backgroundColor = .white
        
        let lineViewR = UIView()
        lineViewR.backgroundColor = .white
        
        view.add(subview: lineViewL){ (v, p) in [
            v.bottomAnchor.constraint(equalTo: socialLoginStackView.topAnchor, constant: -15),
            v.heightAnchor.constraint(equalToConstant: 0.5),
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: socialLabel.leadingAnchor, constant: -10)
        ]}
        
        view.add(subview: lineViewR){ (v, p) in [
            v.bottomAnchor.constraint(equalTo: socialLoginStackView.topAnchor, constant: -15),
            v.heightAnchor.constraint(equalToConstant: 0.5),
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            v.leadingAnchor.constraint(equalTo: socialLabel.trailingAnchor, constant: 10)
        ]}

    }
    
    // ********************************************** func **********************************************
    
    @objc private func loginButtonPressed() {
        loginUser()
    }
    
    @objc private func signupButtonPressed() {
        openRegisterVC()
    }
    @objc private func facebookButtonPressed() {
        print("facebookButtonPressed")
        loginFacebookButton.sendActions(for: .touchUpInside)
    }
    @objc private func googleButtonPressed() {
        print("googleButtonPressed")
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            if let error = error {
                //print("Error status: \(error.localizedDescription)")
                self.showAlert(message: error.localizedDescription)
            } else {
                self.openConversationVC()
                print("Welacome \(self.emailTextField.text!) :)")
            }
        }
    }
    
    func showAlert(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    func openConversationVC() {
        let vc = tabBarVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    func openRegisterVC() {
        let vc = RegisterViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
}

extension LoginViewController : LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if result?.isCancelled ?? false {
                    print("Cancelled")
                } else if error != nil {
                    print("ERROR: Trying to get login results")
                } else {
                    print("Logged in")
                    
                    let credential = FacebookAuthProvider
                      .credential(withAccessToken: AccessToken.current!.tokenString)
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            print("%% \(error)")
                          return
                        }
                        print("%% SUCCESS!")
                        // User is signed in
                        
                        //DatabaseManger.shared.userExists
                        
                        
                        self.openConversationVC()
                        DatabaseManger.shared.getUserProfile(token: result?.token, userId: result?.token?.userID) { userInfo in
                            print("INFO: \(userInfo.emailAddress)")
                            print("INFO: \(userInfo.firstName)")
                            print("INFO: \(userInfo.lastName)")
                            DatabaseManger.shared.userExists(with: userInfo.emailAddress) { boolResult in
                                if (boolResult) {
                                    print("userExists")
                                }
                                else {
                                    print("userNotExists")
                                    DatabaseManger.shared.insertUser(with: userInfo)
                                    // take image from faceBook
                                    let facebookEmail = userInfo.emailAddress
                                    var safeEmail = facebookEmail.replacingOccurrences(of: ".", with: "-")
                                    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-").lowercased()
                                    
   
                                    let url = URL(string: userInfo.profilePictureUrl!)
                                    print("@@@@\(userInfo.profilePictureUrl!)")

                                        let data = try? Data(contentsOf: url!)

                                            self.profileImageView.image = UIImage(data: data!)
                                            let userImage = self.profileImageView.image!.pngData()
                                            let fileName = "\(safeEmail)_profilepicture.png"
                                            StorageManager.shared.uploadProfilePicture(with: userImage!, fileName: fileName) { result in
                                                switch result {
                                                    case .success(let url):
                                                        print("This is: \(url)")
                                                    case .failure(let error):
                                                        print(error.localizedDescription)
                                                    }
                                            }
                                        
                                    

                                    

                                }
                            }
                        }
                    }

                    
                }

    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    

    

    
}

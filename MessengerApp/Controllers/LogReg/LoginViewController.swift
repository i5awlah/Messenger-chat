//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "messengerLogo")
        return iv
    }()

    
    let facebookButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "facebookLogo"), for: .normal)
        btn.addTarget(self, action: #selector(facebookButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    let googleButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "googleLogo"), for: .normal)
        btn.addTarget(self, action: #selector(googleButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    
    
    private let emailImageView = CustomImageView(ivType: .email)
    private let passwordImageView = CustomImageView(ivType: .password)
    
    private lazy var emailTextField = CustomTextField(tfType: .email)
    private lazy var passwordTextField = CustomTextField(tfType: .password)
    
    
    private lazy var loginButton: CustomButton = {
        let btn = CustomButton(title: "Log In")
        btn.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    private lazy var signupLabel = CustomLabel(text: "Don't have an account?", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)
    
    private lazy var socialLabel = CustomLabel(text: "Social Login", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)

    
    private lazy var signupButton: CustomButton = {
        let btn = CustomButton(title: "Sign Up", backgroundColor: .clear)
        btn.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    private lazy var loginLabel = CustomLabel(text: "Or connect with:", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)
    
    private lazy var loginWithFacebookButton: CustomButton = {
        let btn = CustomButton(title: "Facebook")
        btn.addTarget(self, action: #selector(facebookButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    private lazy var loginWithGoogleButton: CustomButton = {
        let btn = CustomButton(title: "Google")
        btn.addTarget(self, action: #selector(googleButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    private let emailContainerView = UIView()
    private let passwordContainerView = UIView()
    private let loginContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("hello")
        if Firebase.Auth.auth().currentUser != nil {
            if let email = Firebase.Auth.auth().currentUser?.email {
                print("there is a user \(email)")
            }
            
//            let vc = ConversationViewController()
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: false)
        }
    }
    
    func setupUI() {
        view.backgroundColor = .Background
        
        view.add(subview: logoImageView) { (v, p) in [
            v.topAnchor.constraint(lessThanOrEqualTo: p.safeAreaLayoutGuide.topAnchor, constant: 50),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 300)
        ]}
        
        // Email Container
        view.add(subview: emailContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: emailTextField, iv: emailImageView, view: emailContainerView)
        
        // password Container
        view.add(subview: passwordContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: passwordTextField, iv: passwordImageView, view: passwordContainerView)
        
        
        // login
        
        view.add(subview: loginButton){ (v, p) in [
            v.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        
        // signup

        let signupStackView = UIStackView(arrangedSubviews: [signupLabel, signupButton])
        signupStackView.axis = .horizontal
        signupStackView.distribution = .equalSpacing
        view.addSubview(signupStackView)

        signupStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            signupStackView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 5),
            signupStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupStackView.widthAnchor.constraint(equalToConstant: 250),
            signupStackView.heightAnchor.constraint(equalToConstant: 30),
            signupButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        let socialLoginStackView = UIStackView(arrangedSubviews: [facebookButton, googleButton])
        socialLoginStackView.axis = .horizontal
        socialLoginStackView.distribution = .fillEqually
        socialLoginStackView.spacing = 10
        view.addSubview(socialLoginStackView)
        
        socialLoginStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            socialLoginStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            socialLoginStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            socialLoginStackView.widthAnchor.constraint(equalToConstant: 110),
            socialLoginStackView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        view.add(subview: socialLabel){ (v, p) in [
            v.bottomAnchor.constraint(equalTo: socialLoginStackView.topAnchor, constant: -10),
            v.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]}
        
        let lineView = UIView()
        lineView.backgroundColor = .white
        
        let lineView2 = UIView()
        lineView2.backgroundColor = .white
        
        view.add(subview: lineView){ (v, p) in [
            v.bottomAnchor.constraint(equalTo: socialLoginStackView.topAnchor, constant: -15),
            v.heightAnchor.constraint(equalToConstant: 0.5),
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: socialLabel.leadingAnchor, constant: -10)
        ]}
        
        view.add(subview: lineView2){ (v, p) in [
            v.bottomAnchor.constraint(equalTo: socialLoginStackView.topAnchor, constant: -15),
            v.heightAnchor.constraint(equalToConstant: 0.5),
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            v.leadingAnchor.constraint(equalTo: socialLabel.trailingAnchor, constant: 10)
        ]}

    }
    
    @objc private func loginButtonPressed() {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = emailTextField.text else {
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                return
            }
            let user = result.user
            print("logged in user: \(user)")
            // go to profile
        })
    }
    @objc private func signupButtonPressed() {
        print("signupButtonPressed")
        
        let vc = RegisterViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
        
    }
    @objc private func facebookButtonPressed() {
        print("facebookButtonPressed")
    }
    @objc private func googleButtonPressed() {
        print("googleButtonPressed")
    }
}

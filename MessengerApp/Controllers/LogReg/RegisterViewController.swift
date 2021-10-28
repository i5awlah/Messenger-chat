//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        iv.image = UIImage(named: "profileImage")
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 3
        iv.roundedImage()
        return iv
    }()
    
    private let emailImageView = CustomImageView(ivType: .email)
    private lazy var emailTextField = CustomTextField(tfType: .email)
    private let emailContainerView = UIView()
    
    private let firstNameImageView = CustomImageView(ivType: .email)
    private lazy var firstNameTextField = CustomTextField(tfType: .firstName)
    private let firstNameContainerView = UIView()
    
    private let lastNameImageView = CustomImageView(ivType: .email)
    private lazy var lastNameTextField = CustomTextField(tfType: .lastName)
    private let lastNameContainerView = UIView()
    
    private let passwordImageView = CustomImageView(ivType: .password)
    private lazy var passwordTextField = CustomTextField(tfType: .password)
    private let passwordContainerView = UIView()
    
    private lazy var registerButton: CustomButton = {
        let btn = CustomButton(title: "Register")
        btn.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    private lazy var signinLabel = CustomLabel(text: "Already have an account?", font: .Regular, textAlignment: .center, textColor: .white, numberOfLines: 1)
    
    private lazy var signinButton: CustomButton = {
        let btn = CustomButton(title: "Sign in", backgroundColor: .clear)
        btn.addTarget(self, action: #selector(signinButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .Background
        
        view.add(subview: profileImageView) { (v, p) in [
            v.topAnchor.constraint(lessThanOrEqualTo: p.safeAreaLayoutGuide.topAnchor, constant: 50),
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.widthAnchor.constraint(equalToConstant: 200)
        ]}
        
        // Email Container
        view.add(subview: emailContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: emailTextField, iv: emailImageView, view: emailContainerView)
        
        // firstName Container
        view.add(subview: firstNameContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: firstNameTextField, iv: firstNameImageView, view: firstNameContainerView)
        
        // lastName Container
        view.add(subview: lastNameContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: firstNameContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: lastNameTextField, iv: lastNameImageView, view: lastNameContainerView)
        
        // password Container
        view.add(subview: passwordContainerView){ (v, p) in [
            v.topAnchor.constraint(equalTo: lastNameContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        Helper.createTextFieldWithAnchor(tf: passwordTextField, iv: passwordImageView, view: passwordContainerView)
        
        view.add(subview: registerButton){ (v, p) in [
            v.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 30),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor, constant: 50),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -50),
            v.heightAnchor.constraint(equalToConstant: 55)
        ]}
        
        // signin

        let signinStackView = UIStackView(arrangedSubviews: [signinLabel, signinButton])
        signinStackView.axis = .horizontal
        signinStackView.distribution = .equalSpacing
        view.addSubview(signinStackView)

        signinStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            signinStackView.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 5),
            signinStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signinStackView.widthAnchor.constraint(equalToConstant: 260),
            signinStackView.heightAnchor.constraint(equalToConstant: 30),
            signinButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
    }
    
    @objc func registerButtonPressed() {
        if let email = emailTextField.text, email.count > 0,
           let password = passwordTextField.text, password.count > 0,
           let firstName = firstNameTextField.text, firstName.count > 0,
           let lastName = lastNameTextField.text, lastName.count > 0 {
            print ("Email: \(email) and Password: \(password)")
            print ("First Name: \(firstName) and Last Name: \(lastName)")
        }
    }
    
    @objc func signinButtonPressed() {
        dismiss(animated: false, completion: nil)
    }
    

}

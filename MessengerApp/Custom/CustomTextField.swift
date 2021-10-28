//
//  BaseTextField.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit

enum TextFieldType {
    case email
    case password
    case firstName
    case lastName
}

class CustomTextField: UITextField {
    
    
    init(tfType:TextFieldType) {
        super.init(frame: .zero)
        
        font = .Regular
        tintColor = .white
        textColor = .white
        backgroundColor = .clear
        
        keyboardAppearance = .dark
        keyboardType = .default
        
        var placeholderTxt = ""
                switch tfType {
                    case .email:
                        keyboardType = .emailAddress
                        placeholderTxt = "Enter a valid email"
                        autocapitalizationType = .none
                    case .firstName:
                        keyboardType = .namePhonePad
                        placeholderTxt = "Enter your first name"
                    case .lastName:
                        keyboardType = .namePhonePad
                        placeholderTxt = "Enter your last name"
                    case .password:
                        placeholderTxt = "Enter a password"
                        keyboardType = .default
                        isSecureTextEntry = true
                }
        
        attributedPlaceholder = NSAttributedString(string: placeholderTxt,
                                                   attributes: [.font : UIFont.Regular, .foregroundColor: UIColor.lightGray])

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Helper {
    static func createTextFieldWithAnchor(tf:UITextField, iv:UIImageView, view:UIView) {
        
        view.add(subview: iv){ (v, p) in [
            v.centerYAnchor.constraint(equalTo: p.centerYAnchor),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor),
            v.heightAnchor.constraint(equalTo: p.heightAnchor, multiplier: 0.5),
            v.widthAnchor.constraint(equalTo: p.heightAnchor, multiplier: 0.5)
        ]}
        
        view.add(subview: tf){ (v, p) in [
            v.topAnchor.constraint(equalTo: p.topAnchor),
            v.bottomAnchor.constraint(equalTo: p.bottomAnchor),
            v.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 20),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor, constant: -5)
        ]}
        
        view.addSeparatorLine(color: .lightGray)
    }
}





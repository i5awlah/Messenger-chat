//
//  CustomImageView.swift
//  MessengerApp
//
//  Created by KM on 28/10/2021.
//

import UIKit

enum ImageViewType {
    case email
    case password
    case name
}

class CustomImageView: UIImageView {
    init(ivType: ImageViewType) {
        super.init(frame: .zero)
        
        switch ivType {
        case .email:
            image = UIImage(systemName: "mail")
        case .password:
            image = UIImage(systemName: "lock")
        case .name:
            image = UIImage(systemName: "person")
        }
        tintColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImageView {
    func roundedImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

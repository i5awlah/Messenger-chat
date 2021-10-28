//
//  BaseButton.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit
class CustomButton : UIButton {
    init(title: String, titleColor: UIColor? = .white, backgroundColor: UIColor? = .Accent, font: UIFont? = .Regular) {
           super.init(frame: .zero)
           
           self.backgroundColor = backgroundColor
           self.setTitle(title, for: .normal)
           self.setTitleColor(titleColor, for: .normal)
           self.titleLabel?.font = font
       }
       
       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
}

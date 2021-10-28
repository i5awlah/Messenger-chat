//
//  UIFont.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit

extension UIFont {
    public class var Regular: UIFont {
        return UIFont(name: "PingFantTC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
    }
}

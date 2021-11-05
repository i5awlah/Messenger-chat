//
//  UIColor.swift
//  MessengerApp
//
//  Created by KM on 27/10/2021.
//

import UIKit

extension UIColor {
    public class var Background: UIColor {
        return UIColor(red: 0.19, green: 0.17, blue: 0.21, alpha: 1.0)
    }
    public class var Accent: UIColor {
        return UIColor(red: 0.13, green: 0.11, blue: 0.15, alpha: 1.0)
    }
    public class var Highlight: UIColor {
        return UIColor(red: 0.98, green: 0.23, blue: 0.36, alpha: 1.0)
    }
    public class var mainColor: UIColor {
        return UIColor(rgb: 0x2f3b3d)
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

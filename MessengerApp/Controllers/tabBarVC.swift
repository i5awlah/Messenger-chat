//
//  tabBarVC.swift
//  MessengerApp
//
//  Created by KM on 31/10/2021.
//

import UIKit

class tabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let conversationVC = UINavigationController(rootViewController: ConversationViewController())
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        
        conversationVC.title = "Chats"
        profileVC.title = "Profile"
        
        setViewControllers([conversationVC,profileVC], animated: true)
        
        guard let items = tabBar.items else {
            return
        }
        
        let images = ["pencil.and.ellipsis.rectangle", "person"]
        for i in 0..<items.count {
            items[i].image = UIImage(systemName: images[i])
        }

        modalPresentationStyle = .fullScreen
        
        tabBar.barTintColor = .mainColor
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().unselectedItemTintColor = UIColor(rgb: 0x999999)

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  MiainViewController.swift
//  assignment_4
//
//  Created by bacho kartsivadze on 18.12.22.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: KeyBoardViewController())
        let vc2 = UINavigationController(rootViewController: ContactsViewController())
        
        tabBar.backgroundColor = .systemBackground
        
        vc1.tabBarItem.image = UIImage(systemName: "keyboard")
        vc2.tabBarItem.image = UIImage(systemName: "person.3")
        
        vc1.title = "KeyPad"
        vc2.title = "Forecast"
        
        setViewControllers([vc1,vc2], animated: true)
    }

}

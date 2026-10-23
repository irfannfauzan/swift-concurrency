//
//  MainTabBar.swift
//  swift-concurrency
//
//  Created by Vokal-Ican on 21/10/26.
//

import UIKit

class MainTabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupUITabBar()
    }
    
    private func setupUITabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemIndigo
    }
    
    private func setupNavbar() {
        let operationQueueTab = makeNavbar(
            root: OperationQueueViewController(),
            title: "OperationQueue",
            icon: "square.stack.3d.up",
            selectedIcon: "square.stack.3d.up.fill"
        )

        let gcdTab = makeNavbar(
            root: GCDViewController(),
            title: "GCD",
            icon: "cpu",
            selectedIcon: "cpu.fill"
        )

        let asyncTab = makeNavbar(
            root: AsyncViewController(),
            title: "Async",
            icon: "bolt",
            selectedIcon: "bolt.fill"
        )
        
        viewControllers = [operationQueueTab, gcdTab, asyncTab]
    }
    
    private func makeNavbar(root: UIViewController, title: String, icon: String, selectedIcon: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: UIImage(systemName: selectedIcon))
        root.title = title
        return nav
    }
}

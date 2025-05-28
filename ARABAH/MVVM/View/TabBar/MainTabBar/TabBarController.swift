//
//  TabBarController.swift
//  ARABAH
//
//  Created by cqlios on 28/10/24.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTabBarAppearance()
    }
    private func customizeTabBarAppearance() {
        if Store.isArabicLang == false{
            let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
            myTabBarItem1.image = UIImage(named: "home1")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem1.selectedImage = UIImage(named: "home2")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
            myTabBarItem2.image = UIImage(named: "shoppingList1")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem2.selectedImage = UIImage(named: "shoppingList2")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
            myTabBarItem3.image = UIImage(named: "deals1")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem3.selectedImage = UIImage(named: "deals2")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            let myTabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
            myTabBarItem4.image = UIImage(named: "profile1")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem4.selectedImage = UIImage(named: "profile2")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
        } else {
            let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
            myTabBarItem1.image = UIImage(named: "HomeArUn")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem1.selectedImage = UIImage(named: "HomeAr")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
            myTabBarItem2.image = UIImage(named: "ShoppingAR")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem2.selectedImage = UIImage(named: "ShoppingListAr")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
            myTabBarItem3.image = UIImage(named: "DealsArUn")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem3.selectedImage = UIImage(named: "DealsAr")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            let myTabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
            myTabBarItem4.image = UIImage(named: "ProfileArUn")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            myTabBarItem4.selectedImage = UIImage(named: "ProfileAr")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
    }
}

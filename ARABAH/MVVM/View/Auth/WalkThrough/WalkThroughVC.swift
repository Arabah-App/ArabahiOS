//
//  WalkThroughVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import AdvancedPageControl

class WalkThroughVC: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var blurEffect: UIView!
    @IBOutlet weak var pageController: AdvancedPageControlView!
    @IBOutlet weak var WalkThroughCV: UICollectionView!
    
    //MARK: - VARIABLES
    var imageArray = ["W1"] //,"W2","W3"
    var selectedIndex = 0
    
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        pageController.isHidden = true
        setUp()
    }

    //MARK: - ACTIONS
    @IBAction func tapOnNextBtn(_ sender: UIButton) {
        guard let visibleItems = WalkThroughCV.indexPathsForVisibleItems.first else { return }
        let currentItem: IndexPath = visibleItems
        let nextItem = IndexPath(item: currentItem.item + 1, section: 0)
        if nextItem.item >= imageArray.count {
            let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            Store.autoLogin = true
            navigationController?.pushViewController(vc, animated: true)
        } else {
            WalkThroughCV.isPagingEnabled = false
            WalkThroughCV.scrollToItem(at: nextItem, at: .left, animated: true)
            WalkThroughCV.isPagingEnabled = true
        }
    }
    
    //MARK: FUNCTIONS
    func setUp() {
        blurEffect.layer.cornerRadius = 26
        blurEffect.layer.masksToBounds = true
        blurEffect.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        pageController.drawer.numberOfPages = imageArray.count
        pageController.drawer = ExtendedDotDrawer(numberOfPages: 3, height: 6, width: 8, space: 4, raduis: 3, currentItem: 0, indicatorColor: #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1), dotsColor: #colorLiteral(red: 0.6988376975, green: 0.6988376975, blue: 0.6988376975, alpha: 1), isBordered: false, borderColor: .gray, borderWidth: 0, indicatorBorderColor: .gray, indicatorBorderWidth: 0)
        
    }
}

//MARK: - EXTENSION
extension WalkThroughVC: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = WalkThroughCV.dequeueReusableCell(withReuseIdentifier: "WalkThroughCVC", for: indexPath) as! WalkThroughCVC
        cell.img.image = UIImage(named: imageArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: WalkThroughCV.layer.bounds.width / 1, height: WalkThroughCV.layer.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.WalkThroughCV.reloadData()
    }

}

//MARK: SCROLL VIEW DELEGATE
extension WalkThroughVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width        
        let index = Int(round(offSet/width))
        pageController.setPage(index) // This will animate the p
    }
}

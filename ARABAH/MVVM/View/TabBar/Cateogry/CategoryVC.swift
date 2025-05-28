//
//  CategoryVC.swift
//  ARABAH
//
//  Created by cqlios on 22/10/24.
//

import UIKit
import SDWebImage
import SkeletonView


class CategoryVC: UIViewController{
    //MARK: - OUTLETS
    @IBOutlet weak var txtFldSearch: UITextField!
    @IBOutlet var categoryCollection: UICollectionView!
    //MARK: - VARIABELS
    var category : [Categorys]?
    var modal : [CreateModalBody]?
    var fitlerdata : [CreateModalBody]?
    var viewModal = HomeViewModal()
    var latitude = String()
    var longitude = String()
    var isLoading: Bool = true
    private let refreshControl = UIRefreshControl()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        catelist()

        // Add Refresh Control to Collection View
        if #available(iOS 10.0, *) {
            categoryCollection.refreshControl = refreshControl
        } else {
            categoryCollection.addSubview(refreshControl)
        }

        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    @objc private func refreshData() {
        catelist()
    }

    func catelist(){
        viewModal.categoryListAPI(latitude: self.latitude,longitude: self.longitude) { dataa in
            self.category = dataa?.category ?? []
            self.categoryCollection.reloadData()
            self.isLoading = false
            self.refreshControl.endRefreshing()
        }
    }
    
//    func CreateSearch(){
//        viewModal.searchCreateAPI(name: txtFldSearch.text ?? "") { dataa in
//            self.modal = dataa
//            self.fitlerdata = dataa
//            self.categoryCollection.reloadData()
//        }
//    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let resultString = txtFldSearch.text ?? ""
//        CreateSearch()
//        return true
//    }
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: - EXTENSIONS
extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading == true {
            return 10
        } else {
            return category?.count ?? 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCVC", for: indexPath) as! CategoryCVC
        cell.categoryImg.isSkeletonable = true
        cell.categoryImg.showAnimatedGradientSkeleton()
        cell.categoryName.isSkeletonable = true
        cell.categoryName.showAnimatedGradientSkeleton()
        if isLoading != true {
            cell.categoryName.hideSkeleton()
            cell.categoryName.text = category?[indexPath.row].categoryName ?? ""
            let CatimageIndex = (imageURL) + (self.category?[indexPath.row].image ?? "")
            cell.categoryImg.sd_setImage(with: URL(string: CatimageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                // Hide skeleton after image is loaded
                cell.categoryImg.hideSkeleton()
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 174)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoading == false{
            let vc = storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
            vc.categoryID = self.category?[indexPath.row].id ?? ""
            vc.check = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

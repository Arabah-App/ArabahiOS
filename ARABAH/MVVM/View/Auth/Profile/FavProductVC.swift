//
//  FavProductVC.swift
//  ARABAH
//
//  Created by cql71 on 13/01/25.
//

import UIKit

class FavProductVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var favProdCollection: UICollectionView!
    //MARK: - VARIABLES
    var viewModal = AuthViewModal()
    var likeVM = HomeViewModal()
    var modal : [LikeProductModalBody]?
    var selectedProviderID = String()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getFavList()
    }
    //MARK: - FUCNTIONS
    func getFavList(){
        viewModal.getProductfavList { [weak self] dataa in
            self?.modal = dataa
            self?.favProdCollection.reloadData()
        }
    }
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - FUCNTION
}
//MARK: - EXTENSIONS
extension FavProductVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if modal?.count == 0 || modal?.count == nil{
            favProdCollection.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
        }else{
            favProdCollection.backgroundView = nil
            return modal?.count ?? 0
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavProductCVC", for: indexPath) as! FavProductCVC
        cell.setupObj = modal?[indexPath.row]
        if modal?[indexPath.row].status == 0 {
            cell.btnFav.isSelected = true
        }else{
            cell.btnFav.isSelected = false
        }
        cell.btnFav.tag = indexPath.row
        cell.btnFav.addTarget(self, action: #selector(BtnLike(_:)), for: .touchUpInside)
        return cell
    }
    @objc func BtnLike(_ sender:UIButton){
        likeVM.likeDeslikeAPI(productID: self.modal?[sender.tag].productID?.id ?? "") { dataa in
            CommonUtilities.shared.showAlert(message: "Product Deslike".localized(),isSuccess: .success)
            self.getFavList()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return(CGSize(width: favProdCollection.frame.width/2, height: 163))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
        vc.prodcutid = self.modal?[indexPath.row].productID?.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

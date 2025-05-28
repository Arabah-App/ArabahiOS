//
//  DealsOffVC.swift
//  ARABAH
//
//  Created by cqlios on 30/10/24.
//

import UIKit
import SDWebImage
import SkeletonView
import SafariServices

class DealsOffVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet var tbl: UITableView!
    //MARK: - VARIABELS
    var imgAry = ["Path 35032","Group 38156", "Group 38157"]
    var viewModal = HomeViewModal()
    var modal : [GetOfferDealsModalBody]?
    var isLoading = true // Track loading state
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = "Deals".localized()
        getOfferDeals()
       
    }

    //MARK: - FUNCTIONS
    func getOfferDeals() {
        viewModal.getOfferDealsAPI { [weak self] dataa in
            self?.modal = dataa
            if self?.modal?.count == 0{
                self?.tbl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                self?.tbl.backgroundView = nil
            }
            self?.isLoading = false
            self?.tbl.showsVerticalScrollIndicator = false
            self?.tbl.showsHorizontalScrollIndicator = false
            self?.tbl.reloadData()
        }
    }
    //MARK: - ACTIONS
}
//MARK: - EXTENSIONS
extension DealsOffVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading == true {
            return 10
        } else {
            return modal?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DealsOffTVC", for: indexPath) as! DealsOffTVC
        cell.imgView.isSkeletonable = true
        cell.imgView.showAnimatedGradientSkeleton()
        cell.lblName.isSkeletonable = true
        cell.lblName.showAnimatedGradientSkeleton()
        if isLoading != true {
            cell.lblName.hideSkeleton()
            cell.lblName.text = "Store Name".localized() + " \(modal?[indexPath.row].storeID?.name ?? "")" + "\n" + "Deal".localized() + " \((modal?[indexPath.row].decription ?? ""))"
            let CatimageIndex = (imageURL) + (modal?[indexPath.row].image ?? "")
            cell.imgView.sd_setImage(with: URL(string: CatimageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                // Hide skeleton after image is loaded
                cell.imgView.hideSkeleton()
            }
            
            let CatimageIndexs = (imageURL) + (modal?[indexPath.row].storeID?.image ?? "")
            cell.imageStore.sd_setImage(with: URL(string: CatimageIndexs), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                // Hide skeleton after image is loaded
                cell.imgView.hideSkeleton()
            }
        }
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let CatimageIndex = (imageURL) + (modal?[indexPath.row].image ?? "")
        if isPDF(urlString: CatimageIndex) == true {
            openPDFInSafariViewController(with: CatimageIndex)
        } else {
            let vw = self.storyboard?.instantiateViewController(identifier: "ZoomImageVC") as! ZoomImageVC
            vw.imageUrl = CatimageIndex
            self.navigationController?.pushViewController(vw, animated: true)
        }
    }

    func openPDFInSafariViewController(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    func isPDF(urlString: String) -> Bool {
        return urlString.lowercased().hasSuffix(".pdf")
    }

}


extension UIViewController {
    func showLocationAlert() {
        let alert = UIAlertController(title:"Location Services Disabled", message: "Please enable location services in Settings.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func makePhoneCall(number: String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Handle error: Unable to make a phone call
        }
    }
    func authNil(val: Bool = false){
        if Store.authToken == nil || Store.authToken == ""{
            let vc = storyboard?.instantiateViewController(withIdentifier: "WithoutAuthVC") as! WithoutAuthVC
            vc.isMoveToHome = val
            vc.modalPresentationStyle = .overCurrentContext
            vc.callback = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.isHidden = true
                UIApplication.shared.windows.first?.rootViewController = navigationController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            self.navigationController?.present(vc, animated: true)
        }else{
            
        }
    }
}

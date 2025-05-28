//
//  NotificationListVC.swift
//  ARABAH
//
//  Created by cqlios on 29/10/24.
//

import UIKit
import SDWebImage
import SkeletonView

class NotificationListVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet var notiListTbl: UITableView!
    //MARK: - VARIABELS
    var isselected = -1
    var viewmodal = AuthViewModal()
    var modal : [GetNotificationModalBody]?
    var isLoading = true // Track loading state
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authNil()
        clearBtn.setLocalizedTitleButton(key: "Clear all")
        notificaitonListAPI()
    }
    
    //MARK: - FUNTIONS
    func notificaitonListAPI(){
        viewmodal.getNotificationList { [weak self] dataa in
            self?.modal = dataa?.reversed()
            if self?.modal?.count == 0{
                self?.notiListTbl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            } else {
                self?.notiListTbl.backgroundView = nil
                self?.clearBtn.isHidden = false
            }
            self?.isLoading = false
            self?.notiListTbl.reloadData()
        }
    }
    
    func deleteNotification() {
        viewmodal.notificationDeleteAPI { dataa in
            self.notificaitonListAPI()
            self.notiListTbl.reloadData()
        }
    }
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClearAll(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "popUpVC") as! popUpVC
        vc.check = "3"
        vc.closure = {
            self.deleteNotification()
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: true)
    }
}

//MARK: - EXTENSIONS
extension NotificationListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading == true {
            return 10
        } else {
            return modal?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificaitonListTVC", for: indexPath) as! NotificaitonListTVC
        if indexPath.row == isselected {
            cell.lblName.textColor = .white
            cell.viewMain.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            cell.lblDescription.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5036878882)
            cell.lblTime.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5036878882)
        } else {
            cell.lblName.textColor = .black
            cell.viewMain.backgroundColor = UIColor.white
            cell.lblDescription.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            cell.lblTime.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
        
        cell.imgView.isSkeletonable = true
        cell.imgView.showAnimatedGradientSkeleton()
        cell.lblName.isSkeletonable = true
        cell.lblName.showAnimatedGradientSkeleton()
        cell.lblDescription.isSkeletonable = true
        cell.lblDescription.showAnimatedSkeleton()
        cell.lblTime.isSkeletonable = true
        cell.lblTime.showAnimatedSkeleton()
        
        if isLoading != true {
            cell.lblName.hideSkeleton()
            cell.lblName.text = modal?[indexPath.row].message?.replacingOccurrences(of: "Product New Price Update", with: "") ?? ""
            let CatimageIndex = (imageURL) + (modal?[indexPath.row].image ?? "")
            cell.imgView.sd_setImage(with: URL(string: CatimageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                // Hide skeleton after image is loaded
                cell.imgView.hideSkeleton()
            }
            cell.lblTime.hideSkeleton()
            let formato = DateFormatter()
            formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            formato.formatterBehavior = .default
            let date = formato.date(from: modal?[indexPath.row].createdAt ?? "")!
            if Store.isArabicLang == true{
                formato.locale = Locale(identifier: "ar")
            }else{
                formato.locale = Locale(identifier: "en")
            }
            formato.timeZone = TimeZone.current
            formato.dateFormat = "hh:mm a"
            cell.lblTime.text = formato.string(from: date)
            cell.lblDescription.hideSkeleton()
            let currentLang = L102Language.currentAppleLanguageFull()
            switch currentLang {
            case "ar":
                cell.lblDescription.text = modal?[indexPath.row].description_Arabic ?? ""
            default:
                cell.lblDescription.text = modal?[indexPath.row].description ?? ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isselected = indexPath.row
        let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
        vc.prodcutid = modal?[indexPath.row].productID ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        notiListTbl.reloadData()
    }
}

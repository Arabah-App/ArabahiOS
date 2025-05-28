//
//  ReviewVC.swift
//  VenteUser
//
//  Created by cqlpc on 23/10/24.
//

import UIKit
import SDWebImage

class ReviewVC: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var lblAvgRating: UILabel!
    @IBOutlet weak var lblTotalCountReview: UILabel!
    @IBOutlet weak var reviewTbl: UITableView!
    //MARK: - VARIABELS
    var viewModal = AuthViewModal()
    var productID = String()
    var ratinglist: [Ratinglist]?
    var modal : GetRaitingModalBody?
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        reviewlistAPI()
    }
    //MARK: - FUCNTIONS
    func reviewlistAPI(){
        viewModal.raitingListAPI(productId: self.productID) { dataa in
            self.ratinglist = dataa?.ratinglist ?? []
            if self.ratinglist?.count == 0{
                self.reviewTbl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                self.reviewTbl.backgroundView = nil
            }
            self.modal = dataa
            self.lblAvgRating.text = "\(dataa?.averageRating ?? 0.0)"
            self.lblTotalCountReview.text = "\(dataa?.ratingCount ?? 0) Ratings"
            self.reviewTbl.reloadData()
        }
    }
    //MARK: ACTIONS
    @IBAction func didTapAddReviewBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
        vc.productID = self.productID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: EXTENSION TABLE VIEW
extension ReviewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 2
//        } else {
//            return 3
//        }
        return ratinglist?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reviewTbl.dequeueReusableCell(withIdentifier: "ReviewTVC", for: indexPath) as! ReviewTVC
        let image = (imageURL) + (ratinglist?[indexPath.row].userID?.image ?? "")
        cell.userImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.userImg.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
        cell.userNameLbl.text = ratinglist?[indexPath.row].userID?.name ?? ""
        cell.reviewLbl.text = ratinglist?[indexPath.row].review ?? ""
        cell.ratingView.rating = Double(ratinglist?[indexPath.row].rating ?? 0)
        let formato = DateFormatter()
        formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formato.formatterBehavior = .default
        let date = formato.date(from: ratinglist?[indexPath.row].createdAt ?? "")
        formato.timeZone = TimeZone.current
        formato.dateFormat = "MMM,dd yyyy"
        cell.reviewDateLbl.text = formato.string(from: date ?? Date())
        return cell
    }
    
}

//
//  FaqVC.swift
//  Wimbo
//
//  Created by cqlnitin on 21/12/22.
//

import UIKit

class FaqVC: UIViewController {
    
    //MARK: - OUTLET
    @IBOutlet weak var faqTableView: UITableView!
    
    //MARK: - VARIABLE
    var selectIndex = -1
    var viewModal = AuthViewModal()
    var modal : [FaqModalBody]?
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        faqlist()
    }
    func faqlist(){
        viewModal.getFaqListAPi { [weak self] dataa in
            self?.modal = dataa
            self?.faqTableView.reloadData()
        }
    }

    //MARK: - ACTION
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - EXTENSION OF TABLEVIEW DELEGATE & DATASOURCE
extension FaqVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modal?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaqTVC", for: indexPath) as! FaqTVC
        cell.FaqHeadingLbl.text = modal?[indexPath.row].question ?? ""
        cell.lblBody.text = selectIndex == indexPath.row ? modal?[indexPath.row].answer ?? "" : ""
        cell.imgArrow.image = selectIndex == indexPath.row ? UIImage(named: "ic_arrow_up") : UIImage(named: "ic_arrow_down")
        cell.onClickBtn.addTarget(self, action: #selector(tickUntick), for: .touchUpInside)
        cell.onClickBtn.tag = indexPath.row
        if cell.lblBody.text == "" {
            cell.mainVw.cornerRadius = 16
        } else {
            cell.mainVw.cornerRadius = 6
        }
        return cell
    }
}

//MARK: OBJECTIVE FUCTIONS
extension FaqVC {
    @objc func tickUntick(sender:UIButton){
        selectIndex = (sender.tag == selectIndex) ? -1 : sender.tag
        self.faqTableView.reloadData()
    }
}

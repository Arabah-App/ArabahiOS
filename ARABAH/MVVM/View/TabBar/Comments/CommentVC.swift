//
//  CommentVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit

class CommentVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var tblViewComment: UITableView!
    //MARK: - VARIABELS
    var comments: [CommentElement]?
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //MARK: - ACTIONS
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: - EXTENSIOSN
extension CommentVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments?.count == 0{
            tblViewComment.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
        }else{
            tblViewComment.backgroundView = nil
            return comments?.count ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentAllTVC", for: indexPath) as! CommentAllTVC
        cell.setupObj = comments?[indexPath.row]
        return cell
    }
}

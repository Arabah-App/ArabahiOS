//
//  RaiseTicketVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit

class RaiseTicketVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var ticketTblView: UITableView!
    //MARK: - VARIABLES
    var viewModal = HomeViewModal()
    var modal : [getTicketModalBody]?
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        ticketListAPI()
    }
    //MARK: - FUCNTIONS
    func ticketListAPI(){
        viewModal.getTicketAPI { [weak self] dataa in
            self?.modal = dataa
            self?.ticketTblView.reloadData()
        }
    }
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapAddTicketBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddTicketVC") as! AddTicketVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - EXTENSIONS
extension RaiseTicketVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if modal?.count == 0{
            ticketTblView.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
        }else{
            ticketTblView.backgroundView = nil
            return modal?.count ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaiseTicketTVC", for: indexPath) as! RaiseTicketTVC
         cell.lblDescription.text = modal?[indexPath.row].description ?? ""
        let formato = DateFormatter()
        formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formato.formatterBehavior = .default
        let date = formato.date(from: modal?[indexPath.row].createdAt ?? "")!
        formato.timeZone = TimeZone.current
        formato.dateFormat = "dd/MM/yyyy"
        cell.lblDate.text = formato.string(from: date)
        cell.ticketLbl.text = modal?[indexPath.row].title ?? ""
        //cell.ticketLbl.text = "Ticket \(indexPath.row+1)"
        return cell
    }
}

//
//  NotesListingVC.swift
//  ARABAH
//
//  Created by cql71 on 30/01/25.
//

import UIKit

class NotesListingVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var txtFldSearch: UITextField!
    @IBOutlet weak var NotesTblVieww: UITableView!
    //MARK: - VARIABLES
    var viewModal = HomeViewModal()
    var modal : [GetNotesModalBody]?
    var filterModal : [NotesText]?
    var notesText: [NotesText]?
    
    var filteredModal: [GetNotesModalBody] = []
    var isSearching = false
    
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFldSearch.delegate = self
        txtFldSearch.addTarget(self, action: #selector(searchNotes), for: .editingChanged)
    }
    
    @objc func searchNotes() {
        guard let searchText = txtFldSearch.text?.lowercased(), !searchText.isEmpty else {
            isSearching = false
            filteredModal = modal ?? []
            NotesTblVieww.reloadData()
            return
        }
        isSearching = true
        filteredModal = modal?.filter { note in
            note.notesText?.contains { $0.text?.lowercased().contains(searchText) == true } ?? false
        } ?? []
        
        NotesTblVieww.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getNotsList()
    }
    //MARK: - FUCNTIONS
    func getNotsList(){
        self.modal?.removeAll()
        viewModal.getNotesAPI { [weak self] dataa in
            self?.modal = dataa
            self?.filterModal = dataa?.flatMap { $0.notesText ?? [] }.reversed()
            self?.notesText = dataa?.flatMap { $0.notesText ?? [] }
            self?.NotesTblVieww.reloadData()
        }
    }
    func deleteList(id:String){
        viewModal.notesDeleteAPI(id: id) { dataa in
            CommonUtilities.shared.showAlert(message: "Delete Note", isSuccess: .success)
            self.getNotsList()
        }
    }
    //MARK: - ACTIONS
    @IBAction func btnAdd(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - EXTENSIONS
extension NotesListingVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredModal.count : (modal?.count ?? 0)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesListingTVC", for: indexPath) as! NotesListingTVC
        let note = isSearching ? filteredModal[indexPath.row] : modal?[indexPath.row]
        
        if let notes = note?.notesText, !notes.isEmpty {
            cell.lblFirstTittle.text = notes[0].text ?? ""
            cell.lblScondTittle.text = notes.count >= 2 ? notes[1].text ?? "" : "No additional text"
        }
        let formato = DateFormatter()
        formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        formato.formatterBehavior = .default
        if let createdAt = note?.createdAt, let date = formato.date(from: createdAt) {
            formato.timeZone = TimeZone.current
            formato.dateFormat = "hh:mm a"
            cell.lblTime.text = formato.string(from: date)
        } else {
            cell.lblTime.text = "--"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
        vc.notesId = self.modal?[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let count = filterModal?.count ?? 0
        if indexPath.row == 0 || indexPath.row == count{
            return UISwipeActionsConfiguration()
        } else {
            let deleteAction = UIContextualAction(style: .destructive, title: "", handler: {a,b,c in
                let vc = self.storyboard?.instantiateViewController(identifier: "popUpVC") as! popUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.check = "4"
                vc.closure = {
                    let getid = self.modal?[indexPath.row].id ?? ""
                    self.deleteList(id: getid)
                    self.modal?.remove(at: indexPath.row)
                    self.NotesTblVieww.deleteRows(at: [indexPath], with: .automatic)
                }
                self.present(vc, animated: true)
            })
            deleteAction.image = UIImage(named: "deleteBtn")
            deleteAction.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
}
extension NotesListingVC:UITextFieldDelegate{
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearching = false
        filteredModal = modal ?? []
        NotesTblVieww.reloadData()
        return true
    }
}

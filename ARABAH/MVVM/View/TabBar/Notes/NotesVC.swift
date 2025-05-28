import UIKit
import IQKeyboardManagerSwift

struct NotesCreate: Codable {
    var text: String?
}

class NotesVC: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var notesTbl: UITableView!
    
    //MARK: - VARIABLES
    var texts = [NotesCreate(text: "")]
    var viewModal = HomeViewModal()
    var notesId = String()
    
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTbl.delegate = self
        notesTbl.dataSource = self
        Notesdetail() // Fetch previous notes
//        notesTbl.estimatedRowHeight = 26
    }
    
    //MARK: - FETCH NOTES LIST
    func createNoteGetListingAPI() {
        viewModal.CreateNotesgetListAPI { [weak self] dataa in
            guard let self = self else { return }
            if let notesData = dataa, !notesData.isEmpty {
                self.texts = notesData.compactMap { NotesCreate(text: $0.text) }
            } else {
                self.texts = [NotesCreate(text: "")]
            }
            DispatchQueue.main.async {
                self.notesTbl.reloadData()
            }
        }
    }
    
    //MARK: - FETCH PREVIOUS NOTES DETAIL
    func Notesdetail() {
        viewModal.getNotesDetailAPI(id: notesId) { [weak self] dataa in
            guard let self = self else { return }
            if let notesArray = dataa?.notesText, !notesArray.isEmpty {
                self.texts = notesArray.map { NotesCreate(text: $0.text) }
            } else {
                self.texts = [NotesCreate(text: "")]
            }
            DispatchQueue.main.async {
                self.notesTbl.reloadData()
            }
        }
    }
    
    //MARK: - CREATE NOTES API CALL
    func createNotes(text: [NotesCreate]) {
        viewModal.createNotesAPI(text: text, id: self.notesId) { [weak self] _ in
            guard let self = self else { return }
            self.createNoteGetListingAPI()
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func btnDone(_ sender: UIButton) {
        let nonEmptyNotes = texts.filter { !($0.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) }
        createNotes(text: nonEmptyNotes)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - EXTENSIONS
extension NotesVC: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTVC", for: indexPath) as! NotesTVC
       cell.txtView.isScrollEnabled = false
        let noteText = texts[indexPath.row].text ?? ""
        if noteText.isEmpty {
            cell.txtView.text = "Enter text here..."
            cell.txtView.textColor = .lightGray
        } else {
            cell.txtView.text = noteText
            cell.txtView.textColor = .black
        }
        cell.txtView.delegate = self
        cell.txtView.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
    // MARK: - UITextViewDelegate Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter text here..." {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let updatedText = textView.text.trimmingCharacters(in: .whitespaces)
        if updatedText.isEmpty {
            textView.text = "Enter text here..."
            textView.textColor = .lightGray
        } else {
            if texts.count > textView.tag {
                texts[textView.tag].text = updatedText
            } else {
                texts.append(NotesCreate(text: updatedText))
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text else { return true }
        
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if let currentCell = self.notesTbl.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as? NotesTVC {
            texts[textView.tag].text = newText // Store full updated text
            self.notesTbl.beginUpdates()
            self.notesTbl.endUpdates()
        }
        
        // Handle Enter Key ("Return" key)
        if text == "\n" {
            let enteredText = newText.trimmingCharacters(in: .whitespaces)
            if !enteredText.isEmpty {
                texts[textView.tag].text = enteredText
            }
            // Append new empty row
            texts.append(NotesCreate(text: ""))
            
            DispatchQueue.main.async {
                self.notesTbl.reloadData()
                let nextIndex = textView.tag + 1
                if let nextCell = self.notesTbl.cellForRow(at: IndexPath(row: nextIndex, section: 0)) as? NotesTVC {
                    nextCell.txtView.becomeFirstResponder()
                }
            }
            return false
        }
        
        // Handle Backspace When Text is Empty
        if text.isEmpty, newText.isEmpty {
            let index = textView.tag
            if texts.count > 1 {
                texts.remove(at: index) // Remove empty row
                DispatchQueue.main.async {
                    self.notesTbl.reloadData()
                    let prevIndex = index - 1
                    if prevIndex >= 0, let prevCell = self.notesTbl.cellForRow(at: IndexPath(row: prevIndex, section: 0)) as? NotesTVC {
                        prevCell.txtView.becomeFirstResponder()
                    }
                }
            }
            return false
        }
        
        return true
    }
}

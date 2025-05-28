import UIKit

class ChangeLangVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var lblEnglish: UILabel!
    @IBOutlet var lblArbic: UILabel!
    @IBOutlet var viewEng: UIView!
    @IBOutlet var viewArabic: UIView!

    //MARK: - VARIABLES
    var viewModal = HomeViewModal()

    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelectedLanguage(Store.isArabicLang)  // Initial setup
        lblEnglish.text = "English".localized()
        lblArbic.text = "Arabic".localized()
    }

    //MARK: - FUNCTIONS
    func setSelectedLanguage(_ isArabic: Bool) {
        Store.isArabicLang = isArabic
        if isArabic {
            viewArabic.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1) // Fill Arabic view
            viewArabic.layer.borderColor = UIColor.clear.cgColor
            lblArbic.textColor = .white
            viewEng.backgroundColor = .clear
            viewEng.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            viewEng.layer.borderWidth = 2
            lblEnglish.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        } else {
            viewEng.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1) // Fill English view
            viewEng.layer.borderColor = UIColor.clear.cgColor
            lblEnglish.textColor = .white
            viewArabic.backgroundColor = .clear
            viewArabic.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            viewArabic.layer.borderWidth = 2
            lblArbic.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        }
    }
    

    //MARK: - ACTIONS
    @IBAction func BtnArabic(_ sender: UIButton) {
        setSelectedLanguage(true)
    }

    @IBAction func BtnEng(_ sender: UIButton) {
        setSelectedLanguage(false)
    }

    @IBAction func BtnUpdate(_ sender: UIButton) {
        let selectedLang = Store.isArabicLang ? "ar" : "en"
        L102Language.setAppleLAnguageTo(lang: selectedLang)
        Bundle.setLanguage(lang: selectedLang)
        Bundle.setLanguage(Store.isArabicLang ? "ar" : "en")
        UIView.appearance().semanticContentAttribute = Store.isArabicLang ? .forceRightToLeft : .forceLeftToRight
//        UITextField.appearance().semanticContentAttribute = Store.isArabicLang ? .forceRightToLeft : .forceLeftToRight
//        UITextView.appearance().semanticContentAttribute = Store.isArabicLang ? .forceRightToLeft : .forceLeftToRight
        UINavigationBar.appearance().semanticContentAttribute = Store.isArabicLang ? .forceRightToLeft : .forceLeftToRight

        viewModal.chagneLangApi(type: selectedLang) { _ in
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            let nav = UINavigationController(rootViewController: redViewController)
            nav.isNavigationBarHidden = true
            UIApplication.shared.windows.first?.rootViewController = nav
        }
    }

    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

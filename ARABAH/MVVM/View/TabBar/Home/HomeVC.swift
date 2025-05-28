//
//  HomeVC.swift
//  VenteUser
//
//  Created by cqlpc on 24/10/24.
//

import UIKit
import GooglePlaces
import SwiftyJSON

var curntLoca = String()
class HomeVC: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var textFieldSeach: UITextField!
    @IBOutlet weak var homeTbl: UITableView!
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var labelUsername: UILabel!
    //MARK: VARIABLES
    @IBOutlet weak var lblLocation: UILabel!
    var viewModal = HomeViewModal()
    var banner : [Banner]?
    var category : [Categorys]?
    var latProduct : [LatestProduct]?
    var section = ["banner".localized(), "Categories".localized(), "Latest Products".localized()]
    var latitude = String()
    var longitude = String()
    var locationManager = CLLocationManager()
    var apiCalled: Bool = false
    var isLoading = true

    
    //MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if SocketIOManager.sharedInstance.socket.status != .connected {
            SocketIOManager.sharedInstance.connectSocket()
        }
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Add Refresh Control to Collection View
        if #available(iOS 10.0, *) {
            homeTbl.refreshControl = refreshControl
        } else {
            homeTbl.addSubview(refreshControl)
        }

        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    

    @objc private func refreshData() {
        apiCalled = true
        apiCall()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLoading == true {
            homeTbl.reloadData()
        }

        if Store.isArabicLang == true{
            textFieldSeach.textAlignment = .right
        }else{
            textFieldSeach.textAlignment = .left
        }

        if let userData = Store.userDetails?.body {
            if userData.name != "" {
                self.labelUsername.text = "Hello".localized() + " \(userData.name ?? "")"
            } else {
                self.labelUsername.text = "Hello".localized()
            }
        }
    }
    
    func apiCall(category: String? = nil, categoryName:String? = nil) {
        viewModal.homeListAPI(latitude: self.latitude, longitude: self.longitude,categoryID: category){ dataa in
            if self.latProduct?.count == 0{
                self.homeTbl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                self.homeTbl.backgroundView = nil
            }
            self.banner = dataa?.banner ?? []
            self.category = dataa?.category ?? []
            self.latProduct = dataa?.latestProduct ?? []
            self.isLoading = false
            self.refreshControl.endRefreshing()
            self.homeTbl.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    //MARK: - ACTIONS
    @IBAction func BtnLcoation(_ sender: UIButton) {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    @IBAction func btnNotificaiton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnSearch(_ sender: UIButton) {
        if Store.authToken == nil || Store.authToken == "" {
            self.authNil()
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SearchCategoryVC") as! SearchCategoryVC
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @IBAction func btnScane(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ScannerVC") as! ScannerVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnFitler(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        vc.latitude = self.latitude
        vc.longitude = self.longitude
        vc.callback = { [weak self] categoryId,isclear in
            if isclear == true{
                self?.apiCall()
            }else{
                self?.apiCall(category: categoryId)
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: false)
    }
}
//MARK: EXTENSION TABLE VIEW
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
            let cell = homeTbl.dequeueReusableCell(withIdentifier: "BannerTVC", for: indexPath) as! BannerTVC
            return cell
        } else {
            let cell = homeTbl.dequeueReusableCell(withIdentifier: "HomeTVC", for: indexPath) as! HomeTVC
            cell.isLoading = isLoading
            cell.btnSeeAll.setLocalizedTitleButton(key: "See all")
            cell.banner = self.banner
            cell.category = self.category
            cell.latProduct = self.latProduct
            cell.homeColl.reloadData()
            cell.homeColl.tag = indexPath.section
            cell.btnSeeAll.tag = indexPath.section
            cell.btnSeeAll.addTarget(self, action: #selector(seeAllBtnTapped(_ :)), for: .touchUpInside)
            cell.headerLbl.text = section[indexPath.section]
            cell.sectionTitle = section[indexPath.section]
            return cell
        }
    }
    @objc func seeAllBtnTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
            vc.check = 3
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.frame.size.width / 2
        } else if indexPath.section == 1 {
            if self.category?.count ?? 0 <= 2{
                return 210
            }else{
                return 352
            }
        } else if indexPath.section == 2 {
            return 192
        } else {
            return 305
        }
    }
}
extension HomeVC : GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.latitude = String(place.coordinate.latitude)
        self.longitude = String(place.coordinate.longitude)
        getAddressFromLatLon(pdblLatitude: self.latitude, withLongitude: self.longitude)
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error GMSAutocompleteViewController: ", error.localizedDescription)
        dismiss(animated: true, completion: nil)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String){
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)") ?? 00
        //21.228124
        let lon: Double = Double("\(pdblLongitude)") ?? 00
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        let locale = Locale(identifier: Locale.preferredLanguages.first ?? "en")
        ceo.reverseGeocodeLocation(loc, preferredLocale: locale, completionHandler: { (placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            if placemarks != nil
            {
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    curntLoca = pm.country ?? ""
                    self.lblLocation.text = pm.locality
                }
            }
        })
    }
}
extension HomeVC: CLLocationManagerDelegate{
    // Check Location Authorization
    func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            // Request when-in-use authorization
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Show alert and redirect to settings
            showLocationSettingsAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            // Start updating location
            locationManager.startUpdatingLocation()
            //apiCall()
        @unknown default:
            break
        }
    }
    // Show alert to redirect to settings
    func showLocationSettingsAlert() {
        let alert = UIAlertController(
            title: "Location Permission Required".localized(),
            message: "Location access is required to use this feature. Please enable location permissions in Settings.".localized(),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings".localized(), style: .default, handler: { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = String(location.coordinate.latitude)
            self.longitude = String(location.coordinate.longitude)
            getAddressFromLatLon(pdblLatitude: self.latitude, withLongitude: self.longitude)
            if !apiCalled {
                apiCalled = true
                apiCall()
            }
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

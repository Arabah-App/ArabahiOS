//
//  Extension.swift
//  metabolisium_Diet
//
//  Created by apple on 15/07/22.
//

import Foundation
import UIKit
import PhoneNumberKit
//import SDWebImage

extension UIView {
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color
        switch side {
        case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
        }
        layer.addSublayer(border)
    }
}

extension String {
    func IsEmpty() -> Bool {
        if self.count == 0 || self.trimmingCharacters(in: .whitespaces).isEmpty == true{
            return true
        }else {
            return false
        }
    }
}

//extension UIView {
//  func addDashedBorder() {
//    let color = UIColor.black.cgColor
//    let shapeLayer:CAShapeLayer = CAShapeLayer()
//    let frameSize = self.frame.size
//    let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
//    shapeLayer.bounds = shapeRect
//    shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
//    shapeLayer.fillColor = UIColor.clear.cgColor
//    shapeLayer.strokeColor = color
//    shapeLayer.lineWidth = 1
//    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
//    shapeLayer.lineDashPattern = [6,3]
//    shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
//    self.layer.addSublayer(shapeLayer)
//    }
//}
extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
    }

}

//extension UIImageView{
//    func loadImage(baseUrl:String,imageUrl:String,color:SDWebImageActivityIndicator = .gray) {
//        self.sd_imageIndicator = color
//        self.sd_imageIndicator?.startAnimatingIndicator()
//        self.sd_setImage(with: URL(string:baseUrl + imageUrl.replacingOccurrences(of: " ", with: "%20")),placeholderImage: UIImage(named: "Placeholder")) { (img, err, type, urll) in
//            if img == nil {
//                self.backgroundColor = .gray
//            }
//            self.sd_imageIndicator?.stopAnimatingIndicator()
//        }
//    }
//}

extension UITextField {
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self.text)
    }
    
    func isValidPhone() -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with:self.text ?? "")
        return result
    }
    
    func isEmpty() -> Bool {
        if self.text == nil || self.text == "" || self.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return true
        }
        return false
    }
}


extension Date{
    func datesFormat(dateStr: String) -> Date{
        let formatter = DateFormatter()
    //            formatter.dateFormat = "hh:mm a"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return Date()
    }
    
    func dateToString(formater:String = "yyyy-MM-dd HH:mm:ss") -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formater //yyyy-MM-dd///this is you want to convert format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //.current  //
        let dateStamp = dateFormatter.string(from: self)
        return dateStamp
    }
}
var rootController1:UIViewController?{
    if let window =  UIApplication.shared.windows.first(where: { $0.isKeyWindow}){
        return window.rootViewController
     }
    return UIViewController()
}

extension String {
    var onlyAlphabet: Bool{
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z- -].*", options: [])
        if regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil {
            return false
        }else{
            return true
        }
    }
    
    func convertToFormattedDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
//    func decodeStr() -> String? {
//        let data = self.data(using: .utf8)!
//        return String(data: data, encoding: .nonLossyASCII)
//    }
    func decodeUnicode() -> String {
            let transformed = self.applyingTransform(.init("Hex-Any"), reverse: false)
            return transformed ?? self
        }
}

extension UIButton {
    func setLocalizedTitleButton(key: String) {
        let buttonText = key.localized()
        let myAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.set,
            .underlineStyle: NSUnderlineStyle.single.rawValue  // Add this line for underlining
        ]
        let myAttrString = NSAttributedString(string: buttonText, attributes: myAttribute)
        
        DispatchQueue.main.async {
            self.setAttributedTitle(myAttrString, for: .normal)
        }
    }
}

extension UILabel {
    func setLocalizedTitle(key: String) {
        let labelText = key.localized()
        let myAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,  // Use an actual color instead of UIColor.set
            //.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let myAttrString = NSAttributedString(string: labelText, attributes: myAttribute)
        DispatchQueue.main.async {
            self.attributedText = myAttrString // Correct method for UILabel
        }
    }
}
extension Sequence where Element: Hashable {
    func uniquedd() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension String{
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }

    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    func removeHtmlFromString(inPutString: String) -> String{
        return inPutString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    func getHtmlStringInWhite(fontSize:Int) -> String{
        let finalString = "<html><body style=\" font-size: \(fontSize); font-family: Play; color: #ffffff\">\(self)</body></html>"
        return finalString
    }

    func getHtmlStringInBlack(fontSize:Int) -> String{
        let finalString = "<html><body style=\" font-size: \(fontSize); font-family: Play; color: #000000\">\(self)</body></html>"
        return finalString
    }

}

extension UITableView {
    func setNoDataMessage(_ message: String,txtColor : UIColor = .black,yPosition : CGFloat = -50) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        let imageOrGifName = "nodataFound"
        // if let imageOrGifURL = Bundle.main.url(forResource: imageOrGifName, withExtension: "gif") ?? Bundle.main.url(forResource: imageOrGifName, withExtension: "png") {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Nodata")
        //sd_setImage(with: imageOrGifURL)
        view.addSubview(imageView)
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = txtColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.sizeToFit()
        view.addSubview(messageLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yPosition), // Adjust this value for vertical positioning
            imageView.widthAnchor.constraint(equalToConstant: 200), // Adjust the width as needed
            imageView.heightAnchor.constraint(equalToConstant: 150), // Adjust the height as needed
            
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.widthAnchor.constraint(equalToConstant: self.bounds.width - 60), // Adjust the width as needed
        ])
        self.backgroundView = view
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

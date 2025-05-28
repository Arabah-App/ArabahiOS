import UIKit
import Charts
import SDWebImage
import IQTextView
import SwiftyJSON
import RangeSeekSlider

class SubCatDetailVC: UIViewController, SocketDelegate, RangeSeekSliderDelegate, UITextViewDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var lblProductUnit: UILabel!
    @IBOutlet weak var btnNotifyMe: UIButton!
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var offerSeeAll: UIButton!
    @IBOutlet weak var btnSeeCommnet: UIButton!
    @IBOutlet weak var btnSellSimilarPrdouct: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var newSliderRange: UISlider!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var lblTotalCountOffer: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblLastPUpdate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblProductKgMl: UILabel!
    @IBOutlet weak var lblTotalRaitingReview: UILabel!
    @IBOutlet weak var lblProName: UILabel!
    @IBOutlet weak var chartVW: LineChartView!
    @IBOutlet weak var OfferTblView: UITableView!
    @IBOutlet weak var offerTblHeight: NSLayoutConstraint!
    @IBOutlet weak var BannerCollection: UICollectionView!
    @IBOutlet weak var similarProColl: UICollectionView!
    @IBOutlet weak var commentTbl: UITableView!
    @IBOutlet weak var commentTblHeight: NSLayoutConstraint!
    @IBOutlet weak var pgController: UIPageControl!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var greenVw: UIView!
    @IBOutlet weak var redVw: UIView!
    @IBOutlet weak var txtView: IQTextView!
    @IBOutlet weak var lblLowPrice: UILabel!
    @IBOutlet weak var slider: RangeSeekSlider!
    @IBOutlet weak var lblHighPrice: UILabel!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var viewPriceHisHeight: NSLayoutConstraint!
    @IBOutlet weak var viewPriceHistory: UIView!
    @IBOutlet weak var viewHistoryPrice: CustomView!
    @IBOutlet weak var viewHistoryPriceHieght: NSLayoutConstraint!
    @IBOutlet weak var viewMultiColor: UIView!
    
    //MARK: VARIABLES
    var viewModal = AuthViewModal()
    var LikeVM = HomeViewModal()
    var modal : ProductDetailModalBody?
    var similarProducts: [SimilarProduct]?
    var comments: [CommentElement]?
    var product: [HighestPriceProductElement]?
    var comentModal : CommentModal?
    var priceHistory :[Pricehistory]?
    var prodcutid = String()
    let floatingValueView = UILabel()
    var productQty = String()
    var btnCheck:Bool = true
    var minVal = 0
    var maxVal = 0
    var qrCode: String = ""
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if qrCode != "" {
            detailFetchQrAPI(id: self.qrCode)
        } else {
            detailFetchAPI(id: self.prodcutid)
        }
        
        btnNotifyMe.backgroundColor = .white
        btnNotifyMe.setTitleColor(.set, for: .normal)
        btnNotifyMe.layer.borderWidth = 1
        btnNotifyMe.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        txtView.placeholder = "Write here...".localized()
        lblHistory.text = "Historical Price".localized()
        offerSeeAll.setLocalizedTitleButton(key: "See all")
        btnSeeCommnet.setLocalizedTitleButton(key: "See all")
        btnSellSimilarPrdouct.setLocalizedTitleButton(key: "See all")
        lblHeader.text = "Details".localized()
        lblTotalCountOffer.text = "Offers".localized()
        slider.enableStep = false
        slider.delegate = self
        slider.disableRange = true
        slider.hideLabels = true
        slider.selectedHandleDiameterMultiplier = 1
        floatingValueView.frame = CGRect(x: 0, y: -13
                                         , width: 150, height: 30)
        floatingValueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        floatingValueView.layer.cornerRadius = 15
        floatingValueView.layer.masksToBounds = true
        floatingValueView.textAlignment = .center
        floatingValueView.font = UIFont.systemFont(ofSize: 14)
        self.viewSlider.addSubview(floatingValueView)
        SocketIOManager.sharedInstance.delegate = self
        if SocketIOManager.sharedInstance.socket.status != .connected {
            SocketIOManager.sharedInstance.connectSocket()
        }
        BannerCollection.delegate = self
        BannerCollection.dataSource = self
        OfferTblView.delegate = self
        OfferTblView.dataSource = self
        reportView.isHidden = true
        chartVW.backgroundColor = .white
    }
    
    @IBAction func BtnNotify(_ sender: UIButton) {
        if Store.authToken == nil || Store.authToken == "" {
            self.authNil()
        } else {
            sender.isSelected = !sender.isSelected
            if modal?.notifyme?.notifyme == 0 {
                notyfyME(notifystatus: 1)
                modal?.notifyme?.notifyme = 1
                btnNotifyMe.backgroundColor = .set
                btnNotifyMe.setTitleColor(.white, for: .normal)
            }else{
                notyfyME(notifystatus: 0)
                modal?.notifyme?.notifyme = 0
                btnNotifyMe.backgroundColor = .white
                btnNotifyMe.setTitleColor(.set, for: .normal)
                btnNotifyMe.layer.borderWidth = 1
                btnNotifyMe.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            }
        }
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        floatingValueView.text = "⃀ ".localized() + " \(Int(sender.value))"
        setData()  // Re-run setData to update the graph with the new slider value
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        floatingValueView.text = "⃀ ".localized() + " \(String(format:"%.0f",Double(maxValue)))"
        floatingValueView.center = CGPoint(x: slider.xPositionAlongLine(for: maxValue), y: slider.sliderLine.frame.midY)
    }
    
    func listenedData(data: SwiftyJSON.JSON, response: String) {
        //MARK: GET CHAT LIST
        if response == SocketListeners.Product_Comment_list.instance{
            print("SOCKET:- \(SocketIOManager.sharedInstance.socket.status)")
            print("DATA:- \(data)","RESPONSE:- \(response)")
            do{
                let teamDataArray = try JSONDecoder().decode([CommentElement].self, from: data.arrayValue[0].rawData())
                self.comments?.insert(teamDataArray[0], at: 0)
                self.commentTbl.reloadData()
            }
            catch let error {
                print("Error \(error)")
            }
        }
    }
    func notyfyME(notifystatus:Int) {
        LikeVM.notifyMeAPI(NotifyStatus: notifystatus) { dataa in
            if self.modal?.notifyme?.notifyme == 1 {
                CommonUtilities.shared.showAlert(message: "You’ll be notified when the price changes.".localized(), isSuccess: .success)
            }
            //
        }
    }

    func addShopping(){
        LikeVM.addShoppingAPI(productID: self.prodcutid) { dataa in
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applySolidColorsToGreenVw()
    }
    
    var latestEntries: [String: UpdatedListElement] = [:]
    
    //    func parseDate(_ dateString: String) -> Date? {
    //        let formatter = ISO8601DateFormatter()
    //        return formatter.date(from: dateString)
    //    }
    
    
    // Function to fill missing dates
    
    struct ShopItem {
        var shopName: String
        var price: Double?
        var date: String
    }
    
    // Function to fill missing entries
    func fillMissingEntries(sortedList: [UpdatedListElement]) -> [UpdatedListElement] {
        var filledList: [UpdatedListElement] = []
        
        let shopNames = Set(sortedList.map { $0.shopName })
        
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd"

        // Convert date strings to Date objects
        let dates = sortedList.compactMap { inputDateFormatter.date(from: $0.date ?? "") }
        
        guard let startDate = dates.min(), let endDate = dates.max() else {
            return sortedList
        }
        
        // Generate all dates between start and end date
        var allDates: [String] = []
        var currentDate = startDate
        while currentDate <= endDate {
            allDates.append(outputDateFormatter.string(from: currentDate))
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        var lastKnownPrice: [String: Double] = [:]
     //   print(allDates)
        print("ddds")
        for date in allDates {
            for shop in shopNames {
                if let existingEntry = sortedList.first(where: {
                    if let entryDate = inputDateFormatter.date(from: $0.date ?? "") {
                        return outputDateFormatter.string(from: entryDate) == date && $0.shopName == shop
                    }
                    return false
                }) {
                    lastKnownPrice[shop ?? ""] = existingEntry.price ?? 0
                    filledList.append(existingEntry)
                } else {
                    let missingEntry = UpdatedListElement(shopName: shop ?? "", price: lastKnownPrice[shop ?? ""] ?? 0, location: "", date: "\(date)T00:00:00.000Z", id: "\(UUID().uuidString)")
                    filledList.append(missingEntry)
                }
            }
        }
    
        return filledList
    }
    
    
    func calculateAveragePriceAccodingToPrice(filledList: [UpdatedListElement]) -> [(weekStartDate: String, averagePrice: Double)] {
        var weeklyPriceDict: [String: [Double]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let calendar = Calendar.current

        // Group prices by week start date
        for item in filledList {
            if let price = item.price, let date = parseDate1(String((item.date ?? "").prefix(10))) {
                // Find the start of the week (Monday)
                let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
                let weekStartString = formatter.string(from: weekStartDate) // Convert back to String

                weeklyPriceDict[weekStartString, default: []].append(price)
            }
        }

        // Calculate average price for each week
        var weeklyAveragePrices: [(String, Double)] = weeklyPriceDict.map { (weekStart, prices) in
            let total = prices.reduce(0, +)
            let average = total / Double(prices.count)
            return (weekStart, average)
        }

        // Sort by average price (lowest to highest)
        weeklyAveragePrices.sort { $0.1 < $1.1 }

        return weeklyAveragePrices
    }

    
    func calculateAveragePrice(filledList: [UpdatedListElement]) -> [(weekStartDate: String, averagePrice: Double)] {
        var weeklyPriceDict: [String: [Double]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let calendar = Calendar.current

        // Group prices by week start date
        for item in filledList {
            
            if let price = item.price, let date = parseDate1(String((item.date ?? "").prefix(10))) {
                // Find the start of the week (Monday)
                let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
                let weekStartString = formatter.string(from: weekStartDate) // Convert back to String

                weeklyPriceDict[weekStartString, default: []].append(price)
            }
        }

        // Calculate average price for each week
        var weeklyAveragePrices: [(String, Double)] = weeklyPriceDict.map { (weekStart, prices) in
            let total = prices.reduce(0, +)
            let average = total / Double(prices.count)
            return (weekStart, average)
        }

        // Sort by week start date
        weeklyAveragePrices.sort { $0.0 < $1.0 }

        return weeklyAveragePrices
    }
    
    func setData1() {
        guard let products = modal?.product?.updatedList, !products.isEmpty else {
            chartVW.clear()
            self.viewPriceHistory.isHidden = true
            self.viewPriceHisHeight.constant = 0
            return
        }
        var latestEntries: [String: UpdatedListElement] = [:]
        for item in products {
            if let shopName = item.shopName, let dateString = item.date {
                let trimmedDate = String(dateString.prefix(10)) // Extract YYYY-MM-DD
                let key = "\(shopName)_\(trimmedDate)" // Unique key for shopName + date
                
                if let existingItem = latestEntries[key], let existingPrice = existingItem.price, let newPrice = item.price {
                    if newPrice > existingPrice {
                        latestEntries[key] = item // Keep the highest price if same date
                    }
                } else {
                    latestEntries[key] = item
                }
            }
        }
        
        // Convert dictionary values to array
        var sortedList = latestEntries.values.sorted {
            if let date1 = parseDate($0.date ?? ""), let date2 = parseDate($1.date ?? "") {
                return date1 < date2  // Ascending order
            }
            return false
        }
        
        // Filter the last 30 days data
        let today = Date()
        
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: today) ?? today
        
        sortedList = sortedList.filter {
            if let date = parseDate($0.date ?? "") {
                return date >= thirtyDaysAgo && date <= today  // Ensures no future dates
            }
            return false
        }
        
//        for i in sortedList {
//            print("ShopName \(i.shopName ?? "") price:- \(i.price ?? 0) date: \(i.date ?? "")")
//        }
        
        
        print("Next Filter")
        
        
        // Get the completed list with missing entries filled
        let completedList = fillMissingEntries(sortedList: sortedList)
        //
        // Print the result
//        for item in completedList {
//            print("ShopName \(item.shopName ?? "") price:- \(item.price ?? 0) date: \(item.date ?? "")")
//        }
        
        print("Next Filter Average Price")
        // Example usage
        let averagePrices = calculateAveragePriceAccodingToPrice(filledList: completedList)
        let averagePricesDateWise = calculateAveragePrice(filledList: completedList)
        
        if averagePrices.count < 10 {
            self.viewPriceHistory.isHidden = true
            self.viewPriceHisHeight.constant = 0
        } else {
            self.viewPriceHistory.isHidden = false
            self.viewPriceHisHeight.constant = 117
        }
        
        // Print the result
//        for (date, avgPrice) in averagePrices {
//            print("Date: \(date), Average Price: \(avgPrice)")
//        }
        let higestPrice = (averagePrices.last?.averagePrice ?? 0.0)
        let lowestPrice = (averagePrices.first?.averagePrice ?? 0.0)
        var higestPriceString = "\((averagePrices.last?.averagePrice ?? 0.0))"
        var lowestPriceString = "\(averagePrices.first?.averagePrice ?? 0.0)"
        if higestPrice == 0 {

        } else {
            let formatted = (higestPrice.truncatingRemainder(dividingBy: 1) == 0) ?
                String(format: "%.0f", higestPrice) :
                String(format: "%.2f", higestPrice).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            higestPriceString = formatted
        }

        if higestPrice == 0 {

        } else {
            let formatted = (lowestPrice.truncatingRemainder(dividingBy: 1) == 0) ?
                String(format: "%.0f", lowestPrice) :
                String(format: "%.2f", lowestPrice).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            lowestPriceString = formatted
        }

        slider.minValue = averagePrices.first?.averagePrice ?? 0.0
        self.lblLowPrice.text = "Low".localized() + " \(lowestPriceString)"
        self.lblHighPrice.text = "High".localized() + " \(higestPriceString)"
        slider.maxValue = averagePrices.last?.averagePrice ?? 0.0
        
        let totalPrice = self.product?
            .compactMap { $0.price } // unwrap optional prices
            .reduce(0, +) ?? 0
        let avgPrice = totalPrice / Double(self.product?.count ?? 0)
        slider.selectedMaxValue = avgPrice
        self.floatingValueView.text = "Average:".localized() + " \(Int(avgPrice))"
        let currentValue = slider.selectedMaxValue
        let minValue = slider.minValue
        let maxValue = slider.maxValue
        
        // Prevent division by zero
        guard maxValue > minValue else { return }
        
        // Normalize the value between 0 and 1
        let normalizedValue = (currentValue - minValue) / (maxValue - minValue)
        
        // Calculate x-position based on slider width
        let sliderTrackWidth = slider.frame.width - 32  // Adjust for slider padding/margins
        let xPos = slider.frame.origin.x + (normalizedValue * sliderTrackWidth) + 16  // Add left padding
        
        // Set position above the slider
        floatingValueView.center = CGPoint(x: xPos, y: slider.frame.origin.y - 25) // Adjust Y offset as needed
        
       
    }
    
    func setData() {
        guard let products = modal?.product?.updatedList, !products.isEmpty else {
            chartVW.clear()
            self.viewHistoryPrice.isHidden = true
            self.viewHistoryPriceHieght.constant = 0
            return
        }
        
        var latestEntries: [String: UpdatedListElement] = [:]
        
        for item in products {
            if let shopName = item.shopName, let dateString = item.date {
                let trimmedDate = String(dateString.prefix(10)) // Extract YYYY-MM-DD
                let key = "\(shopName)_\(trimmedDate)" // Unique key for shopName + date
                
                if let existingItem = latestEntries[key], let existingPrice = existingItem.price, let newPrice = item.price {
                    if newPrice > existingPrice {
                        latestEntries[key] = item // Keep the highest price if same date
                    }
                } else {
                    latestEntries[key] = item
                }
            }
        }
        
        // Convert dictionary values to array
        var sortedList = latestEntries.values.sorted {
            if let date1 = parseDate($0.date ?? ""), let date2 = parseDate($1.date ?? "") {
                return date1 < date2  // Ascending order
            }
            return false
        }
        
        // Filter the last 30 days data
        let today = Date()
       // let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today

        sortedList = sortedList.filter {
            if let date = parseDate($0.date ?? "") {
                return  date <= today  // Ensures no future dates
            }
            return false
        }
        
//        for i in sortedList {
//            print("ShopName \(i.shopName ?? "") price:- \(i.price ?? 0) date: \(i.date ?? "")")
//        }
        
        
        print("Next Filter")
        
       
        // Get the completed list with missing entries filled
        let completedList = fillMissingEntries(sortedList: sortedList)

        // Print the result
//        for item in completedList {
//            print("ShopName \(item.shopName ?? "") price:- \(item.price ?? 0) date: \(item.date ?? "")")
//        }
        
        print("Next Filter Average Price")
        // Example usage
        var averagePrices = calculateAveragePrice(filledList: completedList)



        // Print the result
//        for (date, avgPrice) in averagePrices {
//            print("Date: \(date), Average Price: \(avgPrice)")
//        }
     
        if averagePrices.count <= 3{
            self.viewHistoryPrice.isHidden = true
            self.viewHistoryPriceHieght.constant = 0
            chartVW.clear()
            return
        }else{
            let pr = Array(averagePrices.suffix(4))
            averagePrices = pr
            self.viewHistoryPrice.isHidden = false
            self.viewHistoryPriceHieght.constant = 260
        }
        
        
        // Prepare data for chart
        var productPrices: [ChartDataEntry] = []
        var dateLabels: [String] = [] // Store formatted dates for X-axis labels
        
        for (index, product) in averagePrices.enumerated() {
            let price = product.averagePrice // Directly use it since it's not optional
            let dateStr = product.weekStartDate      // Directly use it since it's not optional

            productPrices.append(ChartDataEntry(x: Double(index), y: price))
            let formattedDate = formatDate(dateStr)
            dateLabels.append(formattedDate) // Store formatted date for labels
        }
        
        // Ensure there is data
        guard !productPrices.isEmpty else {
            chartVW.clear()
            return
        }
        
        // Create Line Chart DataSet
        let productPriceLine = LineChartDataSet(entries: productPrices, label: "Product Prices".localized())
        productPriceLine.colors = [UIColor.blue]
        productPriceLine.lineWidth = 2
        productPriceLine.mode = .cubicBezier
        productPriceLine.drawFilledEnabled = true
        productPriceLine.drawCirclesEnabled = false
        productPriceLine.drawValuesEnabled = true
        productPriceLine.circleRadius = 5
        productPriceLine.circleColors = [UIColor.blue]
        
        // Apply gradient fill
        let gradientColors = [UIColor.blue.cgColor, UIColor.clear.cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: [0.0, 1.0]) {
            productPriceLine.fill = LinearGradientFill(gradient: gradient, angle: 90)
        }
        
        // Configure Chart View
        let data = LineChartData(dataSet: productPriceLine)
        chartVW.data = data
        
        // Configure X-Axis (Use formatted date labels)
        let xAxis = chartVW.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dateLabels)
        xAxis.labelCount = dateLabels.count
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = Double(dateLabels.count - 1)
        xAxis.granularity = 1.0
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        
        // Configure Y-Axis
        let maxPrice = productPrices.max(by: { $0.y < $1.y })?.y ?? 0
        chartVW.leftAxis.axisMinimum = 0
        chartVW.leftAxis.axisMaximum = maxPrice + 10 // Add margin
        chartVW.rightAxis.enabled = false
        
        // Chart Animation
        
        chartVW.legend.enabled = true
        chartVW.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .easeInOutQuart)
        chartVW.notifyDataSetChanged()
    }
    
    // Helper function to parse date
    func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure it's in UTC
        return formatter.date(from: dateString)
    }
    
    func parseDate1(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure it's in UTC
        return formatter.date(from: dateString)
    }
    
    // Helper function to format date for x-axis labels
    func formatDate(_ dateString: String) -> String {
        guard let date = parseDate1(dateString) else { return "" }
        let formatter = DateFormatter()
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let appLanguage = "ar"
            formatter.locale = Locale(identifier: appLanguage)
        default:
            formatter.locale = Locale(identifier: "en")
        }

       
        formatter.dateFormat = "dd MMM" // Example: "06 Mar"
        return formatter.string(from: date)
    }
    
    
    //MARK: - FUNCTIONS
    func applySolidColorsToGreenVw() {
        // Remove any existing subviews
        greenVw.subviews.forEach { $0.removeFromSuperview() }
        
        // Ensure greenVw has a valid width
        guard greenVw.bounds.width > 0 else { return }
        
        // Define the total width of greenVw
        let totalWidth = greenVw.bounds.width
        
        // Define the color ranges (percentage-based)
        let colorRanges: [(CGFloat, CGFloat, UIColor)] = [
            (0, 20, UIColor.init(red: 146 / 255 , green: 200 / 255, blue: 153 / 255, alpha: 1)),   // Green from 10% to 20%
            (20, 80, UIColor.init(red: 247 / 255 , green: 215 / 255, blue: 118 / 255, alpha: 1)),  // Yellow from 20% to 80%
            (80, 100, UIColor.init(red: 228 / 255 , green: 145 / 255, blue: 134 / 255, alpha: 1))     // Red from 80% to 100%
        ]
        
        // Iterate over color ranges and create solid color sections
        for (start, end, color) in colorRanges {
            // Convert range percentages into actual width
            let startX = (start / 100) * totalWidth
            let width = ((end - start) / 100) * totalWidth
            
            // Ensure width is valid
            guard width > 0 else { continue }
            
            // Create a new section view
            let sectionView = UIView(frame: CGRect(x: startX, y: 0, width: width, height: greenVw.bounds.height))
            sectionView.backgroundColor = color
            
            // Add to greenVw
            greenVw.addSubview(sectionView)
        }
    }
    
    func detailFetchQrAPI(id:String){
        
        viewModal.prodcutDetailAPIByQrCode(id: id) { [weak self] dataa in
            guard let self = self else { return }
            if dataa?.product?.id ?? "" == "" {
                let alert = UIAlertController(title: "", message: "This barCode is not exist.".localized(), preferredStyle: .alert)
                alert.addAction(.init(title: "OK".localized(), style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                present(alert, animated: true)
            } else {
                self.MainView.isHidden = false
                self.modal = dataa
                self.comments = dataa?.comments?.reversed() ?? []
                self.similarProducts = dataa?.similarProducts ?? []

                var currentProduct = dataa?.product?.product ?? []
                let updatedProductList = dataa?.product?.updatedList ?? []

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")

                for i in 0 ..< currentProduct.count {
                    let checkExist = updatedProductList.filter { obj in
                        obj.shopName == currentProduct[i].shopName?.id ?? ""
                    }

                    let sortedCheckExist = checkExist.sorted { first, second in
                        guard let firstDateString = first.date,
                              let secondDateString = second.date,
                              let firstDate = dateFormatter.date(from: firstDateString),
                              let secondDate = dateFormatter.date(from: secondDateString) else {
                            return false
                        }
                        return firstDate < secondDate
                    }

                    if checkExist.count != 0 {
                        currentProduct[i].price = sortedCheckExist.last?.price ?? 0.0
                        currentProduct[i].date = sortedCheckExist.last?.date ?? ""
                    }
                    // Your loop logic here
                }

                let newproduct = currentProduct.sorted(by: {$0.price ?? 0 < $1.price ?? 0})
                let prices = newproduct.map({$0.price ?? 0}) ?? []
                let lowestPrice = prices.min()
                let highestPrice = prices.max()
                self.product = newproduct

//                let newproduct = dataa?.product.map({$0.product ?? []})?.sorted(by: {$0.price ?? 0 < $1.price ?? 0})
//                let prices = newproduct?.map({$0.price ?? 0}) ?? []
//                let lowestPrice = prices.min()
//                let highestPrice = prices.max()
//                self.product = currentProduct
                self.priceHistory = dataa?.pricehistory ?? []
                self.lblProName.text = dataa?.product?.name ?? ""
//                self.lblAmount.text = "⃀ ".localized()
                
                self.lblTotalRaitingReview.text = "\(dataa?.averageRating ?? 0) " + "(\(dataa?.ratingCount ?? 0) \("Reviews".localized()))"
                self.productQty = dataa?.product?.productUnitId?.prodiuctUnit ?? ""
                let currentLang = L102Language.currentAppleLanguageFull()
                switch currentLang {
                case "ar":
                    self.productQty = dataa?.product?.productUnitId?.prodiuctUnitArabic ?? ""
                default:
                    self.productQty = dataa?.product?.productUnitId?.prodiuctUnit ?? ""
                }
                
                if self.productQty == "" {
                    
                    let val = (lowestPrice == 0) ? "-" : ((lowestPrice ?? 0).truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice ?? 0) : String(format: "  f", lowestPrice ?? 0))
                    
                    self.lblProductUnit.text = ""
                    self.lblAmount.text =  "⃀ \(val)"
                } else {
                    let val = (lowestPrice == 0) ? "-" : ((lowestPrice ?? 0).truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice ?? 0) : String(format: "%.2f", lowestPrice ?? 0))
                    self.lblAmount.text = "⃀ \(val) "
                    self.lblProductUnit.text = "(\(self.productQty))"
                }
                if dataa?.offerCount == 1{
                    self.lblTotalCountOffer.text = "Offer".localized()
                }else{
                    self.lblTotalCountOffer.text = "\(dataa?.offerCount ?? 0) \("Offers".localized())"
                }
                if let lowestPrice = dataa?.product?.updatedList?.compactMap({ $0.price }).min() {
                    self.minVal = Int(lowestPrice)
                    self.lblLowPrice.text = "⃀ ".localized() + " \(lowestPrice)"
                    let sliderValue = CGFloat(lowestPrice)
                    slider.minValue = sliderValue
                }else {
                    self.lblLowPrice.text = ""
                    self.slider.minValue = 0
                }
                floatingValueView.center = CGPoint(x: slider.xPositionAlongLine(for: slider.maxValue), y: slider.sliderLine.frame.midY)
                if let HighPrice = dataa?.product?.updatedList?.compactMap({ $0.price }).max() {
                    self.lblHighPrice.text = "⃀ ".localized() + " \(HighPrice)"
                    self.maxVal = Int(highestPrice ?? 0)
                    let sliderValue = CGFloat(HighPrice)
                    self.floatingValueView.text = "⃀ ".localized() + " \(Int(HighPrice))"
                    slider.maxValue = sliderValue
                }else {
                    self.lblHighPrice.text = ""
                }
                self.lblDescription.text = dataa?.product?.description?.localized() ?? ""
                let formato = DateFormatter()
                formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
                formato.formatterBehavior = .default

                let date = formato.date(from: dataa?.product?.updatedAt ?? "")!
                formato.timeZone = TimeZone.current
                formato.dateFormat = "dd/MM/yyyy"
                
                if self.comments?.count == 0 || self.comments?.count == nil{
                    btnSeeCommnet.isHidden = true
                }else{
                    btnSeeCommnet.isHidden = false
                }
                
                if (dataa?.product?.updatedList?.count ?? 0) == 0 {
                    self.lblLastPUpdate.text = ""
                } else {
                    let inputDateFormatter = DateFormatter()
                    inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    inputDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let outputDateFormatter = DateFormatter()
                    outputDateFormatter.dateFormat = "dd/MM/yyyy"
                    outputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    let sortedList = dataa?.product?.updatedList ?? []
                    // Convert date strings to Date objects
                    let dates = sortedList.compactMap { inputDateFormatter.date(from: $0.date ?? "") }

                    if let startDate = dates.min(), let endDate = dates.max() {
                        // use startDate and endDate here

                        self.lblLastPUpdate.text = "\("Last price updated on".localized()) \(outputDateFormatter.string(from: endDate))"
                    } else {

                    }

                }
             //   self.lblLastPUpdate.text = "\("Last price updated on".localized()) \(formato.string(from: date))"
                if dataa?.like == 0 || dataa?.like == nil{
                    self.heartBtn.isSelected = false
                }else{
                    self.heartBtn.isSelected = true
                }
                
                self.OfferTblView.reloadData()
                self.similarProColl.reloadData()
                self.BannerCollection.reloadData()
                self.commentTbl.reloadData()
                self.scrollView.isHidden = false
                if modal?.notifyme?.notifyme == 0 {
                    btnNotifyMe.backgroundColor = .white
                    btnNotifyMe.setTitleColor(.set, for: .normal)
                    btnNotifyMe.layer.borderWidth = 1
                    btnNotifyMe.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                }else{
                    btnNotifyMe.backgroundColor = .set
                    btnNotifyMe.setTitleColor(.white, for: .normal)
                }
                self.setData()
                self.setData1()
            }
        }
    }
    
    func detailFetchAPI(id:String){
        
        viewModal.prodcutDetailAPI(id: id) { [weak self] dataa in
            guard let self = self else { return }
            self.scrollView.setContentOffset(.zero, animated: true)
            self.MainView.isHidden = false
            self.modal = dataa
            self.comments = dataa?.comments?.reversed() ?? []
            self.similarProducts = dataa?.similarProducts ?? []
            if self.comments?.count == 0 || self.comments?.count == nil{
                btnSeeCommnet.isHidden = true
            }else{
                btnSeeCommnet.isHidden = false
            }

//            {
//    "_id" = 67da94795545c16f35d1b42f;
//    date = "2025-03-18T00:00:00.000Z";
//    price = 140;
//    shopName = 6789f32859d90e9115cd7559;
//},

            var currentProduct = dataa?.product?.product ?? []
            let updatedProductList = dataa?.product?.updatedList ?? []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            for i in 0 ..< currentProduct.count {
                let checkExist = updatedProductList.filter { obj in
                    obj.shopName == currentProduct[i].shopName?.id ?? ""
                }

                let sortedCheckExist = checkExist.sorted { first, second in
                    guard let firstDateString = first.date,
                          let secondDateString = second.date,
                          let firstDate = dateFormatter.date(from: firstDateString),
                          let secondDate = dateFormatter.date(from: secondDateString) else {
                        return false
                    }
                    return firstDate < secondDate
                }

                if checkExist.count != 0 {
                    currentProduct[i].price = sortedCheckExist.last?.price ?? 0.0
                    currentProduct[i].date = sortedCheckExist.last?.date ?? ""
                }
                // Your loop logic here
            }


            let newproduct = currentProduct.sorted(by: {$0.price ?? 0 < $1.price ?? 0})
            let prices = newproduct.map({$0.price ?? 0}) ?? []
            let lowestPrice = prices.min()
            let highestPrice = prices.max()
            self.product = newproduct
            self.priceHistory = dataa?.pricehistory ?? []
            self.lblProName.text = dataa?.product?.name ?? ""
            //self.lblAmount.text = "⃀ ".localized() + " \(lowestPrice ?? 0)/"
            self.lblTotalRaitingReview.text = "\(dataa?.averageRating ?? 0) " + "(\(dataa?.ratingCount ?? 0) \("Reviews".localized()))"
            let currentLang = L102Language.currentAppleLanguageFull()
            switch currentLang {
            case "ar":
                self.productQty = dataa?.product?.productUnitId?.prodiuctUnitArabic ?? ""
            default:
                self.productQty = dataa?.product?.productUnitId?.prodiuctUnit ?? ""
            }
            
            if self.productQty == "" {
                let val = (lowestPrice == 0) ? "-" : ((lowestPrice ?? 0).truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice ?? 0) : String(format: "%.2f", lowestPrice ?? 0))
                
                
                self.lblAmount.text =  "⃀ \(val)"
                self.lblProductUnit.text = ""
            } else {
                let val = (lowestPrice == 0) ? "-" : ((lowestPrice ?? 0).truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice ?? 0) : String(format: "%.2f", lowestPrice ?? 0))
                self.lblAmount.text = "⃀ \(val)"
                self.lblProductUnit.text = "(\(self.productQty))"
            }

            if dataa?.offerCount == 1{
                self.lblTotalCountOffer.text = "1 " + "Offer".localized()
            }else{
                self.lblTotalCountOffer.text = "\(dataa?.offerCount ?? 0) \("Offers".localized())"
            }
            if let lowestPrice = dataa?.product?.updatedList?.compactMap({ $0.price }).min() {
                self.minVal = Int(lowestPrice)
                self.lblLowPrice.text = "⃀ ".localized() + " \(lowestPrice)"
                let sliderValue = CGFloat(lowestPrice)
               // slider.minValue = sliderValue
            }else {
                self.lblLowPrice.text = ""
              //  self.slider.minValue = 0
            }
            floatingValueView.center = CGPoint(x: slider.xPositionAlongLine(for: slider.maxValue), y: slider.sliderLine.frame.midY)
            if let HighPrice = dataa?.product?.updatedList?.compactMap({ $0.price }).max() {
                self.lblHighPrice.text = "⃀ ".localized() + " \(HighPrice)"
                self.maxVal = Int(highestPrice ?? 0)
                let sliderValue = CGFloat(HighPrice)
                self.floatingValueView.text = "⃀ ".localized() + " \(Int(HighPrice))"
             //   slider.maxValue = sliderValue
            }else {
                self.lblHighPrice.text = ""
            }
            self.lblDescription.text = dataa?.product?.description?.localized() ?? ""
            let formato = DateFormatter()
            formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            formato.formatterBehavior = .default
            let date = formato.date(from: dataa?.product?.updatedAt ?? "")!
            formato.timeZone = TimeZone.current
            formato.dateFormat = "dd/MM/yyyy"

            if (dataa?.product?.updatedList?.count ?? 0) == 0 {
                self.lblLastPUpdate.text = ""
            } else {
                let inputDateFormatter = DateFormatter()
                inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
                inputDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                let outputDateFormatter = DateFormatter()
                outputDateFormatter.dateFormat = "dd/MM/yyyy"
                outputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
                let sortedList = dataa?.product?.updatedList ?? []
                // Convert date strings to Date objects
                let dates = sortedList.compactMap { inputDateFormatter.date(from: $0.date ?? "") }
                
                if sortedList.count != 0 {
                    // use startDate and endDate here
                    let date = inputDateFormatter.date(from:sortedList.last?.date ?? "")
                    
                    self.lblLastPUpdate.text = "\("Last price updated on".localized()) \(outputDateFormatter.string(from: date ?? Date()))"
                } else {

                }

            }
         //   self.lblLastPUpdate.text = "\("Last price updated on".localized()) \(formato.string(from: date))"
            if dataa?.like == 0 || dataa?.like == nil{
                self.heartBtn.isSelected = false
             //   self.heartBtn.setImage(UIImage(named: "Unlike"), for: .normal)
            }else{
                self.heartBtn.isSelected = true
               // self.heartBtn.setImage(UIImage(named: "Like"), for: .normal)
            }
            self.OfferTblView.reloadData()
            self.similarProColl.reloadData()
            self.BannerCollection.reloadData()
            self.commentTbl.reloadData()
            self.scrollView.isHidden = false
            if modal?.notifyme?.notifyme == 0 {
                btnNotifyMe.backgroundColor = .white
                btnNotifyMe.setTitleColor(.set, for: .normal)
                btnNotifyMe.layer.borderWidth = 1
                btnNotifyMe.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            }else{
                btnNotifyMe.backgroundColor = .set
                btnNotifyMe.setTitleColor(.white, for: .normal)
            }
            self.setData()
            self.setData1()
        }
    }
    
    //MARK: ACTIONS
    @IBAction func btnLikeDeslike(_ sender: UIButton) {
        if Store.authToken == nil || Store.authToken == "" {
            self.authNil()
        } else {
            sender.isSelected = !sender.isSelected
            if sender.isSelected == true{
                LikeVM.likeDeslikeAPI(productID: self.prodcutid) { dataa in
                    CommonUtilities.shared.showAlert(message: "Product like".localized(), isSuccess: .success)
                }
            } else {
                LikeVM.likeDeslikeAPI(productID: self.prodcutid) { dataa in
                    CommonUtilities.shared.showAlert(message: "Product Dislike".localized(), isSuccess: .success)
                }
            }
        }
    }
    
    @IBAction func BtnShare(_ sender: UIButton) {
        let message = "Message goes here."
        
        // Convert NSURL to URL
        if let link = URL(string: "https://testflight.apple.com/join/n7ndpk24") {
            let objectsToShare: [Any] = [message, link]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            // Exclude AirDrop and Add to Reading List
            activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
            
            // Present the activity view controller
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendComnt(_ sender: UIButton) {
        if Store.authToken == nil || Store.authToken == "" {
            self.authNil()
        } else {
            let string = self.txtView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if string == ""{
                CommonUtilities.shared.showAlert(message: "Please enter message.", isSuccess: .error)
            }else{
                SocketIOManager.sharedInstance.getCommentList(productID: self.prodcutid, comment: self.txtView.text ?? "")
                self.txtView.text = ""
            }
        }
        
    }
    @IBAction func didTapShowReportBtn(_ sender: UIButton) {
        reportView.isHidden.toggle()
    }
    
    @IBAction func didTapReportBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
        vc.modalPresentationStyle = .overFullScreen
        vc.productID = self.prodcutid
        self.reportView.isHidden = true
        self.present(vc, animated: true)
    }
    
    @IBAction func didTapSeeAllCommentsBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.comments = self.comments
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapSeeAllOffersBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
        vc.productQty = self.productQty
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapReviewsBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewVC") as! ReviewVC
        vc.productID = self.prodcutid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func seeAllSimilarProducts(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
        vc.productID = self.prodcutid
        vc.check = 2
        vc.idCallback = { dataa in
            self.prodcutid = dataa
            self.detailFetchAPI(id: self.prodcutid)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // - Parameter sender:-  <#sender description#>
    @IBAction func addToShoppingListBtn(_ sender: UIButton) {
        if Store.authToken == nil || Store.authToken == "" {
            self.authNil()
        } else {
            if product?.count == 0 {
                CommonUtilities.shared.showAlert(message: "No Offer Avialabel",isSuccess: .error)
            }else{
                addShopping()
            }
        }
    }

    @IBAction func onClickViewShopingList(_ sender: UIButton) {
        if let tabBarController = (UIApplication.shared.windows.first?.rootViewController as? UINavigationController)?.viewControllers.first as? UITabBarController {
            self.navigationController?.popToRootViewController(animated: false)
            tabBarController.selectedIndex = 1
        }
    }
    
}
//MARK: - EXTENSIONS COLLECTION VIEW
extension SubCatDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == BannerCollection {
            return 1
        } else {
            if similarProducts?.count == 0{
                similarProColl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                similarProColl.backgroundView = nil
                return similarProducts?.count ?? 0
            }
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == BannerCollection {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailBannerCVC", for: indexPath) as! DetailBannerCVC
            let imageIndex = (imageURL) + (modal?.product?.image ?? "")
            cell.imgBanner.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgBanner.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            return cell
        } else {
            let cell = similarProColl.dequeueReusableCell(withReuseIdentifier: "AddSimilarCVC", for: indexPath) as! AddSimilarCVC
            cell.setupObj = similarProducts?[indexPath.row]
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == BannerCollection {
            return CGSize(width: BannerCollection.layer.bounds.width/1, height: BannerCollection.layer.bounds.height)
        } else {
            return CGSize(width: similarProColl.bounds.width / 2.2 - 7, height: 155)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == BannerCollection {
            
        }else{
            let prodcutid = similarProducts?[indexPath.row].id ?? ""
            self.prodcutid = prodcutid
            detailFetchAPI(id: prodcutid)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == BannerCollection {
            let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
            let index = scrollView.contentOffset.x / witdh
            let roundedIndex = round(index)
            self.pgController?.currentPage = Int(roundedIndex)
        }
    }
}

//MARK: - EXTENSIONS TABLE VIEW
extension SubCatDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == OfferTblView {
            if product?.count == 0{
                OfferTblView.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                OfferTblView.backgroundView = nil
                return min(5, product?.count ?? 0)
            }
            return 0
        } else {
            if comments?.count == 0{
                commentTbl.setNoDataMessage("No comments yet".localized(), txtColor: UIColor.set)
            }else{
                commentTbl.backgroundView = nil
                btnSeeCommnet.isHidden = false
                return min(5, comments?.count ?? 0)
            }
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == OfferTblView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfferTVC", for: indexPath) as! OfferTVC
            cell.setupObj = product?[indexPath.row]
            cell.productUnit = self.productQty
            let product = self.product?[indexPath.row]
            if product?.price == self.product?.map({ $0.price ?? 0 }).min() {
                cell.lblHighLowPrice.text = NSLocalizedString("Lowest Price", comment: "")
            } else if product?.price == self.product?.map({ $0.price ?? 0 }).max() {
                cell.lblHighLowPrice.text = NSLocalizedString("Highest Price", comment: "")
            } else {
                cell.lblHighLowPrice.text = ""
            }
            return cell
        } else {
            let cell = commentTbl.dequeueReusableCell(withIdentifier: "CommentTVC", for: indexPath) as! CommentTVC
            cell.setupObj = comments?[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == OfferTblView {
            DispatchQueue.main.async {
                self.offerTblHeight.constant = self.OfferTblView.contentSize.height
            }
        } else {
            DispatchQueue.main.async {
                self.commentTblHeight.constant = self.commentTbl.contentSize.height
            }
        }
    }
}
class DollarValueFormatter: IndexAxisValueFormatter {
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "SubCatDetailVC" + String(format: "%.2f", value)
    }
}
//MARK: STRUCTURE
struct OfferDetail {
    var quantity: String
    var price: String
    var storeName: String
    
    init(quantity: String, price: String, storeName: String) {
        self.quantity = quantity
        self.price = price
        self.storeName = storeName
    }
}

// Extension to get thumb position
extension UISlider {
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: self.bounds)
        let thumbRect = self.thumbRect(forBounds: self.bounds, trackRect: trackRect, value: self.value)
        return thumbRect.midX + self.frame.origin.x
    }
}

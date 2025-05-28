//
//  HomeViewModal.swift
//  ARABAH
//
//  Created by cqlios on 10/12/24.
//

import Foundation

class HomeViewModal : NSObject{

    //MARK: - HOME GET API
    func homeListAPI(latitude:String, longitude:String,categoryID:String? = nil, categoryName:String? = nil,onSuccess:@escaping((HomeModalBody?)->())) {
        
        var param = ["longitude":longitude, "latitude":latitude]
        if let category = categoryID{
            param["categoryId"] = category
        }
        if let categoryName = categoryName{
            param["categoryName"] = categoryName
        }
        WebService.service(API.home,param: param,service: .get,showHud: false) { (modelData : HomeModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - SUB CATEGORY GET API
    func subCatProduct(cateogyID:String,onSuccess:@escaping(([SubCatProductModalBody]?)->())) {
        let param = ["categoryId":cateogyID]
        WebService.service(API.SubCategoryProduct,param: param,service: .get,showHud: false) { (modelData : SubCatProductModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    //MARK: - REPORT API
    func reportAPI(ProductID:String,message:String,onSuccess:@escaping((ReportModalBody?)->())) {
        if CheckValidations.ReportValidation(Description: message){
            let param = ["ProductID":ProductID, "message":message] as [String:Any]
            WebService.service(API.ReportCreate,param: param,service: .post) { (modelData : ReportModal, data, json) in
                onSuccess(modelData.body)
            }
        }
    }
    
    //MARK: - REPORT API
    func shoopingListDelteAPI(id:String,onSuccess:@escaping((shoppinglistDeleteModalBody?)->())) {
        let param = ["id":id] as [String:Any]
        WebService.service(API.ShoppingProduct_delete,param: param,service: .post) { (modelData : shoppinglistDeleteModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - NOTIFY ME API
    func notifyMeAPI(NotifyStatus:Int,onSuccess:@escaping((LoginModalBody?)->())) {
        let param = ["Notifyme":NotifyStatus] as [String:Any]
        WebService.service(API.Notifyme,param: param,service: .put) { (modelData : LoginModal, data, json) in
//            CommonUtilities.shared.showAlert(message: modelData.message ?? "",isSuccess: .success)
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Notes Listing delete API
    func notesDeleteAPI(id:String,onSuccess:@escaping((NewCommonStringBody?)->())) {
        let param = ["id":id] as [String:Any]
        WebService.service(API.deleteNotes,param: param,service: .post) { (modelData : NewCommonString, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Chagne langauage API
    func chagneLangApi(type:String,onSuccess:@escaping((LoginModalBody?)->())) {
        let param = ["language_type":type] as [String:Any]
        WebService.service(API.changeLanguage,param: param,service: .post) { (modelData : LoginModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Create Notes API
//    func createNotesAPI(text:String,onSuccess:@escaping((CreateNotesModalBody?)->())) {
//        let param = ["text":text] as [String:Any]
//        WebService.service(API.NotesCreate,param: param,service: .post) { (modelData : CreateNotesModal, data, json) in
//            onSuccess(modelData.body)
//        }
//    }
    func createNotesAPI(text: [NotesCreate],id:String, onSuccess: @escaping ((CreateNotesModalBody?) -> ())) {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(text)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let param = ["texts": jsonString,"id":id] as [String: Any]
                //let apiName = "NotesCreate?id=\(id)"
                WebService.service(API.NotesCreate, param: param, service: .post) { (modelData: CreateNotesModal, data, json) in
                    onSuccess(modelData.body)
                }
            }
        } catch {
            print("Error encoding NotesCreate array to JSON: \(error)")
        }
    }
    
    //MARK: - Get Notes API
    func getNotesAPI(onSuccess:@escaping(([GetNotesModalBody]?)->())) {
        WebService.service(API.getNotes,service: .get) { (modelData : GetNotesModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Create Note list get API
    func CreateNotesgetListAPI(onSuccess:@escaping(([NotesText]?)->())) {
        WebService.service(API.Notes,service: .get) { (modelData : CreateNoteListModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Get Notes Detail
    func getNotesDetailAPI(id:String,onSuccess:@escaping((CreateNotesModalBody?)->())) {
        let param = ["id":id]
        WebService.service(API.getNotesdetail,param: param,service: .get) { (modelData : CreateNotesModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Get Shopping List API
    func shoppingListAPI(onSuccess:@escaping((GetShoppingListModalBody?)->())) {
        WebService.service(API.ShoppingList,service: .get,showHud: true) { (modelData : GetShoppingListModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Get Shopping List all clear API
    func shoppingListClearAllAPI(onSuccess:@escaping((CommentModal?)->())) {
        WebService.service(API.ShoppinglistClear,service: .post) { (modelData : CommentModal, data, json) in
            onSuccess(modelData)
        }
    }
    
    // MARK: - Get fetch filter data API
    func fetchFilterDataAPI(latitude:String,longitude:String,onSuccess:@escaping((FilterGetDataModalBody?)->())){
        let param = ["longitude":longitude, "latitude":latitude]
        WebService.service(API.ApplyFilletr,param: param,service: .get) { (modelData : FilterGetDataModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Search Create API
    func searchCreateAPI(name:String,onSuccess:@escaping(([CreateModalBody]?)->())) {
        let param = ["name":name] as [String:Any]
        WebService.service(API.CreateSerach,param: param,service: .post) { (modelData : CreateModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    //MARK: - Search Category API
    func searchCategoryAPI(categoryName:String,longitude:String,latitude:String,onSuccess:@escaping((CategorySearchModalBody?)->())) {
        var param = ["searchTerm":categoryName, "longitude":longitude, "latitude":latitude] as [String:Any]
        var params = "?searchTerm=\(categoryName)&longitude=\(longitude)&latitude=\(latitude)"
        
        if Store.fitlerBrand?.count ?? 0 != 0 {
            params = "\(params)&brandId=\(Store.fitlerBrand?.joined(separator: ",") ?? "")"
            param["brandId"] = Store.fitlerBrand?.joined(separator: ",")
        }
        
        if Store.filterStore?.count ?? 0 != 0 {
            params = "\(params)&storeId=\(Store.filterStore?.joined(separator: ",") ?? "")"
            param["storeId"] = Store.filterStore?.joined(separator: ",")
        }
        
        if Store.filterdata?.count ?? 0 != 0 {
            params = "\(params)&categoryId=\(Store.filterdata?.joined(separator: ",") ?? "")"
            param["categoryId"] = Store.filterdata?.joined(separator: ",")
        }
     
        WebService.service(API.SearchchingList,urlAppendId: params,param: param,service: .post) { (modelData : CategorySearchModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Search Create API
    func recentSearchAPI(onSuccess:@escaping(([RecentSearchModalBody]?)->())) {
        WebService.service(API.SearchList,service: .get) { (modelData : RecentSearchModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    //MARK: - Search History Delete API
    func historyDeleteAPI(id:String,onSuccess:@escaping((SearchHistoryDeleteModalBody?)->())) {
        let param = ["id":id]
        WebService.service(API.SerachDelete,param: param,service: .post) { (modelData : SearchHistoryDeleteModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Get Category API
    func categoryListAPI(latitude:String,longitude:String,onSuccess:@escaping((CategoryListModalBody?)->())) {
        let param = ["longitude":longitude, "latitude":latitude] as [String:Any]
        WebService.service(API.categoryFilter,param: param,service: .get,showHud: false) { (modelData : CategoryListModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Get latest product API
    func getLatestProductAPI(onSuccess:@escaping(([LatestProModalBody]?)->())) {
        WebService.service(API.LatestProduct,service: .get,showHud: false) { (modelData : LatestProModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Get Similar Product API
    func getSimilarProductAPI(id:String, onSuccess:@escaping(([SimilarProductModalBody]?)->())) {
        let param = ["id":id]
        WebService.service(API.similarProducts,param: param,service: .get,showHud: false) { (modelData : SimilarProductModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Add Shopping API
    func addShoppingAPI(productID:String, onSuccess:@escaping((AddShoppingModalBody?)->())) {
        let param = ["productId":productID] as [String:Any]
        WebService.service(API.addShooping,param: param,service: .post) { (modelData : AddShoppingModal, data, json) in
            CommonUtilities.shared.showAlert(message: modelData.message ?? "",isSuccess: .success)
            onSuccess(modelData.body)
        }
    } 
    //MARK: - ADD TICKET API
    func addTicketAPI(tittle:String,Description:String,onSuccess:@escaping((ReportModalBody?)->())) {
        if CheckValidations.addticketvalidation(tittle: tittle, description: Description){
            let param = ["Title":tittle, "Description":Description] as [String:Any]
            WebService.service(API.createTicket,param: param,service: .post) { (modelData : ReportModal, data, json) in
                onSuccess(modelData.body)
            }
        }
    }
    //MARK: - GET TICKET API
    func getTicketAPI(onSuccess:@escaping(([getTicketModalBody]?)->())) {
        WebService.service(API.TicketList,service: .get) { (modelData : getTicketModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    //MARK: - GET OFFER DEALS API
    func getOfferDealsAPI(onSuccess:@escaping(([GetOfferDealsModalBody]?)->())) {
        WebService.service(API.DealListing,service: .get, showHud: false) { (modelData : GetOfferDealsModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    //MARK: - Like Deslike API
    func likeDeslikeAPI(productID:String, onSuccess:@escaping((LikeModalBody?)->())) {
        let param = ["ProductID":productID]
        WebService.service(API.ProductLike,param: param,service: .post) { (modelData : LikeModal, data, json) in
            onSuccess(modelData.body)
        }
    }
}

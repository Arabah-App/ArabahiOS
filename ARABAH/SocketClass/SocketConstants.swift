//
//  SocketConstants.swift
//  Fargo
//
//  Created by apple on 23/02/21.
//  Copyright © 2021 Cqlsys MacBook Pro. All rights reserved.
//

import Foundation

enum SocketKeys : String {

    case socketBaseUrl = "https://admin.arabahtheapp.com/"
    case userId = "UserId"
    case Productid = "Productid"
    case comment = "comment"
     var instance : String {
        return self.rawValue
    }
}

enum SocketEmitters:String{
    case connectUser = "connect_user"
    case Product_Comment = "Product_Comment"
   
    var instance : String {
        return self.rawValue
    }
}

enum SocketListeners:String{
    case connectListener = "connect_user"
    case Product_Comment_list = "Product_Comment"
    var instance : String {
        return self.rawValue
    }
}




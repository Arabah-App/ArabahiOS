//
//  SocketsManager.swift
//  Service Near
//
//  Created by cqlnp on 06/05/24.
//

import Foundation
import SwiftyJSON
import SocketIO

protocol SocketDelegate {
    func listenedData(data: JSON, response: String)
    
}
class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()

    let manager = SocketManager(socketURL: URL(string: SocketKeys.socketBaseUrl.rawValue)!, config: [.compress,.log(false),.reconnects(true),.reconnectWait(20)])

    
    var socket: SocketIOClient!
    var delegate: SocketDelegate?
    
    override init() {
        super.init()
        socket = manager.defaultSocket
    }
    
    
    //MARK: - default socket listeners
    func connectSocket() {
        if socket.status != .connected {
            self.socket.connect()
            establishConnection()
        }
    }
    //MARK: - Establish Connection
    func establishConnection() {
        socket.removeAllHandlers()
        //self.socket.connect()
        socket.on(clientEvent: .statusChange) { data, ack in
            self.socket.on(clientEvent: .reconnect) { data, ack in
                print("Reconnected")
            }
            print("Status Change")
        }
        
        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
            self.connectUser()
        }
        
        socket.on(clientEvent: .reconnectAttempt) { data, ack in
            print("ReConnect Attempt")
        }
        
        socket.on(clientEvent: .error) { data, ack in
            print("error")
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Disconnect")
        }
        addHandlers()
    }
    //MARK: -Custom Socket Listener
    func addHandlers(){
        //MARK: Connect User  Listener
        socket?.on(SocketListeners.connectListener.instance, callback: { (Data, emitter) in
            print("connect_listener")
            self.delegate?.listenedData(data: JSON(Data), response: SocketListeners.connectListener.instance)
            NotificationCenter.default.post(name: Notification.Name("SocketConnected"), object: nil)

        })
        socket.on(SocketEmitters.connectUser.rawValue) {data, ack in
            print("connect_uESR")
        }
     
        //MARK: - Get Comment List listener
        socket?.on(SocketListeners.Product_Comment_list.instance, callback: { (Data, emitter) in
            print("get_chat_list")
            self.delegate?.listenedData(data: JSON(Data), response: SocketListeners.Product_Comment_list.instance)
        })
        
    }
    //MARK: - Close Connection
    func closeConnection() {
        socket.disconnect()
        manager.defaultSocket.disconnect()
        socket.off(SocketKeys.userId.rawValue)
    }
}
//MARK: - Custom Functions Emitter
extension SocketIOManager {
    
    //MARK: Connect user request emitter
    func connectUser() {
        if Store.userDetails?.body?.authToken != nil || Store.userDetails?.body?.authToken != ""{
            let dict  = [SocketKeys.userId.instance : Store.userDetails?.body?.id ?? 0] as [String : Any]
            socket.emit(SocketEmitters.connectUser.instance,dict)
        }
    }

    //MARK: - Comment emit
    func getCommentList(productID:String, comment:String){
        let params = [SocketKeys.userId.rawValue: Store.userDetails?.body?.id ?? "",SocketKeys.Productid.rawValue:productID, SocketKeys.comment.rawValue:comment] as [String : Any]
        socket.emit(SocketEmitters.Product_Comment.instance, params)
    }
}



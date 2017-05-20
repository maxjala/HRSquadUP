//
//  ChatViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import Starscream


//MARK: Mock Data
struct User {
    let id: String
    let name: String
}

class ChatViewController: JSQMessagesViewController {
    
    let user1 = User(id: "1", name: "Nick")
    let user2 = User(id: "2", name: "Max")
    
    var currentUser: User{
        return user1
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
        
    }
    
    var ref: FIRDatabaseReference!

    
    var chats: [Chat] = []
    var newChats: [Any] = []
    var messages = [JSQMessage]()
    var timer = Timer()
    var seconds = 0
    var socket = WebSocket(url: URL(string: "ws://192.168.1.114:3000/cable")!, protocols: ["ApiProjectChatsChannel"])
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //socket = WebSocket(url: URL(string: "ws://localhost:8080/")!)
        //socket.delegate = self as? WebSocketDelegate
        //socket.connect()
        
        fetchChat()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = currentUser.id
        self.senderDisplayName = currentUser.name
        
        socket.delegate = self as! WebSocketDelegate
        socket.connect()
        
    
        //fetchChat()
        //fetchConstant()
        ref = FIRDatabase.database().reference()

        
        tabBarController?.tabBar.isHidden = true
    }
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    
    func fetchChat(){
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        let url = URL(string: "http://192.168.1.114:3000/api/v1/project_chats?private_token=\(validToken)&project_id=1")
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        guard let validJSON = jsonResponse as? [[String: Any]] else {return}
                        //MARK: NEED TO CHECK
                        self.newChats = validJSON // MARK: MUST CHECK
                        DispatchQueue.main.async {
                            // self.chatTableView.reloadData()
                            self.makeMessages(validJSON)
                            self.collectionView.reloadData()
                        }
                    }catch let jsonError as NSError{
                        
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func makeMessages(_ messageJSON: [[String: Any]]) {
        for each in messageJSON {
            if let id = each["id"] as? Int,
                let projectID = each["project_id"] as? Int,
                let userID = each["user_id"] as? Int,
                let message = each["message"] as? String,
                let timestamp = each["created_at"] as? String {
                
                let aMessage = JSQMessage(senderId: "\(userID)", displayName: "\(userID)", text: message)
                
                messages.append(aMessage!)
                
            }
        }
    }
    
    func sendText(_ messageDict: [String: Any]) {
        
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        if let jsonData = try? JSONSerialization.data(withJSONObject: messageDict, options: []) {
            
            let url = URL(string: "http://192.168.1.114:3000/api/v1/project_chats?private_token=\(validToken)&project_id=1")
            var urlRequest = URLRequest(url: url!)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = jsonData
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let validError = error as NSError? {
                    print(validError.localizedDescription)
                    return
                }
                
            }
            
            dataTask.resume()
        }
        
    }
    
    func addToText(id: Any, textinfo: NSDictionary){
        
        if let userName = textinfo["userName"] as? String,
            let body = textinfo["body"] as? String,
            let imageURL = textinfo["imageURL"] as? String,
            let timeCreated = textinfo["timestamp"] as? String,
            let userId = textinfo["id"] as? Int{
            
            let newText = Chat(anId: userId, aUserName: userName, aBody: body, anImageURL: imageURL, aTimestamp: timeCreated)
            self.chats.append(newText)
        }
        
    }
    
    func fetchConstant(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(counter), userInfo: nil, repeats: true)
        
    }
    
    func counter(){
        seconds += 1
        messages.removeAll()
        fetchChat()
        //collectionView.scrollToItem(at: [messages.count-1], at: .bottom, animated: true)
    }
    
    
}


extension ChatViewController{
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages.append(message!)
        let sentDict = ["sender_id" : message?.senderId, "message_id" : "\(Date.timeIntervalSinceReferenceDate)", "message" : message?.text]
        
        sendText(sentDict)
        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUserName = message.senderDisplayName
        
        return NSAttributedString(string: messageUserName!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if currentUser.id == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .gray)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }

}

extension ChatViewController : WebSocketDelegate {
    /*
    public func websocketDidConnect(socket: Starscream.WebSocket) {
        
    }
    
    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        
    }
    
    public func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any],
            let messageType = jsonDict["type"] as? String else {
                return
        }
        
        if messageType != "ping" {
            
        }
        // 2
        if messageType == "messages",
            let messageData = jsonDict["data"] as? [String: Any],
            let messageAuthor = messageData["author"] as? String,
            let messageText = messageData["text"] as? String {
            
            let message = JSQMessage(senderId: messageAuthor, displayName: messageAuthor, text: messageText)
            messages.append(message!)
            collectionView.reloadData()
        }
        
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
        
    }
    */
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Received data: \(data.count)")
    }
}




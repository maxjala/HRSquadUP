//
//  ChatViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ActionCableClient


//MARK: Mock Data
struct User {
    let id: String
    let name: String
}

class ChatViewController: JSQMessagesViewController {
    
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
        
    }
    
    var project : Project?
    var currentUser : Employee?
    var projectMembers : [Employee]?
    
    var chats: [Chat] = []
    var newChats: [Any] = []
    var messages = [JSQMessage]()
    var timer = Timer()
    var seconds = 0
    
    var client = ActionCableClient(url: URL(string: "ws://192.168.1.114:3000/cable")!)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        
        setUpActionCableConnection()
        
        fetchAndCreateChatHistory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = currentUser?.employeeID else {return}
        self.senderId = "\(id)"
        self.senderDisplayName = currentUser?.firstName
        
        tabBarController?.tabBar.isHidden = true
    }
    
    func fetchAndCreateChatHistory() {
        guard let projectID = project?.projectId else {return}
        
        JSONConverter.fetchChatHistory(projectID) { (chatHistory, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            
            self.makeMessages(chatHistory!)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
                if self.messages.count > 0 {
                    let lastIndex = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: lastIndex, at: .bottom, animated: true)
                }
                
            }
        }
    }
    
    func makeMessages(_ messageJSON: [[String: Any]]) {
        messages = []
        for each in messageJSON {
            if let id = each["id"] as? Int,
                let projectID = each["project_id"] as? Int,
                let userID = each["user_id"] as? Int,
                let message = each["message"] as? String,
                let timestamp = each["created_at"] as? String {
                
                for person in self.projectMembers! {
                    if person.employeeID == userID {
                        self.messages.append(JSQMessage(senderId: "\(userID)", displayName: person.firstName, text: message))
                    }
                }
            }
        }
    }
    
    func sendText(_ messageDict: [String: Any]) {
        
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        guard let projectID = project?.projectId else {return}
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: messageDict, options: []) {
            
            let url = URL(string: "http://192.168.1.114:3000/api/v1/project_chats?private_token=\(validToken)&project_id=\(projectID)")
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
    
}


extension ChatViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
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
        
        guard let id = currentUser?.employeeID else {return nil}
        
        if "\(id)" == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 240/255.0, green: 133/255.0, blue: 91/255.0, alpha: 0.8))
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .gray)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }

}


extension ChatViewController {
    func setUpActionCableConnection() {
        client.connect()
        
        //guard let validID = projectID as? Int else {return}
        
        let room_identifier = ["project_id" : project?.projectId]
        let roomChannel = client.create("ApiProjectChatsChannel", identifier: room_identifier, autoSubscribe: true, bufferActions: true)
        
        client.onConnected = {
            print("Connected!")
        }
        
        client.onDisconnected = {(error: Error?) in
            print("Disconnected!")
        }
        
        
        roomChannel.onReceive = { (JSON : Any?, error : Error?) in
            print("Received", JSON, error)
            //self.fetchChat()
            guard let formattedJSON = JSON as? [String:Any],
                let messageJSON = formattedJSON["chat_message_object"] as? [String:Any],
                let message = messageJSON["message"] as? String,
                let senderID = messageJSON["user_id"] as? Int
                else {return}
            
            for person in self.projectMembers! {
                if person.employeeID == senderID {
                    self.messages.append(JSQMessage(senderId: "\(senderID)", displayName: person.firstName, text: message))
                }
            }
            
            let lastIndex = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: lastIndex, at: .bottom, animated: true)
        }
        
        // A channel has successfully been subscribed to.
        roomChannel.onSubscribed = {
            print("Yay!")
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        roomChannel.onUnsubscribed = {
            print("Unsubscribed")
        }
        
        // The attempt at subscribing to a channel was rejected by the server.
        roomChannel.onRejected = {
            print("Rejected")
        }
    }
    
}







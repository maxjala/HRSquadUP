//
//  ChatViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import JSQMessagesViewController

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
    
    var chats: [Chat] = []
    var newChats: [Any] = []
   var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = currentUser.id
        self.senderDisplayName = currentUser.name
        
    
        fetchChat()
        
        tabBarController?.tabBar.isHidden = true
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
    



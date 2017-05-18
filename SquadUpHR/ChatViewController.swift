//
//  ChatViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!{
        didSet{
            chatTableView.dataSource = self
            chatTableView.delegate = self
            chatTableView.register(ChatTableViewCell.cellNib, forCellReuseIdentifier: ChatTableViewCell.cellIdentifier)
        }
    }

    @IBOutlet weak var textView: UITextView! {
        didSet{
            let tapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(removeText))
            textView.isUserInteractionEnabled = true
            textView.addGestureRecognizer(tapGestureRecongizer)
        }
    }
    
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.addTarget(self, action: #selector(sendText), for: .touchUpInside)
        }
    }
    
    var chats: [Chat] = []
    var newChats: [Any] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeText(){
        if textView.text == "Type Here" {
            textView.text = ""
            textView.isUserInteractionEnabled = true
        }else {
            return
        }
    }
    
    func fetchChat(){
        guard let validToken = UserDefaults.standard.string(forKey: "AUTH_TOKEN") else {return}
        let url = URL(string: "")
        
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
                            self.chatTableView.reloadData()
                        }
                    }catch let jsonError as NSError{
                    
                    }
                }
            }
        }
        dataTask.resume()
    }

    
    func sendText(){
        
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
extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.cellIdentifier, for: indexPath) as? ChatTableViewCell else {return UITableViewCell()}
        
        
        return cell
    }
    
    func tableViewScrollToBottom(){
        let numberOfRows = self.chatTableView.numberOfRows(inSection: 0)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
}

extension ChatViewController: UITableViewDelegate{

}

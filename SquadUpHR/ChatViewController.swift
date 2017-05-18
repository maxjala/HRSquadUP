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

    
    func sendText(){
        
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

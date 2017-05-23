//
//  LoginViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 16/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton! {
        didSet{
            loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.clear.cgColor
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(){
        //MARK TO CHANGE
        
        //m.kuphal@nextacademy.com password is password
        //m.feil@nextacademy.com" password
        
        guard
            let username = usernameTextField.text,
            let password = passwordTextField.text else {return}
            //let username = "t.olson@nextacademy.com"
            //let password = "password"
        //192.168.1.114:3000/api/v1/sessions
        let url = URL(string: "http://192.168.1.53:3000/api/v1/sessions")// need to check
        //let url = URL(string: "http://192.168.1.155:3000/api/v1/sessions")// need to check
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type") //MARK to check
        
        let param : [String : String] = [
            "email" : username,
            "password" : password
        ]
        
        var data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        urlRequest.httpBody = data
        
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: urlRequest) { ( data, response, error) in
            
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        guard let validJSON = jsonResponse as? [String : Any] else {return}
                        
                        UserDefaults.standard.setValue(validJSON["private_token"], forKey: "AUTH_TOKEN")
                        UserDefaults.standard.synchronize()
                        
                        DispatchQueue.main.async {
                            self.displayAttandance()
                        }
                        
                        print(jsonResponse)
                        
                    }catch let jsonError as NSError {
                        
                    }
                    
                    
                }
                
            }
            
        }
        
        dataTask.resume()
    }
    
  
    func displayAttandance(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        self.present(vc, animated: true, completion: nil)
        
    
    }
    
    func hideKeyboard(){
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    

}

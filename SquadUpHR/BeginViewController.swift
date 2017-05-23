//
//  BeginViewController.swift
//  SquadUpHR
//
//  Created by nicholaslee on 23/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class BeginViewController: UIViewController {

    @IBOutlet weak var button: UIButton! {
        didSet{
            button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        
      navigationBarHidden()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToLogin(){
        let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        navigationController?.pushViewController(controller!, animated: true)
    }


}

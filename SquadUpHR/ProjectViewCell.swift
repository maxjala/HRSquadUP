//
//  ProjectViewCell.swift
//  SquadUpHR
//
//  Created by Max Jala on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class ProjectViewCell: UITableViewCell {
    
    @IBOutlet weak var openView: UIView!
    
    @IBOutlet weak var titleButton: UIButton!
    
    @IBOutlet weak var detailView: UIView! {
        didSet{
            detailView.isHidden = true
            detailView.alpha = 0
        }
    }
    
    @IBOutlet weak var membersLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var openProjectButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    static let cellIdentifier = "ProjectViewCell"
    static let cellNib = UINib(nibName: ProjectViewCell.cellIdentifier, bundle: Bundle.main)
    
    var cellExist: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func animate(duration:Double, c: @escaping () -> Void) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModePaced, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration, animations: {
                
                self.detailView.isHidden = !self.detailView.isHidden
                if self.detailView.alpha == 1 {
                    self.detailView.alpha = 0.5
                } else {
                    self.detailView.alpha = 1
                }
                
            })
        }, completion: {  (finished: Bool) in
            print("animation complete")
            c()
        })
    }
}


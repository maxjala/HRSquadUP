//
//  ProjectViewCell.swift
//  SquadUpHR
//
//  Created by Max Jala on 18/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

protocol ProjectRoleViewCellDelegate {
    func openProject(_ project: Project)
    func openProjectChat(_ project: Project)
}

class ProjectViewCell: UITableViewCell {
    
    var project : Project?
    var delegate : ProjectRoleViewCellDelegate? = nil
    
    @IBOutlet weak var openView: UIView!
    
    @IBOutlet weak var projectNameLabel: UILabel!
    
    @IBOutlet weak var detailView: UIView! {
        didSet{
            //detailView.isHidden = true
            //detailView.alpha = 0
        }
    }
    
    @IBOutlet weak var membersLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var openProjectButton: UIButton! {
        didSet{
            openProjectButton.addTarget(self, action: #selector(openProjectButonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var openChatButton: UIButton! {
        didSet{
            openChatButton.addTarget(self, action: #selector(openChatButonTapped), for: .touchUpInside)
        }
    }
    
    
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
    
    func openProjectButonTapped() {
        if delegate != nil {
            if let _project = project {
                delegate?.openProject(_project)
            }
        }
    }
    
    func openChatButonTapped() {
        if delegate != nil {
            if let _project = project {
                delegate?.openProjectChat(_project)
            }
        }
    }
}


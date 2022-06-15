//
//  UserTableViewCell.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/15.
//

import UIKit

class UserTableViewCell: UITableViewCell {
// MARK: - Properties
    
    let reusableTableViewCellIdentifier = "UserTableViewCell"
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let userNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "EHD"
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        return lbl
    }()
    
    private let userRecordLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "승리: 3, 패배: 1"
        lbl.font = UIFont.systemFont(ofSize: 18)
        return lbl
    }()
    

// MARK: - LifeCycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        setupProfileImageView()
        
        addSubview(userNameLabel)
        setupUserNameLabel()
        
        addSubview(userRecordLabel)
        setupUserRecordLabel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - Configure
    func setupProfileImageView() {
        profileImageView.setDimensions(height: 60, width: 60)
        profileImageView.layer.cornerRadius = 60 / 2
        profileImageView.centerY(inView: self,
                                 leftAnchor: leftAnchor,
                                 paddingLeft: 15)
        
    }
    
    func setupUserNameLabel() {
        userNameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingLeft: 10)
    }
    

    func setupUserRecordLabel() {
        userRecordLabel.anchor(left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, paddingLeft: 10, paddingBottom: 2)
    }
}

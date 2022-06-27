//
//  UserTableViewCell.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/15.
//

import UIKit

class UserTableViewCell: UITableViewCell {
// MARK: - Properties
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            userNameLabel.text = user.name
            userRecordLabel.text = "승리: \(user.record.win) , 패배: \(user.record.lose)"
            logStatusLabel.text = user.isLogin ? "로그인중" : "로그아웃중"
            logStatusLabel.textColor = user.isLogin ? .systemBlue : .lightGray
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private var logStatusLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        lbl.layer.borderColor = CGColor(gray: 1, alpha: 1)
        return lbl
    }()
    
    private let userNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        return lbl
    }()
    
    private var userRecordLabel: UILabel = {
        let lbl = UILabel()
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
        
        addSubview(logStatusLabel)
        setupLogStatusLabel()
        
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
    
    func setupLogStatusLabel() {
        logStatusLabel.anchor(top: self.topAnchor, right: self.rightAnchor, paddingTop: 10, paddingRight: 5)
    }
}

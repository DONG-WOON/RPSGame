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
            getUserImage(of: user)
            configure(user)
            if user.isInGame {
                userIsInGameLabel.textColor = .lightGray
            } else {
                userIsInGameLabel.textColor = .clear
            }
        }
    }
    
    let roundedBackgrpundView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 10.0
        v.clipsToBounds = true
        return v
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private var logStatusLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    private lazy var userIsInGameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "게임중"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .clear
        return lbl
    }()
    
    private let userNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 17)
        return lbl
    }()
    
    private var userRecordLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    
// MARK: - Actions
    private func configure(_ user: User) {
        userNameLabel.text = user.name
        userNameLabel.textColor = user.isLogin ? .black : .lightGray
        userRecordLabel.text = "승리: \(user.record.win) , 패배: \(user.record.lose)"
        userRecordLabel.textColor = user.isLogin ? .black : .lightGray
        logStatusLabel.text = user.isLogin ? "로그인 중" : ""
        logStatusLabel.textColor = user.isLogin ?  UIColor(named: "LightOrange") : .lightGray
    }
    
    private func getUserImage(of user: User) {
        guard let url = URL(string: user.profileThumbnailImageUrl) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("download Image dataTaskError: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            DispatchQueue.main.async                                {
                self.profileImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
// MARK: - LifeCycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(roundedBackgrpundView)
        setRoundedBackgrpundViewConstraints()
        
        addSubview(profileImageView)
        setupProfileImageView()
        
        addSubview(userNameLabel)
        setupUserNameLabel()
        
        addSubview(userRecordLabel)
        setupUserRecordLabel()
        
        addSubview(logStatusLabel)
        setupLogStatusLabel()
        
        addSubview(userIsInGameLabel)
        setupUserIsInGameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - Configure
    private func setupProfileImageView() {
        profileImageView.setDimensions(height: 50, width: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerY(inView: roundedBackgrpundView,
                                 leftAnchor: leftAnchor,
                                 paddingLeft: 15)
    }
    
    private func setupUserNameLabel() {
        userNameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingTop: 2, paddingLeft: 10)
    }
    
    private func setupUserIsInGameLabel() {
        userIsInGameLabel.anchor(top: userNameLabel.topAnchor, left: userNameLabel.rightAnchor, paddingTop: 5, paddingLeft: 5)
    }

    private func setupUserRecordLabel() {
        userRecordLabel.anchor(left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, paddingLeft: 10, paddingBottom: 3)
    }
    
    private func setupLogStatusLabel() {
        logStatusLabel.anchor(top: roundedBackgrpundView.topAnchor, right: roundedBackgrpundView.rightAnchor, paddingTop: 10, paddingRight: 10)
    }
    
    private func setRoundedBackgrpundViewConstraints() {
        roundedBackgrpundView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8)
    }
}

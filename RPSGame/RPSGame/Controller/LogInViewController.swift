//
//  ViewController.swift
//  RPSGame
//
//  Created by EHDOMB on 2022/06/05.
//

import UIKit
import Firebase

final class LogInViewController: UIViewController {

    private let backgroundView = UIImageView()
    private let mainLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        setupMainLabel()
        appear()
    }
    
    private func setupBackgroundView() {
        view.backgroundColor = .white
        view.addSubview(backgroundView)
        
        backgroundView.frame = view.frame
        backgroundView.image = UIImage(named: "loginBackground")
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.alpha = 0
        
        view.sendSubviewToBack(backgroundView)
    }
    
    private func setupMainLabel() {
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLabel)
        
        let mainLabelAutoLayout = [
        mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
        mainLabel.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 150),
        mainLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        mainLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
        ]

        NSLayoutConstraint.activate(mainLabelAutoLayout)
        
        mainLabel.backgroundColor = .systemGray
        mainLabel.layer.masksToBounds = true
        mainLabel.numberOfLines = 2
        mainLabel.text = "죽음의\n 가위바위보"
        mainLabel.textColor = .systemRed
        mainLabel.alpha = 0
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont.boldSystemFont(ofSize: 50)
    }
    
//    private func setupLogInButton() {
//        let stackView = UIStackView()
//
//    }
    
    private func appear() {
        UIView.animate(withDuration: 3) {
            self.backgroundView.alpha = 1
            self.mainLabel.alpha = 1
            self.mainLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
        }
    }
}


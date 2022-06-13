//
//  Extension.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/05.
//

import UIKit
// MARK: - UIViewController

extension UIViewController {
    
    func showMessage(title: String, message: String?, firstAction: String?, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstAction = UIAlertAction(title: firstAction, style: .default, handler: completion)
        alert.addAction(firstAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIView
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, paddingTop: CGFloat, left: NSLayoutXAxisAnchor?, paddingLeft: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true

        }
    }
}

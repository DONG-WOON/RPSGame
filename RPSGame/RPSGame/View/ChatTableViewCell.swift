//
//  ChatTableViewCell.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/21.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    enum bubbleType{
        
        case incoming
        case outgoing
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var chatTextBubbleView: UIView!
    @IBOutlet weak var chatTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatTextBubbleView.layer.cornerRadius = 6
    }
    
    func setMessageData(message: Message) {
        userNameLabel.text = message.userName
        chatTextView.text = message.text
    }
    
    func setBubbleType(type: bubbleType) {
        
        if type == .outgoing {
            
            stackView.alignment = .leading
            chatTextBubbleView.backgroundColor = #colorLiteral(red: 0.9485026002, green: 0.6838501096, blue: 0.1121309325, alpha: 0.6835402397)
            chatTextView.textColor = .black
        } else if type == .incoming {
            
            stackView.alignment = .trailing
            chatTextBubbleView.backgroundColor = #colorLiteral(red: 0.9088875055, green: 0.488041997, blue: 0.7129195333, alpha: 0.8097174658)
            chatTextView.textColor = .white
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

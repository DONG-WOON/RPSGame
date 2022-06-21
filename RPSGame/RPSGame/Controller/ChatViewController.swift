//
//  ChatTableViewController.swift
//  RPSGame
//
//  Created by EHDOMB on 2022/06/20.
//

import UIKit

final class ChatViewController: UIViewController {
    

    
//    var chatMessages = [Message]()
    var chatMessages = [Message]()
    
    func addmessage() {
        let message1 = Message(userName: "e", text: "야")
        let message2 = Message(userName: "d", text: "왜")
        let message3 = Message(userName: "e", text: "ㅁ렁나리;ㅁㄴ어라ㅣㅁㄴ;ㅜㅡㅇ라민ㅇㅇ푸마ㅣ;음ㅇ나ㅣ퍼마ㅣㄴ어프마ㅣㄴ;품나ㅣㅍ이;ㅜㄴㅁㅇㅍㄴㅁㅍㅇ푸ㅏㅁㄴ잎;ㅜㅁㄴ아ㅣ")
        let message4 = Message(userName: "d", text: "모야 이건")
        let message5 = Message(userName: "e", text: "ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ")
        let message6 = Message(userName: "e", text: "꼽냐")
        let message7 = Message(userName: "d", text: "응엄청")
        let message8 = Message(userName: "e", text: "ㅁ디지고싶냐")
        let message9 = Message(userName: "d", text: "머라그랬냐")
        let message99 = Message(userName: "e", text: "아무것도아님8")
        

        chatMessages.append(message1)
        chatMessages.append(message2)
        chatMessages.append(message3)
        chatMessages.append(message4)
        chatMessages.append(message5)
        chatMessages.append(message6)
        chatMessages.append(message7)
        chatMessages.append(message8)
        chatMessages.append(message9)
        chatMessages.append(message99)
        
    }
    
    let containerView = UIView()
    let chatTableView = UITableView()
    let inputTextView = UITextView()
    let sendButton = UIButton()
    let moveDownButton = UIButton()
    let messageContainerView = UIView()
    
    var viewBottomSafeInset: CGFloat = 5
    
    struct chatUI { //이거 꼭 필요한가?
        var textFieldSize: CGFloat = 60
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addmessage()
        view.backgroundColor = .white
        
        setAutoLayout()
        configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        observeMessages()
        textViewDidChange(inputTextView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setAutoLayout() {
        
        view.addSubview(containerView)
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        
        containerView.addSubview(chatTableView)
        containerView.addSubview(messageContainerView)
        containerView.addSubview(moveDownButton)
        
        chatTableView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor)
        messageContainerView.anchor(top: chatTableView.bottomAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, height: 60)
        
        moveDownButton.anchor(bottom: messageContainerView.topAnchor, right: containerView.rightAnchor, paddingBottom: 3, paddingRight: 10, width: 32, height: 32)
        
        messageContainerView.addSubview(inputTextView)
        messageContainerView.addSubview(sendButton)

        inputTextView.anchor(left: messageContainerView.leftAnchor, paddingLeft: 5, height: 35)
        inputTextView.centerY(inView: messageContainerView)
        sendButton.anchor(left: inputTextView.rightAnchor, right: messageContainerView.rightAnchor, width: 35, height: 35)
        sendButton.centerY(inView: messageContainerView)
    }
    
    func configure() {

        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        //        chatTableView.rowHeight = 150
        //        chatTableView.estimatedRowHeight = 80
        //        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.separatorStyle = .none
        chatTableView.allowsSelection = false
        chatTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureTableView(_:))))
        
        messageContainerView.backgroundColor = .white
        
        sendButton.setImage(UIImage(named: "sendBtnIcon"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendBtnDidTap(_:)), for: .touchUpInside)
        
        inputTextView.layer.cornerRadius = 7
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputTextView.layer.borderWidth = 0.2
        
        moveDownButton.setImage(UIImage(named: "moveDownBtn"), for: .normal)
        moveDownButton.layer.opacity = 0.5
        moveDownButton.addTarget(self, action: #selector(moveDownBtnDidTap(_:)), for: .touchUpInside)
        view.bringSubviewToFront(moveDownButton)
    }
    
    @objc func tapGestureTableView(_ sender: UITapGestureRecognizer) {
        inputTextView.resignFirstResponder()
    }
    
    @objc func didReceiveKeyboardNotification(_ sender: Notification) {
    
        switch sender.name {
            case UIResponder.keyboardWillShowNotification:
            print("willshow")
            if let keyboardFrame:NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                   let keyboardRectangle = keyboardFrame.cgRectValue
               
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                }
                }
            
            case UIResponder.keyboardWillHideNotification :
                print("willhide")
                self.view.transform = .identity
                
            default : break
        }
    }
    
    func observeMessages() {

//        let messageRoomKey = amIChallenger ? "\(playerID)vs\(playerVS)" : "\(playerVS)vs\(playerID)"      // 도전자의이름이 앞에오는 동일한 키를 가지기위함
//
//        dbRef.child("Chat").child("messages").child("\(messageRoomKey)").observe(.childAdded) { (snapshot) in
//            if let dataArray = snapshot.value as? [String: Any] {
//                print("🔵🔵🔵 obserMessages DataArray: ", dataArray)
//                guard let senderName = dataArray["senderName"] as? String
//                    , let messageText = dataArray["text"] as? String
//                    else { return }
//
//                let message = Message(messageKey: snapshot.key, senderName: senderName, messageText: messageText)
//                self.chatMessages.append(message)
//                self.chatTableView.reloadData()
//
//                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
//            }
//        }
    }
    
    func sendMessage(text: String, completion: @escaping (_ isSuccess: Bool) -> () ) {
//        let senderName = playerID
//        let dataArray: [String: Any] = ["senderName": senderName, "text": text]
//        print("🔸🔸🔸 sendMessage DataArray: ", dataArray)
//
//        let messageRoomKey = amIChallenger ? "\(playerID)vs\(playerVS)" : "\(playerVS)vs\(playerID)"
//
//        dbRef.child("Chat").child("messages").child("\(messageRoomKey)").childByAutoId().setValue(dataArray) { (error, ref) in
//            error == nil ? completion(true) : completion(false)
//        }
        
    }
    
    @objc func sendBtnDidTap(_ sender: UIButton) {
//        guard let text = inputTextView.text, !text.isEmpty else { return }
//
//            sendMessage(text: text, completion: { (isSuccess) in
//                if isSuccess {
//                    self.inputTextView.text = ""
//                    self.textViewDidChange(self.inputTextView)
//                } else {
//                    print("‼️‼️‼️ sendMessage 메소드 에러")
//                }
//            })
    }
    
    @objc func moveDownBtnDidTap(_ sender: UIButton) {
        guard chatMessages.count > 0 else { return }
        
        self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.top, animated: true)
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        let message = chatMessages[indexPath.row]
        
        cell.setMessageData(message: message)
        
        
        
        message.userName == "e" ?
            cell.setBubbleType(type: .outgoing) : cell.setBubbleType(type: .incoming)
        
        return cell
    }
    
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let lastPageContentOffset = scrollView.contentSize.height - chatTableView.frame.height
//
//        scrollView.contentOffset.y < lastPageContentOffset - 50 ?
//            (moveDownButton.isHidden = false) : (moveDownButton.isHidden = true)
//    }
}


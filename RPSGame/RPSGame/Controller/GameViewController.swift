//
//  GameViewController.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/18.
//

import UIKit
import KakaoSDKUser
import AVFoundation

final class GameViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet weak var gameReadyView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var opponentChoiceImageView: UIImageView!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    private lazy var timerView: UIView = {
        let v = UIView()
        return v
    }()
    
    private var player: AVAudioPlayer?
    
    var opponent: Gamer?
    var me: Gamer?
    private var timer = Timer()
    private var timeValue = 7
    
    var startFlag: (Bool,Bool)? = (false, false) {
        didSet {
            if let flag = startFlag, flag == (true, true) {
                self.dismiss(animated: true, completion: nil)
                print("가위바위보 게임 start")
                gamePlay()
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupPlayers()
    }
    // MARK: - Actions
    
    private func gamePlay() {
        startButton.isEnabled.toggle()
        gameReadyView.isHidden = true
        playSound()
        
        guard let opponent = opponent, let me = me else { return }
        USERS_REF.child(opponent.id).child("opponent").child("choice").observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            let mychoice = RPS(rawValue: value)
            self.me?.choice = mychoice
        }
        
        USERS_REF.child(me.id).child("opponent").child("choice").observe(.value) { snapshot in
            guard let value = snapshot.value as? Int else { return }
            let opponentChoice = RPS(rawValue: value)
            self.opponent?.choice = opponentChoice
        }
        
        buttonisEnabled(true)
    }
    
    // MARK: Configure UI
    
    func setupPlayers() {
        guard let opponent = opponent, let me = me else { return }
        opponentName.text = opponent.name
        myName.text = me.name
        
        USERS_REF.child(opponent.id).child("opponent").child("wantsGameStart").observe(.value) { snapshot in
            guard let iWantGameStart = snapshot.value as? Bool else{ return }
            print(iWantGameStart)
            self.startFlag?.0 = iWantGameStart
        }
        
        USERS_REF.child(me.id).child("opponent").child("wantsGameStart").observe(.value) { snapshot in
            guard let opponentWantsGameStart = snapshot.value as? Bool else{ return }
            print(#function,opponentWantsGameStart)
            self.startFlag?.1 = opponentWantsGameStart
        }
        
    }
    
    @IBAction func goChat(_ sender: Any) {
        
        guard let me = me else { return }
        guard let opponent = opponent else { return }
        
        let chatRoomID = opponent.id > me.id ? "\(opponent.id)\(me.id)" : "\(me.id)\(opponent.id)"
        
        let chatVC = ChatViewController()
        
        chatVC.myName = me.name
        chatVC.chatRommID = chatRoomID
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func startGame(_ sender: Any) {
        
        guard let opponentId = opponent?.id else { return }
        showMessage(title: "게임 시작", message: "게임을 시작할까유?", firstAction: "네") { alertAction in
            if alertAction.style == .default {
                USERS_REF.child(opponentId).child("opponent").updateChildValues(["wantsGameStart": true])
                self.showMessage(title: "대기중", message: "상대방을 기다려 주세요", completion: nil)
            } else {
                USERS_REF.child(opponentId).child("opponent").updateChildValues(["wantsGameStart": false])
            }
        }
    }
    
    @IBAction func rockPaperScissors(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        switch button.tag {
        case 0:
            rockButton.isEnabled = false
            paperButton.isEnabled = true
            scissorsButton.isEnabled = true
        case 1:
            rockButton.isEnabled = true
            paperButton.isEnabled = false
            scissorsButton.isEnabled = true
        case 2:
            rockButton.isEnabled = true
            paperButton.isEnabled = true
            scissorsButton.isEnabled = false
        default:
            break
        }
        
        self.me?.choice = RPS(rawValue: button.tag)
        guard let opponentId = opponent?.id else { return }
        
        USERS_REF.child(opponentId).child("opponent").updateChildValues(["choice": button.tag])
    }
    
    // MARK: Helpers
    
    private func playSound() {
        
        guard let sound = Bundle.main.url(forResource: "game", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: sound, fileTypeHint: AVFileType.mp3.rawValue)
            
            player?.delegate = self
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func showStandByUIView() {
        
    }
    
    private func compare(myChoice: RPS?, opponentChoice: RPS?) -> String {
        if myChoice == nil && opponentChoice == nil {
            return "무승부"
        } else if myChoice == nil {
            return opponent!.name
        } else if opponentChoice == nil {
            return me!.name
        } else {
            switch (myChoice, opponentChoice) {
            case (.rock, .rock):     return "무승부"
            case (.rock, .paper):    return opponent!.name
            case (.rock, .scissors): return me!.name
                
            case (.paper, .rock):     return me!.name
            case (.paper, .paper):    return "무승부"
            case (.paper, .scissors): return opponent!.name
                
            case (.scissors, .rock):     return opponent!.name
            case (.scissors, .paper):    return me!.name
            case (.scissors, .scissors): return "무승부"
                
            default:
                return "compare error"
            }
        }
    }
    
    private func showResult(winner: String) {
        print("승자는 \(winner)입니다")
        
        guard let opponent = opponent, let me = me else { return }
        if winner == opponent.name {
            USERS_REF.child(opponent.id).child("record").child("win").getData { (_, snapshot) in
                guard let winCount = snapshot?.value as? Int else { return }
                USERS_REF.child(opponent.id).child("record").updateChildValues(["win":winCount + 1])
            }
        } else if winner == me.name {
            USERS_REF.child(opponent.id).child("record").child("lose").getData { (_, snapshot) in
                guard let loseCount = snapshot?.value as? Int else { return }
                USERS_REF.child(opponent.id).child("record").updateChildValues(["lose":loseCount + 1])
            }
        }
        
        USERS_REF.child(me.id).child("opponent").updateChildValues(["wantsGameStart": false])
        USERS_REF.child(opponent.id).child("opponent").updateChildValues(["wantsGameStart": false])
        
        gameReadyView.isHidden = false
        askGameAgain()
    }
    
    private func askGameAgain() {
        
    }
    private func exit() {
        //나가기 버튼 누르면
        // 나의 정보가 사라지고
        // 정보가 사라지면서 firebase 초기화 되고
        // observer가 상대방이 나갔는지 알려줌.
    }
}

// MARK: - Helpers

extension GameViewController {
    private func buttonisEnabled(_ bool: Bool) {
        rockButton.isEnabled = bool
        paperButton.isEnabled = bool
        scissorsButton.isEnabled = bool
    }
}

extension GameViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        buttonisEnabled(false)
        guard let opponent = opponent, let me = me else { return }
        let winner = compare(myChoice: me.choice, opponentChoice: opponent.choice)
        showResult(winner: winner)
    }
}

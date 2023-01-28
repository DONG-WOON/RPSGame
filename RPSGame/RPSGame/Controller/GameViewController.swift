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
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var scissorsButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var opponentView: UIView!
    @IBOutlet weak var opponentChoiceImageView: UIImageView!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    /*
     timer관련 ui적용 필요
    private lazy var timerView: UIView = {
        let v = UIView()
        return v
    }()
    
    private var timer = Timer()
    private var timeValue = 7
    */
    private var player: AVAudioPlayer?
    
    var opponent: Gamer?
    var me: Gamer?
    
    var startFlag: (Bool,Bool)? = (false,false) {
        didSet {
            guard !compareTuples(tuple1: startFlag!, tuple2: oldValue!) else { return }
            guard let startFlag = startFlag else { return }
            
            switch startFlag {
                    
                case (false, true):
                    
                    guard let opponent = opponent, let me = me else { return }
                    guard startButton.isEnabled else { return }
                    
                    self.showMessage(title: "게임 요청", message: "상대방이 게임시작을 요청했습니다. 시작하시겠습니까?", firstAction: .yes, secondAction: .reject, firstActionCompletion: { _ in
                        
                        // 게임요청 수락할 경우
                        opponent.oppoenentWantGameStart(true)
                    }, secondActionCompletion: { _ in
                        
                        // 게임요청 거절할 경우
                        me.oppoenentWantGameStart(false)
                    })
                    
                case (true, true):
                    
                    let messageVC = self.presentedViewController as? UIAlertController
                    
                    if messageVC?.title == "대기중" {
                        // 내가 게임요청을 보냈을때
                        dismiss(animated: true)
                        print("가위바위보 게임 start")
                        gamePlay()
                    } else {
                        // 내가 요청 받았을때
                        print("화면 안사라지고 가위바위보 게임 start")
                        gamePlay()
                    }
                    
                case (false, false):
                    
                    let messageVC = self.presentedViewController as? UIAlertController
                    
                    if messageVC?.title == "대기중" {
                        dismiss(animated: true)
                        showMessage(title: "게임수락 거절", message: "상대방이 게임요청을 거절헀습니다.",action: .ok)
                    } else if messageVC?.title == "게임 요청" {
                        dismiss(animated: true)
                        showMessage(title: "게임요청 취소", message: "상대방이 게임요청을 취소헀습니다.",action: .ok)
                    }
                    
                default:
                    return
            }
        }
    }
    // 상대방이 게임에서 나가는 경우 확인
    var opponentIsInGame: Bool = true {
        willSet(value) {

            if !value {
                showMessage(title: "게임 나가기", message: "상대방이 나갔습니다. 게임에서 나갑니다.", action: .ok) { _ in
                    self.exit()
                }
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupPlayers()
        setViewsLayerBorderShadow()
        exitButton.addTarget(self, action: #selector(exit), for: .touchUpInside)
    }
    
    // MARK: Configure UI
    
    func setViewsLayerBorderShadow() {
        startButton.backgroundColor = UIColor(named: "Background")
        startButton.layer.borderColor = UIColor(named: "LightOrange")?.cgColor
        startButton.layer.borderWidth = 2
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        startButton.layer.shadowOpacity = 0.7
        startButton.layer.cornerRadius = 10
        
        myView.layer.borderColor = UIColor(named: "LightOrange")?.cgColor
        myView.layer.borderWidth = 2
        myView.layer.shadowColor = UIColor.black.cgColor
        myView.layer.shadowOffset = CGSize(width: 0, height: 0)
        myView.layer.shadowOpacity = 0.7
        myView.layer.cornerRadius = 10
        
        opponentView.layer.borderColor = UIColor(named: "LightOrange")?.cgColor
        opponentView.layer.borderWidth = 2
        opponentView.layer.shadowColor = UIColor.black.cgColor
        opponentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        opponentView.layer.shadowOpacity = 0.7
        opponentView.layer.cornerRadius = 10
    }
    
    // MARK: - Actions
    
    func setupPlayers() {
        guard let opponent = opponent, let me = me else { return }
        opponentName.text = opponent.name
        myName.text = me.name
        
        // Gamers "wantsGameStart" Observer
        USERS_REF.child(opponent.id).child(Const.opponent).child(Const.wantsGameStart).observe(.value, with: { snapshot in
            guard let iWantGameStart = snapshot.value as? Bool else{ return }
            self.startFlag?.0 = iWantGameStart
        })
        
        USERS_REF.child(me.id).child(Const.opponent).child(Const.wantsGameStart).observe(.value, with: { snapshot in
            guard let opponentWantsGameStart = snapshot.value as? Bool else{ return }
            self.startFlag?.1 = opponentWantsGameStart
        })
        
        // Gamers "choice" Observer
        USERS_REF.child(opponent.id).child(Const.opponent).child(Const.choice).observe(.value, with: { snapshot in
            guard let value = snapshot.value as? Int else { return }
            let mychoice = RPS(rawValue: value)
            self.me?.choice = mychoice
        })
        
        USERS_REF.child(me.id).child(Const.opponent).child(Const.choice).observe(.value, with: { snapshot in
            guard let value = snapshot.value as? Int else { return }
            let opponentChoice = RPS(rawValue: value)
            self.opponent?.choice = opponentChoice
        })
        
        // Opponent "isInGame" Observer
        USERS_REF.child(opponent.id).child(Const.isInGame).observe(.value, with: { snapshot in
            guard let value = snapshot.value as? Bool else { return }
            print(value, #function)
            self.opponentIsInGame = value
        })
    }
    
    private func gamePlay() {
        startButton.isEnabled.toggle()
        buttonisEnabled(true)
        reset()
        playSound()
    }
    
    private func reset() {
        
        resultLabel.text = "게임 시작"

        opponentChoiceImageView.image = UIImage(named: "쨰려봐")
        myChoiceImageView.image = UIImage(named: "쨰려봐")
        
        self.opponent?.choice = nil
        self.me?.choice = nil
        
        USERS_REF.child(me!.id).child(Const.opponent).child(Const.choice).setValue(nil)
        USERS_REF.child(opponent!.id).child(Const.opponent).child(Const.choice).setValue(nil)
    }
    
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
            
            print("play sound error: ",error.localizedDescription)
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
    
    @objc func exit() {
        
        guard let presentingVC = self.presentingViewController as? MainViewController else { return }
        guard let opponentId = opponent?.id, let myId = me?.id else { return }
        
        USERS_REF.child(myId).child(Const.isInGame).setValue(false)
        USERS_REF.child(myId).child(Const.isInGame).setValue(false)

        USERS_REF.child(opponentId).child(Const.opponent).removeValue()
        USERS_REF.child(opponentId).child(Const.opponent).removeAllObservers()
        USERS_REF.child(opponentId).child(Const.isInGame).removeAllObservers()
        
        presentingVC.fetchUsersData()
        
        self.dismiss(animated: true)
    }
    
    @IBAction func startGame(_ sender: Any) {

        showMessage(title: "게임 시작", message: "게임을 시작할까요?", firstAction: .yes, secondAction: .no, firstActionCompletion: { _ in
            self.opponent?.oppoenentWantGameStart(true)
            self.showMessage(title: "대기중", message: "상대방을 기다려 주세요", action: .cancel) { _ in
                self.opponent?.oppoenentWantGameStart(false)
            }
        })
    }
    
    @IBAction func rockPaperScissors(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        switch button.tag {
            case 0:
                rockButton.isEnabled = false
                paperButton.isEnabled = true
                scissorsButton.isEnabled = true
                myChoiceImageView.image = UIImage(named: button.currentTitle ?? "")
                myChoiceImageView.backgroundColor = .white
            case 1:
                rockButton.isEnabled = true
                paperButton.isEnabled = false
                scissorsButton.isEnabled = true
                myChoiceImageView.image = UIImage(named: button.currentTitle ?? "")
                myChoiceImageView.backgroundColor = .white
                
            case 2:
                rockButton.isEnabled = true
                paperButton.isEnabled = true
                scissorsButton.isEnabled = false
                myChoiceImageView.image = UIImage(named: button.currentTitle ?? "")
                myChoiceImageView.backgroundColor = .white
            default:
                break
        }
        
        self.me?.choice = RPS(rawValue: button.tag)
        
        USERS_REF.child(opponent!.id).child(Const.opponent).updateChildValues([Const.choice: button.tag])
    }
    
    // 튜플의 Equatable처리를 위해 만든 함수
    func compareTuples <T: Equatable> (tuple1: (T, T), tuple2: (T, T)) -> Bool {
        return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
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
        
        let winner = compare(myChoice: me!.choice, opponentChoice: opponent!.choice)
        showResult(winner: winner)
    }
    
    // MARK: Actions
    
    private func compare(myChoice: RPS?, opponentChoice: RPS?) -> String {
        
        if myChoice == nil && opponentChoice == nil {
            return Const.draw
        } else if myChoice == nil {
            return opponent!.id
        } else if opponentChoice == nil {
            return me!.id
        } else {
            switch (myChoice, opponentChoice) {
            case (.rock, .rock):     return Const.draw
            case (.rock, .paper):    return opponent!.id
            case (.rock, .scissors): return me!.id
                
            case (.paper, .rock):     return me!.id
            case (.paper, .paper):    return Const.draw
            case (.paper, .scissors): return opponent!.id
                
            case (.scissors, .rock):     return opponent!.id
            case (.scissors, .paper):    return me!.id
            case (.scissors, .scissors): return Const.draw
                
            default:
                return "compare error"
            }
        }
    }
    
    private func showResult(winner: String) {

        switch opponent?.choice {
            case .paper:
                opponentChoiceImageView.backgroundColor = .white
                opponentChoiceImageView.image = UIImage(named: "paper")
            case .rock:
                opponentChoiceImageView.backgroundColor = .white
                opponentChoiceImageView.image = UIImage(named: "rock")
            case .scissors:
                opponentChoiceImageView.backgroundColor = .white
                opponentChoiceImageView.image = UIImage(named: "scissors")
            case nil:
                fallthrough
            case .some(.none):
                break
        }
        if winner == Const.draw {
            resultLabel.text = "무승부! 재대결 해야죠?"
        } else if winner == opponent!.id {
            resultLabel.text = " 졌어요.. 😭 "
        } else if winner == me!.id {
            resultLabel.text = " 이겼어요!! 🎉 "
        }
        
        if winner == opponent!.id {
            USERS_REF.child(opponent!.id).child(Const.record).child(Const.win).getData { (_, snapshot) in
                guard let winCount = snapshot?.value as? Int else { return }
                USERS_REF.child(self.opponent!.id).child(Const.record).updateChildValues([Const.win:winCount + 1])
            }
        } else if winner == me!.id {
            USERS_REF.child(opponent!.id).child(Const.record).child(Const.lose).getData { (_, snapshot) in
                guard let loseCount = snapshot?.value as? Int else { return }
                USERS_REF.child(self.opponent!.id).child(Const.record).updateChildValues([Const.lose:loseCount + 1])
            }
        }
        
        USERS_REF.child(me!.id).child(Const.opponent).updateChildValues([Const.wantsGameStart: false])
        USERS_REF.child(opponent!.id).child(Const.opponent).updateChildValues([Const.wantsGameStart: false])
        
        startButton.isEnabled.toggle()
        askGameAgain()
    }
    
    private func askGameAgain() {
        startButton.setTitle("재대결", for: .normal)
    }
}

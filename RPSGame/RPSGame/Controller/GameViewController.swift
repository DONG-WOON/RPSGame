//
//  GameViewController.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/18.
//

import UIKit

final class GameViewController: UIViewController {
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var startButton: UIButton!
    var opponent: User? = nil
    var mycard: RPS?
    var token = 0   //토큰이 1일 때 나가면 무조건
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func goChat(_ sender: Any) {
        
    }
    
    @IBAction func startGame(_ sender: Any) {
        /*
         토큰 1로 바꾸기
         가위바위보 사운드 재생
         가위바위보 버튼들 활성화
         이 버튼 비활성화
         상대방이 째려보는 사진 내리고
         사운드 재생 속도에 맞춰 가위바위보 ui를 글로, 차례대로 보여주기
         백그라운드에서 상대의 패가 있다면 가져오는 시도 지속하기
         */
        
    }
    
    @IBAction func rockPaperScissors(_ sender: Any) {
        
    }
    
    //게임 시작 눌렀을 때
    private func playSound() {
        
    }
    
    private func showStandByUIView() {
        
    }
    
    private func disableStarGameButton() {
        
    }
    
    private func enableCards() {
        
    }
    
    private func recievePartysCard() {
        
    }
    
    // 패 눌렀을 때
    private func uploadMyCard() {
        
    }
    
    private func compareCards() {
        
    }
    
    private func showResult() {
        askGameAgain()
    }
    
    private func askGameAgain() {
//        내 전적 데이터 변경
//        토큰 0으로 바꾸고
//        버튼label을 "리겜?" 으로 바꿈
    }
}

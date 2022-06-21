//
//  GameData.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/05.
//

import Foundation
import Firebase


struct GamerInfo {
    var name: String
    var choice: RPS?    // lazy는 optional일 때 못씀!
    var wantsGameStart: Bool
    
//    func fetchGamerInfo(of username: String) {
//
//    }
}

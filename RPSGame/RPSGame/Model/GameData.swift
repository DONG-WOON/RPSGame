//
//  GameData.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/05.
//

import Foundation


struct GameData {
    var userName: String
    var userChoice: RPS?    // lazy는 optional일 때 못씀!
    var userWantGameStart: Bool
}

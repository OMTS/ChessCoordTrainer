//
//  Square.swift
//  ChessCoordTrainer
//
//  Created by Iman Zarrabian on 16/02/2018.
//  Copyright © 2018 One More Thing Studio. All rights reserved.
//

import Foundation

typealias Rank = Int
typealias File = String

struct Square {
    var rank: Rank
    var file: File
    var flatRank: Int
    
    var name: String {
        return file + "\(rank)"
    }
}

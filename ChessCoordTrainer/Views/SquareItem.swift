//
//  SquareItem.swift
//  ChessCoordTrainer
//
//  Created by Iman Zarrabian on 15/02/2018.
//  Copyright © 2018 One More Thing Studio. All rights reserved.
//

import Cocoa

class SquareItem: NSCollectionViewItem {

    enum ResultType {
        case correct
        case wrong
    }
    var result: ResultType = .correct {
        didSet {
            switch result {
            case .correct:
                view.layer?.borderColor = NSColor.green.cgColor
            case .wrong:
                view.layer?.borderColor = NSColor.red.cgColor
            }
        }
    }
   /*var wiselySelected = false {
        didSet {
            view.layer?.borderColor = NSColor.green.cgColor
            isSelected = true
        }
    }

    var poorlySelected = false {
        didSet {
            view.layer?.borderColor = NSColor.red.cgColor
            isSelected = true
        }
    }*/

    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 5.0 : 0.0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true

        view.layer?.borderColor = NSColor.green.cgColor
        view.layer?.borderWidth = 0.0
    }
    
}

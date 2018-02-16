//
//  ViewController.swift
//  ChessCoordTrainer
//
//  Created by Iman Zarrabian on 15/02/2018.
//  Copyright © 2018 One More Thing Studio. All rights reserved.
//

import Cocoa
import AVFoundation

class BoardViewController: NSViewController {

    @IBOutlet weak var whiteFilesCoord: NSStackView!
    @IBOutlet weak var whiteRanksCoord: NSStackView!
    @IBOutlet weak var blackFilesCoord: NSStackView!
    @IBOutlet weak var blackRanksCoord: NSStackView!
    @IBOutlet weak var board: NSCollectionView!
    @IBOutlet weak var sideSwitch: NSButton!
    @IBOutlet weak var showCoordSwitch: NSButton!
    @IBOutlet weak var cpmSlider: NSSlider!
    @IBOutlet weak var cpmLabel: NSTextField!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var hudView: NSView!
    @IBOutlet weak var currentSquareLabel: NSTextField!
    
    fileprivate var currentSquare: Square?
    fileprivate var soundPlayer: AVAudioPlayer?

    let gameLogic = Logic()

    var isWhitePlaying: Bool {
        return sideSwitch.state == NSControl.StateValue.on
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHudView()
        configureGamePlay()
    }

    @IBAction func cpmChanged(_ sender: NSSlider) {
        cpmLabel.stringValue = "\(sender.integerValue)CPM (Coords Per Min)"
    }

    @IBAction func startGame(_ sender: NSButton) {
        sideSwitch.isEnabled = false
        showCoordSwitch.isEnabled = false
        cpmSlider.isEnabled = false
        startButton.isEnabled = false
        gameLogic.startGame(cpm: cpmSlider.integerValue, isWhitePerspective: isWhitePlaying)
 }

    @IBAction func switchSides(_ sender: NSButton) {
        if showCoordSwitch.state == NSControl.StateValue.on {
            showAppropriateCoord()
        }
    }

    @IBAction func switchShowCoord(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            //show the active coord
            showAppropriateCoord()
        } else {
            //just hide everything
            whiteFilesCoord.isHidden = true
            whiteRanksCoord.isHidden = true
            blackFilesCoord.isHidden = true
            blackRanksCoord.isHidden = true
        }
    }

    fileprivate func configureGamePlay() {
        gameLogic.passiveTickhandler = { nbOfTicks in
            self.playSound(alternateSound: true)

            if nbOfTicks < 3 {
                self.currentSquareLabel.stringValue = "\(nbOfTicks + 1)"
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 0.1
                    self.hudView.animator().alphaValue = 1.0
                }, completionHandler: nil)
            }
        }

        gameLogic.activeTickHandler = { square in
            self.currentSquare = square
            self.currentSquareLabel.stringValue = self.currentSquare!.name
            self.playSound()
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.1
                self.hudView.animator().alphaValue = 1.0
            }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NSAnimationContext.runAnimationGroup({ (context) in
                        context.duration = 0.2
                        self.hudView.animator().alphaValue = 0.0
                    }, completionHandler: nil)
                }
            }
        }
        gameLogic.gameOverHandler = {
            self.sideSwitch.isEnabled = true
            self.showCoordSwitch.isEnabled = true
            self.cpmSlider.isEnabled = true
            self.startButton.isEnabled = true
        }
    }

    fileprivate func setupHudView() {
        hudView.alphaValue = 0.0
        hudView.wantsLayer = true
        hudView.layer?.backgroundColor = NSColor(deviceRed: 0, green: 0, blue: 0, alpha:0.7).cgColor
        hudView.layer?.cornerRadius = 20.0
        hudView.layer?.masksToBounds = true
    }

    fileprivate func showAppropriateCoord() {
        if isWhitePlaying {
            //show coord for whites
            whiteFilesCoord.isHidden = false
            whiteRanksCoord.isHidden = false
            blackFilesCoord.isHidden = true
            blackRanksCoord.isHidden = true
        } else {
            whiteFilesCoord.isHidden = true
            whiteRanksCoord.isHidden = true
            blackFilesCoord.isHidden = false
            blackRanksCoord.isHidden = false
        }
    }

    fileprivate func playSound(alternateSound: Bool = false) {

        let path = alternateSound ? Bundle.main.path(forResource: "beep-07.wav", ofType:nil)! : Bundle.main.path(forResource: "beep-08b.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.play()
        } catch {
            print("Sound file nout found")
        }
    }
}

//CollectionView datasource and delegate
extension BoardViewController : NSCollectionViewDataSource, NSCollectionViewDelegate{

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 64
    }

    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        let item = board.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SquareItem"), for: indexPath) as! SquareItem

        let row = indexPath.item / 8
        let column = indexPath.item % 8

        item.view.layer?.backgroundColor = (row % 2) == (column % 2) ?  NSColor.white.cgColor : NSColor.black.cgColor
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            collectionView.deselectItems(at: indexPaths)
        }
    }

    func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {

        guard gameLogic.gameIsStarted, let square = currentSquare else {
            return []
        }

        let selectedItemNumber = indexPaths.first!.item

        let tappedItem = collectionView.item(at: indexPaths.first!) as! SquareItem

        if selectedItemNumber == square.flatRank {
            tappedItem.result = .correct
            return [indexPaths.first!]

        } else {

            let correctIndexPath = try! gameLogic.indexPathForItem(itemNumber: square.flatRank)
            let correctItem = collectionView.item(at: correctIndexPath) as! SquareItem

            tappedItem.result = .wrong
            correctItem.result = .correct

            return [indexPaths.first!, correctIndexPath]
        }
    }
}


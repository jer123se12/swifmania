//
//  introviewcontroller.swift
//  test
//
//  Created by lightweight on 12/5/21.
//

import Cocoa
import SpriteKit
import GameplayKit

class introviewcontroller: NSViewController {
    
    @IBOutlet var skView: SKView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            
            if let scene = SKScene(fileNamed: "intro") {
                // Set the scale mode to scale to fit the window
                
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
        }
    }
    
}

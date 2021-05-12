//
//  ViewController.swift
//  test
//
//  Created by lightweight on 26/4/21.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {
    func getfiles()->([String],[[String]]){
        let f=FileManager.default
        let home=f.homeDirectoryForCurrentUser
        var dirs:[String]=[]
        var songfiles:[[String]]=[]
        do {
            dirs = try f.contentsOfDirectory(atPath: home.appendingPathComponent("Documents").appendingPathComponent("Songs").path)
            if dirs==[]{
                try f.createDirectory(at: home.appendingPathComponent("Documents").appendingPathComponent("Songs"), withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            OSErr("error very helpful")
        }
        var osuf:[String]=[]
        for dir in dirs{
            do {
                let temp = try f.contentsOfDirectory(atPath: home.appendingPathComponent("Documents").appendingPathComponent("Songs").appendingPathComponent(dir).path)
                if !(temp==[]){
                    osuf.append(dir)
                }
            } catch {
                OSErr("error very helpful")
            }
        }
        dirs=osuf
        for dir in dirs{
            do {
                let files=try f.contentsOfDirectory(atPath: home.appendingPathComponent("Documents").appendingPathComponent("Songs").appendingPathComponent(dir).path)
                var osu:[String]=[]
                for file in files{
                    if file.suffix(4)==".osu"{
                        osu.append(file)
                    }
                }
                songfiles.append(osu)
                
            } catch {
                OSErr("error very helpful")
            }
        }
        return (dirs,songfiles)
    }
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            
            if let scene = SKScene(fileNamed: "GameScene") {
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


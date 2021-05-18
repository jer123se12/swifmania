//
//  intro.swift
//  test
//
//  Created by lightweight on 12/5/21.
//

import SpriteKit
import GameplayKit
import AVFoundation
import Cocoa

class intro: SKScene  {
    
    func getfiles()->([String],[[String]]){
        let f=FileManager.default
        let home=f.homeDirectoryForCurrentUser.appendingPathComponent("Documents")
        var dirs:[String]=[]
        var songfiles:[[String]]=[]
        do {
            dirs = try f.contentsOfDirectory(atPath: home.appendingPathComponent("Songs").path)
            if dirs==[]{
                try f.createDirectory(at: home.appendingPathComponent("Songs"), withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            OSErr("error very helpful")
        }
        var osuf:[String]=[]
        
        for dir in dirs{
            
            do {
                let temp = try f.contentsOfDirectory(atPath: home.appendingPathComponent("Songs").appendingPathComponent(dir).path)
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
                let files=try f.contentsOfDirectory(atPath: home.appendingPathComponent("Songs").appendingPathComponent(dir).path)
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
    func getsongfile(filename:String) -> String{
        let lines = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8).split(separator:"\r\n")
        var returns=""
        for line in lines{
            if line.contains("AudioFilename: "){
                returns = String(line.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return returns
    }
    func circle(pos: CGPoint,colorin: SKColor,rad: CGFloat,wid:CGFloat=0,colorout: SKColor=SKColor.white,z:CGFloat=0)-> SKShapeNode{
        let circle = SKShapeNode(circleOfRadius: rad )
        
        circle.position = pos
        circle.strokeColor = colorout
        circle.glowWidth = wid
        circle.fillColor = colorin
        circle.zPosition=z
        self.addChild(circle)
        return circle
    }
    func rect(colorin: SKColor,rect: CGRect,wid:CGFloat=0,colorout: SKColor=SKColor.white,z:CGFloat=0)->SKShapeNode{
        let rec = SKShapeNode(rect: rect)
        rec.fillColor = SKColor.white
        rec.strokeColor = colorout
        rec.glowWidth = wid
        rec.fillColor = colorin
        rec.zPosition=z
        self.addChild(rec)
        return rec
    }
    func gettitle(filename:String) -> String{
      let lines = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8).split(separator:"\r\n")
      var returns=""
      for line in lines{
        if line.contains("Title:"){
          returns = String(line.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }
      return returns
    }
    func getver(filename:String) -> String{
      let lines = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8).split(separator:"\r\n")
      var returns=""
      for line in lines{
        if line.contains("Version:"){
          returns = String(line.split(separator: ":")[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }
      return returns
    }
    let ud=UserDefaults.standard
    var songselected=[0,0]
    var audioPlayer = AVAudioPlayer()
    var totalSongs=(0,[0])
    var texts:[SKLabelNode]=[]
    var title:SKLabelNode!=SKLabelNode()
    var ver:SKLabelNode!=SKLabelNode()
    var inVer:Bool=false
    var songs:([String],[[String]])=([],[[]])
    let theme:[SKColor]=[SKColor(red: 34/255, green: 116/255, blue: 165/255, alpha: 1),//"Star Command Blue"
                         SKColor(red: 125/255, green: 29/255, blue: 163/255, alpha: 1),//"Claret"
                         SKColor(red: 81/255, green: 37/255, blue: 0/255, alpha: 1),//"Seal Brown"
                         SKColor(red: 22/255, green: 193/255, blue: 255/255, alpha: 1),//"Mauve"
                         SKColor(red: 0/255, green: 204/255, blue: 102/255, alpha: 1)]//"Emerald"
    func reload()->(Int,[Int],([String],[[String]])){
        let f=FileManager.default
        
        let songdir=f.homeDirectoryForCurrentUser.appendingPathComponent("Documents").appendingPathComponent("Songs")
        let listOfSongs=getfiles()
        var vers:[Int]=[]
        if listOfSongs.0.count>0 {
            let osufile=songdir.appendingPathComponent(listOfSongs.0[songselected[0]]).appendingPathComponent(listOfSongs.1[songselected[0]][songselected[1]])
            
            let odir=songdir.appendingPathComponent(listOfSongs.0[songselected[0]])
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: odir.appendingPathComponent(getsongfile(filename: osufile.path)))
                audioPlayer.play()
            }catch{
                
            }
            
            for song in listOfSongs.1{
                vers.append(song.count)
            }
        }
        return (listOfSongs.0.count,vers,listOfSongs)
    }
    func getname()->([String],[[String]]){
        let f=FileManager.default
        
        let songdir=f.homeDirectoryForCurrentUser.appendingPathComponent("Documents").appendingPathComponent("Songs")
        let listOfSongs=getfiles()
        var title:[String] = []
        var vers:[[String]]=[]
        for t in 0...listOfSongs.0.count-1{
            title.append(gettitle(filename: songdir.appendingPathComponent(listOfSongs.0[t]).appendingPathComponent(listOfSongs.1[t][0]).path))
            vers.append([])
            for v in 0...listOfSongs.1[t].count-1{
                vers[t].append(getver(filename: songdir.appendingPathComponent(listOfSongs.0[t]).appendingPathComponent(listOfSongs.1[t][v]).path))
            }
        }
        print(title,vers)
//        var fulltext=try! String(contentsOfFile: file.path).split(separator:"\r\n")
        return (title,vers)
    }
    override func keyDown(with event: NSEvent) {
        guard !event.isARepeat else {return}
        let keycode = event.keyCode
        print(songselected[0],totalSongs.0)
        if keycode==125{//up
            
            if !inVer{
            songselected[0]+=1
            songselected[1]=0
            if songselected[0]>=totalSongs.0{
                songselected[0]=0
                
            }}else{
                songselected[1]+=1
                
                if songselected[1]>=totalSongs.1[songselected[0]]{
                    songselected[1]=0
                }
            }
            reload()
        }else if keycode==126{//down
            
            if !inVer{
            songselected[0]-=1
            songselected[1]=0
            if songselected[0]<=0{
                songselected[0]=totalSongs.0-1
            }}else{
                songselected[1]-=1
                
                if songselected[1]<=0{
                    songselected[1]=totalSongs.1[songselected[0]]-1
                }
            }
            reload()
        }else if event.characters=="\r"{
            if !inVer{
                inVer=true
            }else{
                //go to play
                
                ud.set(songselected, forKey: "selected")
                let scene = SKScene(fileNamed: "GameScene")!
                let transition = SKTransition.fade(with: NSColor.black, duration: 1)
                self.removeAllChildren()
                self.view?.presentScene(scene, transition: transition)
                
            }
        }else if event.characters=="\u{1B}"{
            inVer=false
        }
        
//
//            if(keycode == 125)//up
//
//            {
//
//            }
//
//            else if(keycode == 126)//down
//
//            {
//                player.position.y += 10
//            }
//
//            if(keycode == 124)//right
//
//            {
//                player.position.x += 10
//            }
//
//            else if(keycode == 123)//left
//
//            {
//                player.position.x -= 10
//
//            }
        updateLabels()
    }
    func updateLabels(){
        
        
        title?.fontSize=CGFloat(30-((songs.0[songselected[0]].count-19)))
        title.text=songs.0[songselected[0]]
        ver.text=songs.1[songselected[0]][songselected[1]]
        
        for count in 0...9{
            if !inVer{
                if (count-5)+songselected[0] <= songs.0.count-1 && (count-5)+songselected[0] >= 0{
                    let songse=songs.0[(count-5)+songselected[0]]
                    texts[count].text=songse
                    texts[count].fontSize=CGFloat(20-((songse.count-20)/2))
                    
                }else{
                    texts[count].text=""
                }
            }else{
                if (count-5)+songselected[1] <= songs.1[songselected[0]].count-1 && (count-5)+songselected[1] >= 0{
                    let songse=songs.1[songselected[0]][(count-5)+songselected[1]]
                    texts[count].text=songse
                    texts[count].fontSize=CGFloat(20-((songse.count-20)/2))
                    
                }else{
                    texts[count].text=""
                }
            }
            
        }
    }
    override func sceneDidLoad() {
        super .sceneDidLoad()
        let stuff=reload()
        totalSongs = (stuff.0,stuff.1)
        songs=getname()
        print(self.children)
        title=self.childNode(withName: "helpmenotworking") as! SKLabelNode
        
        
        ver=(self.childNode(withName: "sdesc") as! SKLabelNode)
        for count in 0...9{
            texts.append(self.childNode(withName: String(count))!.childNode(withName: String(count)+"text")  as! SKLabelNode)
        }
        updateLabels()
        
    }
    
    
    
}

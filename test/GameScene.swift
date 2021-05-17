//
//  GameScene.swift
//  test
//
//  Created by lightweight on 26/4/21.
//

import SpriteKit
import GameplayKit
import AVFoundation
import Cocoa

class GameScene: SKScene  {
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
  func amtofkeys(filename:String) -> Int{
    let lines = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8).split(separator:"\r\n")
    var temp:[String]=[]
    var hit = false
    for line in lines{
      if hit{
        //var line2:[String] = line.split(seperator:",")[:-1] + [line.split(",")[5].split(":")[0]]
        let line2=line.split(separator: ",").map{String($0)}
        
        if temp.contains(line2[0]){
          continue
        }else{
          temp.append(line2[0])
        }
      }
      else{
        if line.contains("[HitObjects]"){
          hit = true
        }
      }
    }
    
    return temp.count
  }
  func getsong(filename:String,amoky:Int)->([[String]], [[[String]]]){
    let lines=try! String(contentsOfFile: filename).split(separator:"\r\n")
    var song:[[String]]=[]
    var hold:[[[String]]]=[]
    var hit=false
    for _ in 0...amoky-1{
      song.append([])
      hold.append([])
    }
    
    //math.floor((int(line[0]) * amoky) / 512)
    for line in lines{
      if hit{
        var line2=line.split(separator: ",")
        let last=line2.last!.split(separator: ":")[0]
        line2.removeLast()
        line2.append(last)
        let ind:Int=((Int(line2[0])! * amoky) / 512)
        if line2[3]=="128"{
          hold[ind].append([String(line2[2]),String(line2[5])])
        }
        song[ind].append(String(line2[2]))
      }else{
        if line.contains("[HitObjects]"){
          hit=true
        }
      }
    }
    for a in 0...amoky-1{
      song[a].append("999999999999999")
      hold[a].append(["999999999999999","999999999999999"])
    }
    return (song,hold)
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
  func initialtext(font:String,pos:CGPoint,z:CGFloat=0)-> SKLabelNode{
    let text = SKLabelNode(fontNamed: font)
    
    text.position = CGPoint(x: frame.midX, y: frame.midY)
    text.zPosition=z
    return (text)
  }
  func show(label:SKLabelNode,text:String,size:CGFloat,color:SKColor){
    label.removeFromParent()
    label.text=text
    label.fontSize = size
    label.fontColor = color
    self.addChild(label)
  }
  func contains(keys:[String],charaters:String)->Bool{
    
    for chr in charaters{
      if keys.contains(String(chr)){
        return true
      }
    }
    return false
  }
  
  
  //vars
  let ud=UserDefaults.standard
  var starttime=(CACurrentMediaTime()*1000)+3000
  var song:([[String]], [[[String]]])=([[""]], [[[""]]])
  var amt:Int=0
  var startupdating=false
  var juy:CGFloat=0
  var wid:CGFloat=0
  var hei:CGFloat=0
  var midwid:CGFloat=0
  var midhei:CGFloat=0
  var lanes:[CGFloat]=[]
  var remove:[SKShapeNode]=[]
  var combo=0
  var light:[SKShapeNode]=[]
  var held:[Bool]=[]
  var colors:[SKColor]=[]
  var colorsout:[SKColor]=[]
  var times:[Int]=[0]
  var font:SKLabelNode?=nil
  var combotext:SKLabelNode?=nil
  var judgetext:SKLabelNode?=nil
  var acctext:SKLabelNode?=nil
  var audioPlayer = AVAudioPlayer()
  var hitplayer=AVAudioPlayer()
  var score:[Int]=[6]
  var lasthit:Double=0
  var songneedtostarted:Bool=true
  
  
  
  
  
  //can be edited
  let judge=[
    "EXCELLENT",
    "PERFECT",
    "GREAT",
    "GOOD",
    "MISS",
    ""
  ]
  var songselected=[6,4]//current song you will play
  let jt = [22, 40, 90, 130, 180, 200]
  let allkeys=[[],[" "],["s","k"],["s"," ","k"],["d","c","m","k"],["a","s"," ","k","l"],["a","s","d","j","k","l"],["a","s","d"," ","j","k","l"]]
  var keys:[String]=["a","s","d"," ","j","k","l"]//keys
  let scroll:CGFloat=700
  let rad:CGFloat=25
  let theme:[SKColor]=[SKColor(red: 34/255, green: 116/255, blue: 165/255, alpha: 1),//"Star Command Blue"
                       SKColor(red: 125/255, green: 29/255, blue: 163/255, alpha: 1),//"Claret"
                       SKColor(red: 81/255, green: 37/255, blue: 0/255, alpha: 1),//"Seal Brown"
                       SKColor(red: 22/255, green: 193/255, blue: 255/255, alpha: 1),//"Mauve"
                       SKColor(red: 0/255, green: 204/255, blue: 102/255, alpha: 1)]//"Emerald"
  override func keyUp(with event: NSEvent) {
    if contains(keys: keys, charaters: event.characters!) {
      let elp=(CACurrentMediaTime()*1000)-starttime
      for key in 0...keys.count-1{
        if event.characters!.contains(keys[key]){
          held[key]=false
          light[key].removeFromParent()
          light[key]=circle(pos: CGPoint(x: lanes[key], y: juy), colorin: colors[key], rad: CGFloat(rad), wid: CGFloat(1), colorout: colorsout[2],z:1)
          if Int(elp)>Int(song.1[key][0][0])! && Int(elp)<Int(song.1[key][0][1])!-200{
            combo=0
            song.1[key].removeFirst()
            
          }else {
            for index in 0...jt.count-1{
              if Int(elp)<Int(song.1[key][0][1])!+jt[index] && Int(elp)>Int(song.1[key][0][1])!-jt[index]{
                judgetext?.text=judge[index]
                //show(label: font!, text: judge[index], size: 20, color: SKColor.white)
                score.append(jt.count-index)
                times.append(Int(elp)-Int(song.1[key][0][1])!)
                if index<4{
                  combo+=1
                  
                }else{
                  combo=0
                }
                song.1[key].removeFirst()
                combotext?.text=String(combo)
                lasthit=elp
                let percent=(Double(score.reduce(0,+))/Double(score.count*jt.count))*100
                acctext?.text=String(round(percent*10)/10)+"%"
                break
                
              }
              
            }
            
          }
          break
        }
      }
    }
  }
  func playsound(){
    DispatchQueue.global().async {
      let new=self.hitplayer
      new.play()}
  }
  override func keyDown(with event: NSEvent) {
    guard !event.isARepeat else { return }
    //playsound()
    
    
    
    if contains(keys: keys, charaters: event.characters!){
      let elp=(CACurrentMediaTime()*1000)-starttime
      for key in 0...keys.count-1{
        if event.characters!.contains(keys[key]){
          held[key]=true
          light[key].removeFromParent()
          light[key]=circle(pos: CGPoint(x: lanes[key], y: juy), colorin: colorsout[key], rad: CGFloat(rad), wid: CGFloat(1), colorout: colorsout[2],z:1)
          for index in 0...jt.count-1{
            if Int(elp)<Int(song.0[key][0])!+jt[index] && Int(elp)>Int(song.0[key][0])!-jt[index]{
              judgetext?.text=judge[index]
              score.append(jt.count-index)
              //show(label: font!, text: judge[index], size: 20, color: SKColor.white)
              times.append(Int(elp)-Int(song.0[key][0])!)
              //print(times)
              if index<4{
                combo+=1
                
              }else{
                combo=0
              }
              song.0[key].removeFirst()
              combotext?.text=String(combo)
              lasthit=elp
              let percent=(Double(score.reduce(0,+))/Double(score.count*jt.count))*100
              acctext?.text=String(round(percent*10)/10)+"%"
              
              break
              
            }
            
          }
          break
        }
      }
    }
  }
  override func update(_ currentTime: TimeInterval) {
    
    if startupdating{
      
      for node in remove{
        node.removeFromParent()
        
      }
      remove=[]
      let elp=(CACurrentMediaTime()*1000)-starttime
      if songneedtostarted && elp>0{
        DispatchQueue.global().async {
          
          self.audioPlayer.play()
          self.starttime=(CACurrentMediaTime()*1000)
        }
        songneedtostarted=false
        
      }
      judgetext?.alpha=5-CGFloat((elp-lasthit)/100)
      judgetext?.fontSize=32-CGFloat((elp-lasthit)/50)
      //scroll-----------------
      for lane in 0...song.0.count-1{
        if Double(song.0[lane][0])!<elp-200{
          song.0[lane].removeFirst()
          score.append(1)
          times.append(200)
          judgetext?.text=judge[4]
          //show(label: font!, text: judge[4], size: 20, color: SKColor.white)
          combo=0
          lasthit=elp
          combotext?.text=String(combo)
          
          let percent=(Double(score.reduce(0,+))/Double(score.count*jt.count))*100
          acctext?.text=String(round(percent*10)/10)+"%"
        }
        if Double(song.1[lane][0][1])!<elp-200{
          song.1[lane].removeFirst()
          judgetext?.text=judge[4]
          score.append(1)
          //show(label: font!, text: judge[4], size: 20, color: SKColor.white)
          times.append(200)
          combo=0
          lasthit=elp
          combotext?.text=String(combo)
          let percent=(Double(score.reduce(0,+))/Double(score.count*jt.count))*100
          acctext?.text=String(round(percent*10)/10)
        }
        for notes in 0...song.1[lane].count-1{
          let start=Double(song.1[lane][notes][0])!
          
          let st=CGFloat(start - elp) / scroll
          
          let y1 =  (st * (midhei-juy))+juy
          
          let x = lanes[lane]
          if y1<midhei{
            
            let end=Double(song.1[lane][notes][1])!
            let en=CGFloat(end - elp) / scroll
            var y2 =  (en * (midhei-juy))+juy
            if y2>midhei{
              y2=midhei
              
              var size=y1-y2
              if held[lane] && (elp > Double(song.1[lane][notes][0])!) && (elp < Double(song.1[lane][notes][1])!+200){
                size=juy-y2
              }
              if size>0{
                size=0
              }else{
                remove.append(rect(colorin: colors[lane].withAlphaComponent(0.4), rect: CGRect(x: x-rad, y: y2, width: 2*rad, height: size),wid: CGFloat(1), colorout: colorsout[2]))
                
              }
              
            }
            else{
              var size=y1-y2
              if held[lane] && (elp > Double(song.1[lane][notes][0])!) && (elp < Double(song.1[lane][notes][1])!+200){
                size=juy-y2
              }
              if size>0{
                size=0
              }else{
                remove.append(rect(colorin: colors[lane].withAlphaComponent(0.4), rect: CGRect(x: x-rad, y: y2, width: 2*rad, height: size),wid: CGFloat(1), colorout: colorsout[2]))
                remove.append(circle(pos: CGPoint(x: x, y: y2), colorin: colors[lane], rad: CGFloat(rad), wid: CGFloat(1), colorout: colorsout[2]))
                
              }
              
              
            }
            
          }
          else{
            break
          }
        }
        for notes in 0...song.0[lane].count-1{
          let note=Double(song.0[lane][notes])!
          let percent=CGFloat(note - elp) / scroll
          let y =  (percent * (midhei-juy))+juy
          let x = lanes[lane]
          if y<midhei{
            remove.append(circle(pos: CGPoint(x: x, y: y), colorin: colors[lane], rad: CGFloat(rad), wid: CGFloat(1), colorout: colorsout[2]))
          }
          else{
            break
          }
        }
        
      }
      
      
      var times2=times
      var avg:Int=0
      times2.reverse()
      var count=0
      for t in times2{
        avg+=t
        count+=1
        
        if count>9{
          break
        }
      }
      remove.append(rect(colorin: theme[1], rect: CGRect(x: (CGFloat(avg/count)/200)*100, y: 50, width: 1, height: 10),colorout: SKColor.white, z: 1.1))
      
      
      
    }//end of start updating
    
  }
  override func sceneDidLoad() {
    super.sceneDidLoad()
    songselected = ud.object(forKey:"selected") as! [Int] 
    let f=FileManager.default
    
    let songdir=f.homeDirectoryForCurrentUser.appendingPathComponent("Documents").appendingPathComponent("Songs")
    let listOfSongs=getfiles()
    
    let osufile=songdir.appendingPathComponent(listOfSongs.0[songselected[0]]).appendingPathComponent(listOfSongs.1[songselected[0]][songselected[1]])
    let odir=songdir.appendingPathComponent(listOfSongs.0[songselected[0]])
    
    
    
    
    
    
    
    combotext = (self.childNode(withName: "combo") as! SKLabelNode)
    judgetext = self.childNode(withName: "judgetext") as? SKLabelNode
    acctext = self.childNode(withName: "acc") as? SKLabelNode
    combotext?.text="0"
    judgetext?.text=""
    do{
      audioPlayer = try AVAudioPlayer(contentsOf: odir.appendingPathComponent(getsongfile(filename: osufile.path)))
//      hitplayer=try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "normal-hitnormal", ofType: "wav")!))
    }catch{
      OSErr("audio not found or smt")
    }
    amt=amtofkeys(filename: osufile.path)
    
    song=getsong(filename:  osufile.path, amoky: amt)
    wid=self.size.width
    hei=self.size.height
    midwid=self.size.width/2
    midhei=self.size.height/2
    juy=CGFloat((-200/600)*hei)
    keys=allkeys[amt]
    startupdating=true
    light=[]
    for a in 0...amt-1{
      held.append(false)
      if a < Int(amt/2) && a%2==0 {
        colors.append(theme[0])
      }else if a < Int(amt/2){
        colors.append(theme[4])
      }
      held.append(false)
      let lanecount=(a - ((amt + 1) / 2))
      let size=Int(2 * rad)
      lanes.append( CGFloat(lanecount * size)+(rad*CGFloat((amt/3))))
      light.append(circle(pos: CGPoint(x: CGFloat(lanecount * size)+(rad*CGFloat((amt/3))), y: juy), colorin: SKColor.blue, rad: CGFloat(rad), wid: CGFloat(1), colorout: SKColor.white))
      
      
    }
    var color2=colors
    color2.reverse()
    if amt%2==1{
      
      colors=colors + [theme[3]] + color2
      
      
    }else{
      colors=colors + color2
    }
    for _ in colors{
      colorsout.append(SKColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1))
    }
    
    didChangeSize(self.size)
    starttime=(CACurrentMediaTime()*1000)+3000
  }
  override func didChangeSize(_ oldSize: CGSize) {
    wid=self.size.width
    hei=self.size.height
    midwid=self.size.width/2
    midhei=self.size.height/2
    juy=CGFloat((-200/600)*hei)
    light=[]
    
    if startupdating{
      for a in 0...amt-1{
        let lanecount=(a - ((amt + 1) / 2))
        let size=Int((2 * rad))
        lanes.append( CGFloat(lanecount * size)+(rad*CGFloat((amt/3))))
        
        
      }
      //print(lanes.last!-lanes.first!)
      rect(colorin: SKColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1), rect: CGRect(x: lanes.first!-rad-5, y: midhei * -1, width: (lanes.last!-lanes.first!)+(2*rad)+10, height: hei),z:-1)
      for a in 0...amt-1{
        let lanecount=(a - ((amt + 1) / 2))
        let size=Int((2 * rad))
        
        light.append(circle(pos: CGPoint(x: CGFloat(lanecount * size)+(rad*CGFloat((amt/3))), y: juy), colorin: colors[a], rad: CGFloat(rad), wid: CGFloat(1), colorout: colorsout[a],z:1))
        
      }
      
    }
    rect(colorin: theme[2], rect: CGRect(x: 0, y: 50, width: 1, height: 10),colorout: SKColor.white,z: 1)
    
  }
  
}

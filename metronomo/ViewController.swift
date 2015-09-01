//
//  ViewController.swift
//  metronomo
//
//  Created by Daniele Elia on 25/02/15.
//  Copyright (c) 2015 Daniele Elia. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    
    @IBOutlet var labelBpm: UILabel!
    @IBOutlet var btnStart: UIButton!
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var labelBattiti: UILabel!
    @IBOutlet var stepperBattiti: UIStepper!
    @IBOutlet var labelNomeTempo: UILabel!

    

    var myTimer: NSTimer?
    var myTimerBattiti: NSTimer?
    var player : AVAudioPlayer?
    var myImageView: UIImageView!
    let altezzaSchermo = UIScreen.mainScreen().bounds.size.height
    let larghezzaSchermo = UIScreen.mainScreen().bounds.size.width
    var tempo: Double = 1
    var bpm: Double = 60
    var battiti: Double = 1
    let yImmagine: CGFloat = 60 //CGFloat(altezzaSchermo/2)
    let larghezzaPallina: CGFloat = 60
    let altezzaPallina:CGFloat = 60
    var inizio = 1
    var tempoIniziale: CFAbsoluteTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let savedBpm = defaults.objectForKey("Bpm") as? String {
            labelBpm.text = savedBpm
            stepper.value = (labelBpm.text! as NSString).doubleValue
        } else {
            labelBpm.text = "\(Int(stepper.value))"
        }
        if let savedBattiti = defaults.objectForKey("Battiti") as? String {
            labelBattiti.text = savedBattiti
            stepperBattiti.value = (labelBattiti.text! as NSString).doubleValue
        } else {
            labelBattiti.text = "\(Int(stepperBattiti.value))"
        }
        
        
        var image = UIImage(named: "pallina")
        myImageView = UIImageView(image: image!)
        myImageView.frame = CGRect(x: CGFloat(30), y: yImmagine, width: larghezzaPallina, height: altezzaPallina)
        view.addSubview(myImageView)
        
        
        var audioSessionError: NSError?
        let audioSession = AVAudioSession.sharedInstance()

        audioSession.setActive(true, error: nil)
        
        if audioSession.setCategory(AVAudioSessionCategoryPlayback, error: &audioSessionError){
            debugPrintln("Successfully set the audio session")
        } else {
            debugPrintln("Could not set the audio session")
        }
        
        calcolaTempo()
        nomeTempo()

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* The delegate message that will let us know that the player
    has finished playing an audio file */
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        //debugPrintln("Finished playing the song")
        //sleep(1)
    }
    
    @IBAction func cambiaBpm(sender: AnyObject) {
        labelBpm.text = "\(Int(stepper.value))"
        calcolaTempo()
    }
    
    @IBAction func cambiaBattit(sender: UIStepper) {
        labelBattiti.text = "\(Int(stepperBattiti.value))"
        calcolaTempo()
    }
    
    func calcolaTempo() {
        bpm = (labelBpm.text! as NSString).doubleValue
        tempo = 60/bpm
        battiti = (labelBattiti.text! as NSString).doubleValue
        nomeTempo()
        debugPrintln("tempo: \(tempo)")
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(labelBpm.text, forKey: "Bpm")
        defaults.setObject(labelBattiti.text, forKey: "Battiti")
        defaults.synchronize()
    }
    
    @IBAction func startStop(sender: UIButton) {
        
        calcolaTempo()

        var lbl: String = "Start"
        var img: String = "play"
        if btnStart.titleLabel?.text == "Start" {
            img = "stop"
            lbl = "Stop"
            inizio = 1
            tempoIniziale = CFAbsoluteTimeGetCurrent()
            myTimer = NSTimer.scheduledTimerWithTimeInterval(0.005,
                target: self,
                selector: "timerMethod:",
                userInfo: nil,
                repeats: true)

            UIScreen.mainScreen().brightness = 0
        } else {
            myTimer?.invalidate()
            self.myTimerBattiti?.invalidate()
            myImageView.frame = CGRectMake(CGFloat(30), yImmagine, larghezzaPallina, altezzaPallina)
            UIScreen.mainScreen().brightness = 0.2
        }
        
        btnStart.setTitle(lbl, forState: UIControlState.Normal)
        let image = UIImage(named: img) as UIImage!
        btnStart.setImage(image, forState: .Normal)
        
        
        
    }
    
    
    
    func timerMethod(sender: NSTimer){
        
        if (CFAbsoluteTimeGetCurrent() - tempoIniziale) >= (tempo) {
            click()
            move()
            tempoIniziale = CFAbsoluteTimeGetCurrent()
        }
        
    }
    
    func move() {
        var origine: CGFloat = 30
        if myImageView.frame.origin.x == 30 {
            origine = larghezzaSchermo - (myImageView.frame.width*2)
        }
        
        UIView.animateWithDuration(tempo, delay: 0.0, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            self.myImageView.frame = CGRectMake(origine, self.myImageView.frame.origin.y, self.myImageView.frame.size.width, self.myImageView.frame.size.height);
            }, completion: nil)
    }
    
    func click() {
        
        var file = NSBundle.mainBundle().URLForResource("toc", withExtension: "aiff")
        
        var error:NSError?
        
        /* Start the audio player */
        self.player = AVAudioPlayer(contentsOfURL: file, error: &error)
        
        /* Did we get an instance of AVAudioPlayer? */
        if let theAudioPlayer = self.player {
            theAudioPlayer.delegate = self;
            if inizio == 1 {
                self.player?.volume = 1
            } else {
                self.player?.volume = 0.2
                //debugPrintln("0.5")
            }
            if theAudioPlayer.prepareToPlay() && theAudioPlayer.play(){
                //debugPrintln("Successfully started playing")
            } else {
                debugPrintln("Failed to play \(error)")
            }
        } else {
            /* Handle the failure of instantiating the audio player */
        }
        debugPrintln("battito: \(inizio)")
        
        inizio = inizio + 1
        if inizio > Int(battiti) {
            inizio = 1
        }
        
    }
    
    
    func nomeTempo() {
        
        var n: String = "Largo"
        
        switch bpm {
        case 40...59: n = "Largo"
        case 60...65: n = "Larghetto"
        case 66...75: n = "Adagio"
        case 76...107: n = "Andante"
        case 108...119: n = "Moderato"
        case 120...167: n = "Allegro"
        case 168...199: n = "Presto"
        case 200...250: n = "Prestissimo"
        default: n = " "
        }
        
        labelNomeTempo.text = n
    }
    
    
    func handleInterruption(notification: NSNotification){
        /* Audio Session is interrupted. The player will be paused here */
        let interruptionTypeAsObject = notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
        let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeAsObject.unsignedLongValue)
        if let type = interruptionType{
        if type == .Ended{
                /* resume the audio if needed */
        } }
        debugPrintln("interruption")
    }


    // ======== respond to remote controls
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        /*
        let rc = event.subtype
        if let theAudioPlayer = self.player {
            println("received remote control \(rc.rawValue)") // 101 = pause, 100 = play
            switch rc {
            case .RemoteControlTogglePlayPause:
                if theAudioPlayer.playing { theAudioPlayer.pause() } else { theAudioPlayer.play() }
            case .RemoteControlPlay:
                theAudioPlayer.play()
            case .RemoteControlPause:
                theAudioPlayer.pause()
            default:break
            }
        }
        */

        
    }

}


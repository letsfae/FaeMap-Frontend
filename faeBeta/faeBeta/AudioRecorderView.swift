//
//  AudioRecorderView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol AudioRecorderViewDelegate {
    func audioRecorderView(audioView: AudioRecorderView, needToSendAudioData data: NSData)
}

class AudioRecorderView: UIView {

//MARK: - properties
    
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var signalImageView: UIImageView!
    
    var isRecordMode = true // true: record mode  false: play mode
    var isPressingMainButton = false
    var flowTimer: NSTimer! // the timer to display flow
    var timeTimer: NSTimer! // the timer to count the time
    
    var currentTime = 0
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var voiceData = NSData()
    var startRecording = false
    var isPlayingRecroding = false // true: is playing the audio
    

    var delegate : AudioRecorderViewDelegate!
    
    @IBOutlet weak var signalIconHeight: NSLayoutConstraint!
    @IBOutlet weak var signalIconWidth: NSLayoutConstraint!
    
    //MARK: - init
    init(){
        super.init(frame:CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // setup UI
        mainButton.layer.cornerRadius = 67
        mainButton.backgroundColor = UIColor.whiteColor()
        mainButton.layer.shadowColor = UIColor.faeAppShadowGrayColor().CGColor
        mainButton.layer.shadowOpacity = 1
        mainButton.layer.shadowRadius = 10;
        mainButton.layer.shadowOffset = CGSizeMake(0, 0);
        mainButton.layer.masksToBounds = false
        
        mainButton.addTarget(self, action: #selector(self.mainButtonPressing(_:)), forControlEvents: .TouchDown)
        mainButton.addTarget(self, action: #selector(self.mainButtonTouchUpInSide(_:)), forControlEvents: .TouchUpInside)
        mainButton.addTarget(self, action: #selector(self.mainButtonTouchUpOutSide(_:withEvent:)), forControlEvents: .TouchUpOutside )
        mainButton.addTarget(self, action: #selector(self.mainButtonDragOutside(_:withEvent:)), forControlEvents: .TouchDragOutside)

        
        leftButton.addTarget(self, action: #selector(self.leftButtonPressed(_:)), forControlEvents: .TouchUpInside)
        rightButton.addTarget(self, action: #selector(self.rightButtonPressed(_:)), forControlEvents: .TouchUpInside)

        leftButton.alpha = 0
        rightButton.alpha = 0
        
        setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
    }
    
    func setInfoLabel(text:String, color: UIColor){
        let attributedText = NSAttributedString(string:text, attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18)!])
        infoLabel.attributedText = attributedText
        infoLabel.sizeToFit()
        self.setNeedsLayout()
    }
    
    func mainButtonPressing(sender: UIButton)
    {
        if(isRecordMode){
            isPressingMainButton = true
            
            let view = UIView(frame: CGRect(x: 0,y: 0,width: 5,height: 5))
            view.layer.cornerRadius = 2.5
            view.backgroundColor = UIColor.faeAppRedColor()
            self.addSubview(view)
            view.center = mainButton.center
            
            self.signalImageView.image = UIImage(named: "signalIcon_red")
            
            startDisplayingFlow()
            setupRecorder()
            
            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = view.layer.cornerRadius
            animation.toValue = 50
            animation.duration = 0.21
            view.layer.addAnimation(animation, forKey: "cornerRadius")
            
            UIView.animateWithDuration(0.2, delay: 0, options:.CurveLinear ,animations: {
                view.frame = CGRect(x: 0,y: 0,width: 100,height: 100)

                view.center = self.mainButton.center
                self.mainButton.transform = CGAffineTransformMakeScale(0.77, 0.77)
                self.setInfoLabel("0:00", color: UIColor.faeAppRedColor())
                self.leftButton.alpha = 1
                self.rightButton.alpha = 1
                }, completion: { (complete) in
                    view.hidden = true
                    view.removeFromSuperview()
                    self.mainButton.backgroundColor = UIColor.faeAppRedColor()
                    self.generateFlow()
                    self.startRecord()
            })
        }
    }
    
    func mainButtonReleased(sender: UIButton){
        if(isRecordMode){
            isPressingMainButton = false
            let isValidAudio = stopRecord()
            if(!isValidAudio){
                showWarnMeesage()
            }
            
            let view = UIView(frame: CGRect(x: 0,y: 0,width: 5,height: 5))
            view.layer.cornerRadius = 2.5
            view.backgroundColor = UIColor.whiteColor()
            view.center = self.mainButton.center
            self.addSubview(view)
            self.signalImageView.image = UIImage(named: "signalIcon_gray")
            self.bringSubviewToFront(signalImageView)

            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = view.layer.cornerRadius
            animation.toValue = 67
            animation.duration = 0.21
            view.layer.addAnimation(animation, forKey: "cornerRadius")
            
            UIView.animateWithDuration(0.2, delay: 0, options:.CurveLinear , animations: {
                view.frame = CGRect(x: 0,y: 0,width: 133,height: 133)
                view.center = self.mainButton.center

                self.mainButton.transform = CGAffineTransformMakeScale(1, 1)
                self.leftButton.alpha = 0
                self.rightButton.alpha = 0
                
            }, completion: { (complete) in
                view.hidden = true
                view.removeFromSuperview()
                self.mainButton.backgroundColor = UIColor.whiteColor()
            })
        }else{
            if(soundPlayer.playing){
                signalImageView.image = UIImage(named: "playButton_red")
                soundPlayer.pause()
            }
            else{
                signalImageView.image = UIImage(named: "pauseButton_red_new")
                soundPlayer.play()
            }
        }
    }
    
    func leftButtonPressed(sender: UIButton){
        if(!isRecordMode){
            switchToRecordMode()
        }
    }
    
    func rightButtonPressed(sender: UIButton){
        if(!isRecordMode){
            self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
            switchToRecordMode()
        }
    }
    
    private func startDisplayingFlow(){
        flowTimer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(self.generateFlow), userInfo: nil, repeats: true)
    }
    
    func generateFlow(){
        if(isPressingMainButton){
            let view = UIView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
            view.layer.cornerRadius = 50
            view.backgroundColor = UIColor.faeAppRedColor()
            view.alpha = 0.7
            view.center = self.mainButton.center
            self.addSubview(view)
            self.sendSubviewToBack(view)
            
            UIView.animateWithDuration(2, delay: 0, options:.CurveEaseOut , animations: {
//                view.transform = CGAffineTransformMakeScale(3, 3)
                view.frame = CGRect(x: 0,y: 0,width: 300,height: 300)
                //add cornerRadius animation
                let animation = CABasicAnimation(keyPath: "cornerRadius")
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation.fromValue = view.layer.cornerRadius
                animation.toValue = 150
                animation.duration = 2
                view.layer.addAnimation(animation, forKey: "cornerRadius")
                
                view.center = self.mainButton.center
                view.alpha = 0
                }, completion: { (complete) in
                    view.removeFromSuperview()
            })
            
        }else{
            flowTimer.invalidate()
        }
    }
    
    //MARK: - helper
    
    func setupRecorder() {

        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(.Speaker)
        } catch let error as NSError {
            print(error.description)
        }
        let recordSettings = [AVFormatIDKey : Int(kAudioFormatAppleLossless),
                              AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0 ]
        soundRecorder = nil
        do {
            soundRecorder = try AVAudioRecorder(URL: getFileURL(), settings: recordSettings as! [String : AnyObject])
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print("cannot record")
        }
    }
    
    func startRecord(){
        if(mainButton.enabled){
            if !soundRecorder.recording {
                print("recording")
                soundRecorder.record()
            }
            currentTime = 0
            self.updateTime()
            timeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        }
    }
    
    
    func stopRecord() -> Bool{
        soundRecorder.stop()
        if(timeTimer != nil){
            timeTimer.invalidate()
        }
        // send voice message to firebase
        voiceData = NSData(contentsOfURL: getFileURL())!
        
        // add a check to avoid short sound message
        soundPlayer = nil
        do {
            soundPlayer = try AVAudioPlayer(data: voiceData, fileTypeHint: nil)
            soundPlayer.delegate = self
        } catch {
            print("cannot play")
        }
        if(soundPlayer != nil && soundPlayer.duration < 1.0){
            return false;
        }
        return true
    }

    func getFileURL() -> NSURL {
        //record: change the default save file path from getCacheDirectory
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "/TempMemo.caf"
        
        return NSURL.fileURLWithPath(filePath)
    }
    
    func updateTime(){
        currentTime += 1
        let secondString = currentTime < 10 ? "0\(currentTime)" : "\(currentTime)"
        setInfoLabel("0:\(secondString)", color: UIColor.faeAppRedColor())
    }
    
    func mainButtonDragOutside(sender: UIButton, withEvent event:UIEvent)
    {
        if(isRecordMode){
            let touch: UITouch = (event.allTouches()?.first)!
            let loc = touch.locationInView(self)
            if (CGRectContainsPoint(leftButton.frame, loc)){
                leftButton.setBackgroundImage(UIImage(named:"playButtonIcon_red"), forState: .Normal)
            }
            else if(CGRectContainsPoint(rightButton.frame, loc)){
                rightButton.setBackgroundImage(UIImage(named:"trashButtonIcon_red"), forState: .Normal)
            }
            else{
                leftButton.setBackgroundImage(UIImage(named:"playButtonIcon_gray"), forState: .Normal)
                rightButton.setBackgroundImage(UIImage(named:"trashButtonIcon_gray"), forState: .Normal)
            }
        }
    }
    
    func mainButtonTouchUpInSide(sender: UIButton)
    {
        mainButtonReleased(sender)
        if(isRecordMode){
            let audioIsValid = self.stopRecord()
            if audioIsValid {
                self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
                setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
            }
        }
    }
    
    func mainButtonTouchUpOutSide(sender: UIButton, withEvent event:UIEvent) {
        if isRecordMode{
            mainButtonReleased(sender)
            let audioIsValid = self.stopRecord()
            
            let touch: UITouch = (event.allTouches()?.first)!
            let loc = touch.locationInView(self)
            if(CGRectContainsPoint(leftButton.frame, loc)){
                switchToPlayMode()
                
            }else if (CGRectContainsPoint(rightButton.frame, loc)){
                setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())

            }else{
                if audioIsValid {
                    self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
                    setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
                }
            }
        }else{
            
        }
    }
    
    func switchToPlayMode(){
        isRecordMode = false
        signalImageView.image = UIImage(named: "playButton_red")
        signalIconWidth.constant = 65
        signalIconHeight.constant = 65
        leftButton.setBackgroundImage(UIImage(named: "cancelButtonIcon"), forState: .Normal)
        rightButton.setBackgroundImage(UIImage(named: "sendButtonIcon"), forState: .Normal)
        self.leftButton.alpha = 1
        self.rightButton.alpha = 1
        
        let secondString = soundPlayer.duration < 9 ? "0\(Int(ceil(soundPlayer.duration)))" : "\(Int(ceil(soundPlayer.duration)))"
        setInfoLabel("0:\(secondString)", color: UIColor.blackColor())
        
        self.setNeedsLayout()
    }
    
    func switchToRecordMode(){
        isRecordMode = true
        signalImageView.image = UIImage(named: "signalIcon_gray")
        signalIconWidth.constant = 50
        signalIconHeight.constant = 30
        leftButton.alpha = 0
        rightButton.alpha = 0
        leftButton.setBackgroundImage(UIImage(named: "playButtonIcon_gray"), forState: .Normal)
        rightButton.setBackgroundImage(UIImage(named: "trashButtonIcon_gray"), forState: .Normal)
        setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
        self.setNeedsLayout()
        
    }
    
    func showWarnMeesage()
    {
        setInfoLabel("Too Short!", color: UIColor.faeAppRedColor())
        mainButton.enabled = false
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(self.recoverRecordButton), userInfo: nil, repeats: false)
    }
    
    func recoverRecordButton()
    {
        setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
        mainButton.enabled = true
    }
    

}

extension AudioRecorderView:  AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    //MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if(flag && !isRecordMode){
            signalImageView.image = UIImage(named: "playButton_red")
        }
    }
}



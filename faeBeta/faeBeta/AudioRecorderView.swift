//
//  AudioRecorderView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 10/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol AudioRecorderViewDelegate: class {
    func audioRecorderView(_ audioView: AudioRecorderView, needToSendAudioData data: Data)
}

class AudioRecorderView: UIView {

//MARK: - properties
    
    @IBOutlet private weak var mainButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var infoLabel: UILabel! // the label displaying "to short" or "record duration"
    @IBOutlet fileprivate weak var signalImageView: UIImageView! // the image view on the record button to show the signal icon
    
    fileprivate var isRecordMode = true // true: record mode  false: play mode
    private var isPressingMainButton = false
    private var flowTimer: Timer! // the timer to display flow
    private var timeTimer: Timer! // the timer to count the time
    fileprivate var progressTimer: Timer!
    
    private var currentTime = 0 // 0 - 60 current time for recording
    
    private var soundRecorder : AVAudioRecorder!
    private var soundPlayer: AVAudioPlayer!
    private var recordingSession: AVAudioSession!
    private var voiceData = Data()
    private var startRecording = false // true: is recording
    private var isPlayingRecroding = false // true: is playing the audio
    
    weak var delegate : AudioRecorderViewDelegate!
    
    private let leftAndRightButtonResizingFactorMax: CGFloat = 1.3 // while recording, the buttom left & right button will become larger when you move your finger toward to it. This factor limit the maximum size of it
    
    @IBOutlet private weak var signalIconHeight: NSLayoutConstraint!
    @IBOutlet private weak var signalIconWidth: NSLayoutConstraint!
    
    //MARK: - init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // setup UI
        mainButton.layer.cornerRadius = 67
        mainButton.backgroundColor = UIColor.white
        mainButton.layer.shadowColor = UIColor.faeAppShadowGrayColor().cgColor
        mainButton.layer.shadowOpacity = 1
        mainButton.layer.shadowRadius = 10;
        mainButton.layer.shadowOffset = CGSize(width: 0, height: 0);
        mainButton.layer.masksToBounds = false
        
        mainButton.addTarget(self, action: #selector(self.mainButtonPressing(_:)), for: .touchDown)
        mainButton.addTarget(self, action: #selector(self.mainButtonTouchUpInSide(_:withEvent:)), for: .touchUpInside)
        mainButton.addTarget(self, action: #selector(self.mainButtonTouchUpOutSide(_:withEvent:)), for: .touchUpOutside )
        mainButton.addTarget(self, action: #selector(self.mainButtonDragOutside(_:withEvent:)), for: .touchDragOutside)
        mainButton.addTarget(self, action: #selector(self.mainButtonDragInside(_:withEvent:)), for: .touchDragInside)
        leftButton.addTarget(self, action: #selector(self.leftButtonPressed(_:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(self.rightButtonPressed(_:)), for: .touchUpInside)

        leftButton.alpha = 0
        rightButton.alpha = 0
        
        setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
    }
    
    
    //MARK: - button actions
    @objc private func mainButtonPressing(_ sender: UIButton)
    {
        if(isRecordMode){
            isPressingMainButton = true
            
            let view = UIImageView(frame: CGRect(x: 0,y: 0,width: 5,height: 5))
            view.image = UIImage(named: "Oval 3")
            self.addSubview(view)
            view.center = mainButton.center
            
            self.signalImageView.image = UIImage(named: "signalIcon_red")
            
            startDisplayingFlow()
            setupRecorder()
            
            UIView.animate(withDuration: 0.2, delay: 0, options:.curveLinear ,animations: {
                view.frame = CGRect(x: 0,y: 0,width: 100,height: 100)

                view.center = self.mainButton.center
                self.mainButton.transform = CGAffineTransform(scaleX: 0.77, y: 0.77)
                self.setInfoLabel("1:00", color: UIColor._2499090())
                self.leftButton.alpha = 1
                self.rightButton.alpha = 1
                }, completion: { (complete) in
                    self.mainButton.backgroundColor = UIColor._2499090()
                    view.isHidden = true
                    view.removeFromSuperview()
                    self.generateFlow()
                    self.startRecord()
            })
        }
    }
    
    @objc private func mainButtonReleased(_ sender: UIButton){
        if(isRecordMode){
            isPressingMainButton = false
            let isValidAudio = stopRecord()
            if(!isValidAudio){
                showWarnMeesage()
            }
            
            let view = UIImageView(frame: CGRect(x: 0,y: 0,width: 5,height: 5))
            view.image = UIImage(named: "Oval 2")
            view.center = self.mainButton.center
            self.addSubview(view)
            self.bringSubview(toFront: view)
            self.signalImageView.image = UIImage(named: "signalIcon_gray")
            self.bringSubview(toFront: signalImageView)
            
            UIView.animate(withDuration: 0.2, delay: 0, options:.curveLinear , animations: {
                view.frame = CGRect(x: 0,y: 0,width: 133,height: 133)
                view.center = self.mainButton.center

                self.mainButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.leftButton.alpha = 0
                self.rightButton.alpha = 0
                
            }, completion: { (complete) in
                view.isHidden = true
                view.removeFromSuperview()
                self.mainButton.backgroundColor = UIColor.white
            })
        }else{
            if(soundPlayer.isPlaying){
                signalImageView.image = UIImage(named: "playButton_red_new")
                soundPlayer.pause()
                if progressTimer != nil{
                    progressTimer.invalidate()
                }
            }
            else{
                signalImageView.image = UIImage(named: "pauseButton_red_new")
                soundPlayer.play()
                self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc private func leftButtonPressed(_ sender: UIButton){
        if(!isRecordMode){
            switchToRecordMode()
            resumeBackGroundMusic()
            if progressTimer != nil {
                progressTimer.invalidate()
            }
        }
    }
    
    @objc private func rightButtonPressed(_ sender: UIButton){
        if(!isRecordMode){
            self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
            switchToRecordMode()
            resumeBackGroundMusic()
            if progressTimer != nil{
                progressTimer.invalidate()
            }
        }
    }
    
    @objc private func mainButtonDragInside(_ sender: UIButton, withEvent event:UIEvent)
    {
        if(isRecordMode){
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            
            let disToLeftButton = sqrt( pow(loc.x - self.leftButton.center.x, 2) + pow(loc.y - self.leftButton.center.y, 2)) - 30 * leftAndRightButtonResizingFactorMax
            let disToRightButton = sqrt( pow(loc.x - self.rightButton.center.x, 2) + pow(loc.y - self.rightButton.center.y, 2)) - 30 * leftAndRightButtonResizingFactorMax
            let firstArg = pow(mainButton.center.x - self.leftButton.center.x, 2) + pow(mainButton.center.y - self.leftButton.center.y, 2)
            let distanceThreshold = sqrt(firstArg) - 30 * leftAndRightButtonResizingFactorMax - 67
            let leftFactor = disToLeftButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToLeftButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax) : 1
            let rightFactor = disToRightButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToRightButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax ) : 1
            
            self.leftButton.transform = CGAffineTransform(scaleX: leftFactor , y: leftFactor)
            self.rightButton.transform = CGAffineTransform(scaleX: rightFactor , y: rightFactor)
            
            if (leftButton.frame.contains(loc)){
                leftButton.setBackgroundImage(UIImage(named:"playButtonIcon_red"), for: UIControlState())
            }
            else if(rightButton.frame.contains(loc)){
                rightButton.setBackgroundImage(UIImage(named:"trashButtonIcon_red"), for: UIControlState())
            }
            else{
                leftButton.setBackgroundImage(UIImage(named:"playButtonIcon_gray"), for: UIControlState())
                rightButton.setBackgroundImage(UIImage(named:"trashButtonIcon_gray"), for: UIControlState())
            }
        }
    }
    
    
    @objc private func mainButtonDragOutside(_ sender: UIButton, withEvent event:UIEvent)
    {
        if(isRecordMode){
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            
            let disToLeftButton = sqrt( pow(loc.x - self.leftButton.center.x, 2) + pow(loc.y - self.leftButton.center.y, 2)) - 33
            let disToRightButton = sqrt( pow(loc.x - self.rightButton.center.x, 2) + pow(loc.y - self.rightButton.center.y, 2)) - 33
            let distanceThreshold = sqrt( pow(mainButton.center.x - self.leftButton.center.x, 2) + pow(mainButton.center.y - self.leftButton.center.y, 2)) - 33 - 67
            let leftFactor = disToLeftButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToLeftButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax) : 1
            let rightFactor = disToRightButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToRightButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax ) : 1
            
            self.leftButton.transform = CGAffineTransform(scaleX: leftFactor , y: leftFactor)
            self.rightButton.transform = CGAffineTransform(scaleX: rightFactor , y: rightFactor)
            
            if (leftButton.frame.contains(loc)){
                leftButton.setBackgroundImage(UIImage(named:"playButtonIcon_red"), for: UIControlState())
            }
            else if(rightButton.frame.contains(loc)){
                rightButton.setBackgroundImage(UIImage(named:"trashButtonIcon_red"), for: UIControlState())
            }
            else{
                leftButton.setBackgroundImage(UIImage(named:"playButtonIcon_gray"), for: UIControlState())
                rightButton.setBackgroundImage(UIImage(named:"trashButtonIcon_gray"), for: UIControlState())
            }
        }
    }
    
    @objc private func mainButtonTouchUpInSide(_ sender: UIButton, withEvent event: UIEvent)
    {
        mainButtonReleased(sender)
        if(isRecordMode){
            let audioIsValid = self.stopRecord()
            
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            if(leftButton.frame.contains(loc)){
                if audioIsValid{
                    switchToPlayMode()
                }
            }
            else if (rightButton.frame.contains(loc)){
                switchToRecordMode()
                resumeBackGroundMusic()
            }
            else{
                if audioIsValid {
                    self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
                    switchToRecordMode()
                    resumeBackGroundMusic()
                }
            }
        }
    }
    
    @objc private func mainButtonTouchUpOutSide(_ sender: UIButton, withEvent event:UIEvent) {
        if isRecordMode{
            mainButtonReleased(sender)
            let audioIsValid = self.stopRecord()
            
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            if(leftButton.frame.contains(loc)){
                if audioIsValid{
                    switchToPlayMode()
                }
            }else if (rightButton.frame.contains(loc)){
                switchToRecordMode()
                resumeBackGroundMusic()
            }else{
                resumeBackGroundMusic()
                if audioIsValid {
                    self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
                    switchToRecordMode()
                }
            }
        }
    }
    
    //MARK: - switch mode
    func switchToPlayMode(){
        UIView.animate(withDuration: 0.2, animations: {
            
            self.isRecordMode = false
            self.signalImageView.image = UIImage(named: "playButton_red_new")
            self.signalIconWidth.constant = 55
            self.signalIconHeight.constant = 55
            self.leftButton.setBackgroundImage(UIImage(named: "cancelButtonIcon"), for: UIControlState())
            self.leftButton.setBackgroundImage(UIImage(named: "cancelButtonIcon_red"), for: .highlighted)
            self.rightButton.setBackgroundImage(UIImage(named: "sendButtonIcon"), for: UIControlState())
            self.rightButton.setBackgroundImage(UIImage(named: "sendButtonIcon_red"), for: .highlighted)
            self.leftButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.rightButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.leftButton.alpha = 1
            self.rightButton.alpha = 1
            
            let secondString = self.soundPlayer.duration < 9 ? "0\(Int(ceil(self.soundPlayer.duration)))" : "\(Int(ceil(self.soundPlayer.duration)))"
            self.setInfoLabel("0:\(secondString)", color: UIColor._107107107())
            
        }, completion: { (completed) in
        })
    }
    
    func switchToRecordMode(){
        UIView.animate(withDuration: 0.2, animations: {
            self.isRecordMode = true
            self.signalImageView.image = UIImage(named: "signalIcon_gray")
            self.signalIconWidth.constant = 50
            self.signalIconHeight.constant = 30
            self.leftButton.alpha = 0
            self.rightButton.alpha = 0
            self.leftButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.rightButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
            self.setNeedsLayout()
        }, completion: { (completed) in
            self.leftButton.setBackgroundImage(UIImage(named: "playButtonIcon_gray"), for: UIControlState())
            self.rightButton.setBackgroundImage(UIImage(named: "trashButtonIcon_gray"), for: UIControlState())
        }) 
    }
    
    //MARK: - recorder
    private func setupRecorder() {
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(.speaker)
        } catch let error as NSError {
            print(error.description)
        }
        let recordSettings = [AVFormatIDKey : Int(kAudioFormatAppleLossless),
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0 ] as [String : Any]
        soundRecorder = nil
        do {
            soundRecorder = try AVAudioRecorder(url: getFileURL(), settings: recordSettings as [String : AnyObject])
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print("cannot record")
        }
    }
    
    private func startRecord(){
        if(mainButton.isEnabled){
            if !soundRecorder.isRecording {
                print("recording")
                soundRecorder.record()
            }
            currentTime = 60
            self.updateTime()
            timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        }
    }
    
    
    /// stop recording audio
    ///
    /// - Returns: whether the record is valid
    private func stopRecord() -> Bool{
        soundRecorder.stop()
        if(timeTimer != nil){
            timeTimer.invalidate()
        }
        // send voice message to firebase
        voiceData = try! Data(contentsOf: getFileURL())
        
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
    
    //MARK: - helper
    
    func setInfoLabel(_ text:String, color: UIColor){
        let attributedText = NSAttributedString(string:text, attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18)!])
        infoLabel.attributedText = attributedText
        infoLabel.sizeToFit()
        self.setNeedsLayout()
    }

    
    /// get a temporary file url to store the audio recorded
    ///
    /// - Returns: the url to store audio
    private func getFileURL() -> URL {
        //record: change the default save file path from getCacheDirectory
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "/TempMemo.caf"
        
        return URL(fileURLWithPath: filePath)
    }
    
    // while recording, update the time passed
    @objc private func updateTime(){
        currentTime -= 1
        let secondString = currentTime < 10 ? "0\(currentTime)" : "\(currentTime)"
        setInfoLabel("0:\(secondString)", color: UIColor._2499090())
        if(currentTime == 0){
            timeTimer.invalidate()
            _ = self.stopRecord()
            isPressingMainButton = false
        }
    }
    
    private func showWarnMeesage()
    {
        setInfoLabel("Too Short!", color: UIColor._2499090())
        mainButton.isEnabled = false
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.recoverRecordButton), userInfo: nil, repeats: false)
    }
    
    // transform the record button to origin looks
    @objc private func recoverRecordButton()
    {
        setInfoLabel("Hold & Speak!", color: UIColor.faeAppInfoLabelGrayColor())
        mainButton.isEnabled = true
    }
    
    private func resumeBackGroundMusic()
    {
        do {
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        }
        catch{
            print("cannot resume music")
        }
    }
    
    @objc private func updateProgressTimer()
    {
        let secondString = self.soundPlayer.currentTime < 9 ? "0\(Int(ceil(self.soundPlayer.currentTime)))" : "\(Int(ceil(self.soundPlayer.currentTime)))"
        self.setInfoLabel("0:\(secondString)", color: UIColor._107107107())
    }
    
    // Ask the user for permission to use the microphone
    func requireForPermission(_ completion: ((Bool) -> ())?)
    {
        // add this line to active microphone check
        recordingSession = AVAudioSession.sharedInstance()
        recordingSession.requestRecordPermission{
            BOOL in
            if completion != nil {
                completion!(BOOL)
            }
        }
    }
    
    // start displaying the wave around the record button
    fileprivate func startDisplayingFlow(){
        flowTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(self.generateFlow), userInfo: nil, repeats: true)
    }
    
    @objc private func generateFlow(){
        if(isPressingMainButton){
            let view = UIView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
            view.layer.cornerRadius = 50
            view.backgroundColor = UIColor._2499090()
            view.alpha = 0.5
            view.center = self.mainButton.center
            self.addSubview(view)
            self.sendSubview(toBack: view)
            
            UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut , animations: {
                //                view.transform = CGAffineTransformMakeScale(3, 3)
                view.frame = CGRect(x: 0,y: 0,width: 300,height: 300)
                //add cornerRadius animation
                let animation = CABasicAnimation(keyPath: "cornerRadius")
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation.fromValue = view.layer.cornerRadius
                animation.toValue = 150
                animation.duration = 2
                view.layer.add(animation, forKey: "cornerRadius")
                
                view.center = self.mainButton.center
                view.alpha = 0
            }, completion: { (complete) in
                view.removeFromSuperview()
            })
            
        }else{
            flowTimer.invalidate()
        }
    }
}

//MARK: - AVAudioPlayerDelegate
extension AudioRecorderView:  AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if(flag && !isRecordMode){
            signalImageView.image = UIImage(named: "playButton_red_new")
            progressTimer.invalidate()
        }
    }
}



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

    // MARK: properties
    var btnMain: UIButton!
    var btnLeft: UIButton!
    var btnRight: UIButton!
    var lblInfo: UILabel!
    var imgSignal: UIImageView!
    
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
    
    //@IBOutlet private weak var signalIconHeight: NSLayoutConstraint!
    //@IBOutlet private weak var signalIconWidth: NSLayoutConstraint!
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        btnMain = UIButton()
        btnMain.layer.cornerRadius = 67
        btnMain.backgroundColor = UIColor.white
        btnMain.layer.shadowColor = UIColor._210210210().cgColor
        btnMain.layer.shadowOpacity = 1
        btnMain.layer.shadowRadius = 10;
        btnMain.layer.shadowOffset = CGSize(width: 0, height: 0);
        btnMain.layer.masksToBounds = false
        addSubview(btnMain)
        addConstraintsWithFormat("H:|-\((screenWidth - 133)/2)-[v0(133)]", options: [], views: btnMain)
        addConstraintsWithFormat("V:|-84-[v0(133)]", options: [], views: btnMain)
        
        btnMain.addTarget(self, action: #selector(self.mainButtonPressing(_:)), for: .touchDown)
        btnMain.addTarget(self, action: #selector(self.mainButtonTouchUpInSide(_:withEvent:)), for: .touchUpInside)
        btnMain.addTarget(self, action: #selector(self.mainButtonTouchUpOutSide(_:withEvent:)), for: .touchUpOutside )
        btnMain.addTarget(self, action: #selector(self.mainButtonDragOutside(_:withEvent:)), for: .touchDragOutside)
        btnMain.addTarget(self, action: #selector(self.mainButtonDragInside(_:withEvent:)), for: .touchDragInside)
        
        btnLeft = UIButton()
        btnLeft.setBackgroundImage(UIImage(named: "playButtonIcon_gray"), for: .normal)
        addSubview(btnLeft)
        btnLeft.isHidden = true
        addConstraintsWithFormat("H:|-15-[v0(60)]", options: [], views: btnLeft)
        addConstraintsWithFormat("V:[v0(60)]-12-|", options: [], views: btnLeft)
        btnLeft.addTarget(self, action: #selector(self.leftButtonPressed(_:)), for: .touchUpInside)
        
        btnRight = UIButton()
        btnRight.setBackgroundImage(UIImage(named: "trashButtonIcon_gray"), for: .normal)
        addSubview(btnRight)
        btnRight.isHidden = true
        addConstraintsWithFormat("H:[v0(60)]-15-|", options: [], views: btnRight)
        addConstraintsWithFormat("V:[v0(60)]-12-|", options: [], views: btnRight)
        btnRight.addTarget(self, action: #selector(self.rightButtonPressed(_:)), for: .touchUpInside)
        
        lblInfo = UILabel()
        setInfoLabel("Hold & Speak!", color: UIColor._182182182())
        addSubview(lblInfo)
        addConstraintsWithFormat("H:|-\((screenWidth - 121)/2)-[v0(121)]", options: [], views: lblInfo)
        addConstraintsWithFormat("V:|-34-[v0(25)]", options: [], views: lblInfo)
        
        imgSignal = UIImageView()
        imgSignal.image = UIImage(named: "signalIcon_gray")
        imgSignal.contentMode = .scaleAspectFill
        btnMain.addSubview(imgSignal)
        btnMain.addConstraintsWithFormat("H:|-\((133 - 50)/2)-[v0(50)]", options: [], views: imgSignal)
        btnMain.addConstraintsWithFormat("V:|-\((133 - 30)/2)-[v0(30)]", options: [], views: imgSignal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: button actions
    @objc private func mainButtonPressing(_ sender: UIButton) {
        if isRecordMode {
            isPressingMainButton = true
            
            let view = UIImageView(frame: CGRect(x: 0,y: 0,width: 5,height: 5))
            view.image = UIImage(named: "Oval 3")
            self.addSubview(view)
            view.center = btnMain.center
            
            imgSignal.image = UIImage(named: "signalIcon_red")
            
            startDisplayingFlow()
            setupRecorder()
            
            UIView.animate(withDuration: 0.2, delay: 0, options:.curveLinear, animations: {
                view.frame = CGRect(x: 0,y: 0,width: 100,height: 100)

                view.center = self.btnMain.center
                self.btnMain.transform = CGAffineTransform(scaleX: 0.77, y: 0.77)
                self.setInfoLabel("1:00", color: UIColor._2499090())
                self.btnLeft.isHidden = false
                self.btnRight.isHidden = false
                }, completion: { (complete) in
                    self.btnMain.backgroundColor = UIColor._2499090()
                    view.isHidden = true
                    view.removeFromSuperview()
                    self.generateFlow()
                    self.startRecord()
            })
        }
    }
    
    @objc private func mainButtonReleased(_ sender: UIButton){
        if isRecordMode {
            isPressingMainButton = false
            let isValidAudio = stopRecord()
            if(!isValidAudio){
                showWarnMeesage()
            }
            
            let view = UIImageView(frame: CGRect(x: 0,y: 0,width: 5,height: 5))
            view.image = UIImage(named: "Oval 2")
            view.center = btnMain.center
            self.addSubview(view)
            self.bringSubview(toFront: view)
            imgSignal.image = UIImage(named: "signalIcon_gray")
            self.bringSubview(toFront: imgSignal)
            
            UIView.animate(withDuration: 0.2, delay: 0, options:.curveLinear , animations: {
                view.frame = CGRect(x: 0,y: 0,width: 133,height: 133)
                view.center = self.btnMain.center

                self.btnMain.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.btnLeft.isHidden = true
                self.btnRight.isHidden = true
                
            }, completion: { (complete) in
                view.isHidden = true
                view.removeFromSuperview()
                self.btnMain.backgroundColor = UIColor.white
            })
        } else {
            if soundPlayer.isPlaying {
                imgSignal.image = UIImage(named: "playButton_red_new")
                soundPlayer.pause()
                if progressTimer != nil {
                    progressTimer.invalidate()
                }
            } else {
                imgSignal.image = UIImage(named: "pauseButton_red_new")
                soundPlayer.play()
                self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc private func leftButtonPressed(_ sender: UIButton){
        if !isRecordMode {
            switchToRecordMode()
            resumeBackGroundMusic()
            if progressTimer != nil {
                progressTimer.invalidate()
            }
        }
    }
    
    @objc private func rightButtonPressed(_ sender: UIButton){
        if !isRecordMode {
            self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
            switchToRecordMode()
            resumeBackGroundMusic()
            if progressTimer != nil {
                progressTimer.invalidate()
            }
        }
    }
    
    @objc private func mainButtonDragInside(_ sender: UIButton, withEvent event:UIEvent) {
        if isRecordMode {
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            
            let disToLeftButton = sqrt(pow(loc.x - btnLeft.center.x, 2) + pow(loc.y - btnLeft.center.y, 2)) - 30 * leftAndRightButtonResizingFactorMax
            let disToRightButton = sqrt(pow(loc.x - btnRight.center.x, 2) + pow(loc.y - btnRight.center.y, 2)) - 30 * leftAndRightButtonResizingFactorMax
            let firstArg = pow(btnMain.center.x - btnLeft.center.x, 2) + pow(btnMain.center.y - btnLeft.center.y, 2)
            let distanceThreshold = sqrt(firstArg) - 30 * leftAndRightButtonResizingFactorMax - 67
            let leftFactor = disToLeftButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToLeftButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax) : 1
            let rightFactor = disToRightButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToRightButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax ) : 1
            
            btnLeft.transform = CGAffineTransform(scaleX: leftFactor , y: leftFactor)
            btnRight.transform = CGAffineTransform(scaleX: rightFactor , y: rightFactor)
            
            if btnLeft.frame.contains(loc) {
                btnLeft.setBackgroundImage(UIImage(named:"playButtonIcon_red"), for: UIControlState())
            } else if btnRight.frame.contains(loc) {
                btnRight.setBackgroundImage(UIImage(named:"trashButtonIcon_red"), for: UIControlState())
            } else {
                btnLeft.setBackgroundImage(UIImage(named:"playButtonIcon_gray"), for: UIControlState())
                btnRight.setBackgroundImage(UIImage(named:"trashButtonIcon_gray"), for: UIControlState())
            }
        }
    }
    
    
    @objc private func mainButtonDragOutside(_ sender: UIButton, withEvent event:UIEvent) {
        if isRecordMode {
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            
            let disToLeftButton = sqrt(pow(loc.x - btnLeft.center.x, 2) + pow(loc.y - btnLeft.center.y, 2)) - 33
            let disToRightButton = sqrt(pow(loc.x - btnRight.center.x, 2) + pow(loc.y - btnRight.center.y, 2)) - 33
            let distanceThreshold = sqrt(pow(btnMain.center.x - btnLeft.center.x, 2) + pow(btnMain.center.y - btnLeft.center.y, 2)) - 33 - 67
            let leftFactor = disToLeftButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToLeftButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax) : 1
            let rightFactor = disToRightButton < distanceThreshold ? min(leftAndRightButtonResizingFactorMax - disToRightButton / distanceThreshold * (leftAndRightButtonResizingFactorMax - 1), leftAndRightButtonResizingFactorMax ) : 1
            
            btnLeft.transform = CGAffineTransform(scaleX: leftFactor , y: leftFactor)
            btnRight.transform = CGAffineTransform(scaleX: rightFactor , y: rightFactor)
            
            if btnLeft.frame.contains(loc) {
                btnLeft.setBackgroundImage(UIImage(named:"playButtonIcon_red"), for: UIControlState())
            } else if btnRight.frame.contains(loc) {
                btnRight.setBackgroundImage(UIImage(named:"trashButtonIcon_red"), for: UIControlState())
            } else {
                btnLeft.setBackgroundImage(UIImage(named:"playButtonIcon_gray"), for: UIControlState())
                btnRight.setBackgroundImage(UIImage(named:"trashButtonIcon_gray"), for: UIControlState())
            }
        }
    }
    
    @objc private func mainButtonTouchUpInSide(_ sender: UIButton, withEvent event: UIEvent) {
        mainButtonReleased(sender)
        if isRecordMode {
            let audioIsValid = self.stopRecord()
            
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            if btnLeft.frame.contains(loc) {
                if audioIsValid{
                    switchToPlayMode()
                }
            } else if btnRight.frame.contains(loc) {
                switchToRecordMode()
                resumeBackGroundMusic()
            } else {
                if audioIsValid {
                    self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
                    switchToRecordMode()
                    resumeBackGroundMusic()
                }
            }
        }
    }
    
    @objc private func mainButtonTouchUpOutSide(_ sender: UIButton, withEvent event:UIEvent) {
        if isRecordMode {
            mainButtonReleased(sender)
            let audioIsValid = self.stopRecord()
            
            let touch: UITouch = (event.allTouches?.first)!
            let loc = touch.location(in: self)
            if btnLeft.frame.contains(loc) {
                if audioIsValid{
                    switchToPlayMode()
                }
            } else if btnRight.frame.contains(loc) {
                switchToRecordMode()
                resumeBackGroundMusic()
            } else {
                resumeBackGroundMusic()
                if audioIsValid {
                    self.delegate.audioRecorderView(self, needToSendAudioData: self.voiceData)//temporary put it here
                    switchToRecordMode()
                }
            }
        }
    }
    
    //MARK: switch mode
    func switchToPlayMode() {
        UIView.animate(withDuration: 0.2, animations: {
            self.isRecordMode = false
            self.imgSignal.image = UIImage(named: "playButton_red_new")
            self.btnLeft.setBackgroundImage(UIImage(named: "cancelButtonIcon"), for: UIControlState())
            self.btnLeft.setBackgroundImage(UIImage(named: "cancelButtonIcon_red"), for: .highlighted)
            self.btnRight.setBackgroundImage(UIImage(named: "sendButtonIcon"), for: UIControlState())
            self.btnRight.setBackgroundImage(UIImage(named: "sendButtonIcon_red"), for: .highlighted)
            self.btnLeft.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.btnRight.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.btnLeft.isHidden = false
            self.btnRight.isHidden = false
            
            let secondString = self.soundPlayer.duration < 9 ? "0\(Int(ceil(self.soundPlayer.duration)))" : "\(Int(ceil(self.soundPlayer.duration)))"
            self.setInfoLabel("0:\(secondString)", color: UIColor._107107107())
            
        }, completion: { (completed) in
        })
    }
    
    func switchToRecordMode(){
        UIView.animate(withDuration: 0.2, animations: {
            self.isRecordMode = true
            self.imgSignal.image = UIImage(named: "signalIcon_gray")
            self.btnLeft.isHidden = true
            self.btnRight.isHidden = true
            self.btnLeft.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.btnRight.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.setInfoLabel("Hold & Speak!", color: UIColor._182182182())
            self.setNeedsLayout()
        }, completion: { (completed) in
            self.btnLeft.setBackgroundImage(UIImage(named: "playButtonIcon_gray"), for: UIControlState())
            self.btnRight.setBackgroundImage(UIImage(named: "trashButtonIcon_gray"), for: UIControlState())
        }) 
    }
    
    //MARK: recorder
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
    
    private func startRecord() {
        if btnMain.isEnabled {
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
    private func stopRecord() -> Bool {
        soundRecorder.stop()
        if timeTimer != nil {
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
    
    //MARK: helper
    func setInfoLabel(_ text:String, color: UIColor) {
        let attributedText = NSAttributedString(string:text, attributes: [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!])
        lblInfo.attributedText = attributedText
        lblInfo.textAlignment = .center
        lblInfo.sizeToFit()
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
    @objc private func updateTime() {
        currentTime -= 1
        let secondString = currentTime < 10 ? "0\(currentTime)" : "\(currentTime)"
        setInfoLabel("0:\(secondString)", color: UIColor._2499090())
        if currentTime == 0 {
            timeTimer.invalidate()
            _ = self.stopRecord()
            isPressingMainButton = false
        }
    }
    
    private func showWarnMeesage() {
        setInfoLabel("Too Short!", color: UIColor._2499090())
        btnMain.isEnabled = false
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.recoverRecordButton), userInfo: nil, repeats: false)
    }
    
    // transform the record button to origin looks
    @objc private func recoverRecordButton() {
        setInfoLabel("Hold & Speak!", color: UIColor._182182182())
        btnMain.isEnabled = true
    }
    
    private func resumeBackGroundMusic() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            print("cannot resume music")
        }
    }
    
    @objc private func updateProgressTimer() {
        let secondString = self.soundPlayer.currentTime < 9 ? "0\(Int(ceil(self.soundPlayer.currentTime)))" : "\(Int(ceil(self.soundPlayer.currentTime)))"
        self.setInfoLabel("0:\(secondString)", color: UIColor._107107107())
    }
    
    // Ask the user for permission to use the microphone
    func requireForPermission(_ completion: ((Bool) -> ())?) {
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
    fileprivate func startDisplayingFlow() {
        flowTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(self.generateFlow), userInfo: nil, repeats: true)
    }
    
    @objc private func generateFlow() {
        if isPressingMainButton {
            let view = UIView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
            view.layer.cornerRadius = 50
            view.backgroundColor = UIColor._2499090()
            view.alpha = 0.5
            view.center = btnMain.center
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
                
                view.center = self.btnMain.center
                view.alpha = 0
            }, completion: { (complete) in
                view.removeFromSuperview()
            })
            
        } else {
            flowTimer.invalidate()
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension AudioRecorderView:  AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag && !isRecordMode {
            self.imgSignal.image = UIImage(named: "playButton_red_new")
            progressTimer.invalidate()
        }
    }
}



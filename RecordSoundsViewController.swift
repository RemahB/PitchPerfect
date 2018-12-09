//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Remah on 11/3/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - RecordSoundsViewController:  UIViewController, AVAudioRecorderDelegate 
class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    //initialize variables
    var audioRecorder : AVAudioRecorder!
    var pulseLayers = [CAShapeLayer]()
    
    // Connect the UI to Code
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.layer.cornerRadius = stopRecordingButton.frame.size.width/2.0
        createPulse()
        recordButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        stopRecordingButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    
    // MARK: createPulse (create pulse when stopRecordingButton clicked)
    func createPulse() {
        for _ in 0...2 {
            let circularPath = UIBezierPath(arcCenter: .zero, radius: UIScreen.main.bounds.size.width/2.0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            let pulseLayer = CAShapeLayer()
            pulseLayer.path = circularPath.cgPath
            pulseLayer.lineWidth = 2.0
            pulseLayer.fillColor = UIColor.clear.cgColor
            pulseLayer.lineCap = CAShapeLayerLineCap.round
            pulseLayer.position = CGPoint(x: stopRecordingButton.frame.size.width/2.0, y: stopRecordingButton.frame.size.width/2.0)
            stopRecordingButton.layer.addSublayer(pulseLayer)
            pulseLayers.append(pulseLayer)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animatePulse(index: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animatePulse(index: 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.animatePulse(index: 2)
                }
            }
        }
    }
    
    // MARK: animatePulse (Pulse Animation)
    func animatePulse(index: Int) {
        pulseLayers[index].strokeColor = UIColor.black.cgColor
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 2.0
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 0.9
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        pulseLayers[index].add(scaleAnimation, forKey: "scale")
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.duration = 2.0
        opacityAnimation.fromValue = 0.9
        opacityAnimation.toValue = 0.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        opacityAnimation.repeatCount = .greatestFiniteMagnitude
        pulseLayers[index].add(opacityAnimation, forKey: "opacity")
    }
    // MARK: viewWillAppear() 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopRecordingButton.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: recordButtonClicked (when recordButton is clicked )
    @IBAction func recordButtonClicked(_ sender: Any) {
        stopRecordingButton.isHidden = false
        recordButton.setImage(UIImage(named:"stop"), for: .normal)
        recordingLabel.text = "Tap to finish recording"
        recordButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    // MARK: stopRecordingButtonClicked (when stopRecordingButton is clicked )
    @IBAction func stopRecordingButtonClicked(_ sender: Any) {
        recordingLabel.text = "Tap to start recording"
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive (false)
    }
    
    // MARK: audioRecorderDidFinishRecording (if the recording is successful perfomeSegue, if it's not show the alert message )
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }else {
            let alert = UIAlertController(title: "Error", message: "Recording was not successful!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Segue Identifier
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"{
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
            
        }
    }
}





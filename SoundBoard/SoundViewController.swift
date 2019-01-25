//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Nathan Glynn on 4/16/18.
//  Copyright © 2018 Nathan Glynn. All rights reserved.
//

import UIKit
// import library code for audio
import AVFoundation

class SoundViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    //new variable, it will error if not set to nil
    var audioRecorder : AVAudioRecorder? = nil
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // call the function described below after loading the view
        setupRecorder()
        //disable the buttons because there is nothing for them to do yet
        playButton.isEnabled = false
        addButton.isEnabled = false
        self.nameTextField.delegate = self
    }
    // function to clear keyboard entry on `return` press
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // function for building an audio recorder
    func setupRecorder() {
        do {
            // create audio session (this section is just how you have to code audio stuff in xcode, so it's basically copy/paste)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            // create url for audio file
                    // points towards the 'documents' directory in the sandbox of the app
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            // sets filepath components, including filename?
            let pathComponents = [basePath, "sample.m4a"]
            // tells the audioURL to be made out of the pathcomponents described above and the basepath
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            // create settings for audiorecorder
            //make a dictionary called 'settings' that is made of strings because that's how settings in the AVAudiorecorder thing have to be defined
            var settings : [String:AnyObject] = [:]
            // set filetype
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject
            // set sample rate
            settings[AVSampleRateKey] = 44100.0 as AnyObject
            // set number of channels, 2 = stereo
            settings[AVNumberOfChannelsKey] = 2 as AnyObject
            // create AudioRecorder object
            audioRecorder = try AVAudioRecorder (url: audioURL!, settings: settings)
            audioRecorder!.prepareToRecord()
        } catch let error as NSError {
            // what happens if one of the "try"s up there fails
            print(error)
        }
        
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder!.isRecording {
            //stop recording
            audioRecorder?.stop()
            //change button to 'microphone'
            recordButton.setTitle("🎙", for: .normal)
            playButton.isEnabled = true
            addButton.isEnabled = true
        } else {
            //start recording
            audioRecorder?.record()
            //change button to stop
            recordButton.setTitle("🛑", for: .normal)
            
        }
        
        
    }
    
    @IBAction func playTapped(_ sender: Any) {
        do {
        try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer!.play()
        } catch {}
    }
    @IBAction func addTapped(_ sender: Any) {
// coredata stuff
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let sound = Sound(context : context)
       // set values in coredata
        sound.name = nameTextField.text
        sound.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        //return to main view controller after saving
        navigationController?.popViewController(animated: true)
    }
    
}

//
//  AudioRecorder.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/12/21.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

class AudioRecorder {
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var speechReconizer: SpeechRecognizer = SpeechRecognizer()
    
    func requestAudioPermission() -> Bool {
        audioSession = AVAudioSession.sharedInstance()
        var allowed: Bool = false
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission({ allowed_ in
                allowed = allowed_
            })
            try audioSession.setActive(false)
            return allowed
        } catch {
            print("caught an error request Audio")
            return false
        }
    }
    
    func startRecording(unpause: Bool) -> String {
        
        if (!unpause) {
            let audioFilename = String(Date().timeIntervalSince1970)
            let audioFilePath = self.getDocumentsDirectory()
                    .appendingPathComponent("\(audioFilename).wav")
            
            let settings: [String : Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM), // change file extension if changing encoding
                AVSampleRateKey: 22100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                return audioFilename + ".wav"
            } catch {
                print(error)
                finishRecording(success: false, audioFileName: "")
            }
        } else {
            audioRecorder.record()
        }
        return ""
    }
    
    func pauseRecording() {
        audioRecorder.pause()
    }
    
    func finishRecording(success: Bool, audioFileName: String) -> Bool {
        audioRecorder.stop()
        
        if (audioFileName != "") {
            let authResponse = createJWT()
            let accessToken = (authResponse["access_token"] as! String).prefix(222)
            speechReconizer
                .uploadAudio(audioFilePath: self.getDocumentsDirectory()
                                .appendingPathComponent(audioFileName).path,
                            audioFileName: audioFileName,
                            accessToken: String(accessToken)) { [self] i in
                    
                    speechReconizer.requestTranscript(accessToken: String(accessToken),
                                                      audioFileName: audioFileName)
            }
        }
        
        return success
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

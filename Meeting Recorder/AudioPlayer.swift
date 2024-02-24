//
//  AudioPlayer.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/12/21.
//

import Foundation
import AVFoundation

class AudioPlayer {
    var audioSession: AVAudioSession!
    var audioPlayer: AVAudioPlayer!
    
    
    func audioDuration(audioFilePath: String) -> TimeInterval {
        let url = URL(fileURLWithPath: getDocumentsDirectory() + "/" + audioFilePath)
        do {
            return try AVAudioPlayer(contentsOf: url).duration
        } catch {
            // blank
        }
        return TimeInterval(0)
    }
    
    func playSound(audioFilePath: String, currentTime: Double) -> Bool {
        
        let url = URL(fileURLWithPath: getDocumentsDirectory() + "/" + audioFilePath)
        
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            audioPlayer.currentTime += currentTime
            return (audioPlayer.delegate?.audioPlayerDidFinishPlaying?(audioPlayer, successfully: true) != nil)
        } catch {
            print(error)
            return false
        }
    }
    
    func pauseSound() {
        if (audioPlayer != nil) {
            audioPlayer.pause()
        } else {
            print("no audio playing -- couldn't pause audio")
        }
    }
    
    func getDocumentsDirectory() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.path
    }
}

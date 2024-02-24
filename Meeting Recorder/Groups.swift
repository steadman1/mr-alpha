//
//  Groups.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/10/21.
//

import SwiftUI
import Foundation

class Group {
    var name: String
    var backgroundColor: Int
    var audioFileNames: [String]
    var transcript: [[String: String]]
    var uuid: String
    var firestorePath: String
        //UUID().uuidString
    //var icon: String //Path to image maybe?
    
    init(name: String,
         backgroundColor: Int,
         audioFileNames: [String],
         transcript: [[String: String]],
         uuid: String,
         firestorePath: String) {
        
        self.name = name
        self.backgroundColor = backgroundColor
        self.audioFileNames = audioFileNames
        self.transcript = transcript
        self.uuid = uuid == "" ? UUID().uuidString : uuid
        self.firestorePath = firestorePath
    }
    
//    mutating func setTranscript(transcriptRaw_: [String: Any],
//                                audioFileName: String,
//                                error: Bool) -> Group {
//        self.transcript[audioFileName] = []
//        let transcriptRaw = transcriptRaw_["results"] as! [Dictionary<String, Any>]
//
//        for i in 0..<transcriptRaw.count {
//            let alternatives = transcriptRaw[i]["alternatives"]! as! [Dictionary<String, Any>]
//                
//            self.transcript[audioFileName]!.append([
//                "transcript": alternatives[0]["transcript"]! as! String,
//                "timeStamp": i > 0
//                    ? transcriptRaw[i - 1]["resultEndTime"]! as! String
//                    : "0.000s",
//                "error": error ? "true" : "false"
//            ])
//        }
//        return self
//    }
    
    func color() -> String {
        return Group.uiColors[self.backgroundColor]
    }
    
    static let uiColors: [String] = [
        "Blue",
        "Green",
        "Red",
        "Purple",
        "Yellow",
        "Pink",
        "Cyan",
        "Orange",
        "OffWhite",
        "Beige",
        "OffGrey",
        "OffGreen",
    ]
    
    static var currentGroups: [Group] = [
        Group(name: "Unnamed Group",
              backgroundColor: 0,
              audioFileNames: [],
              transcript: [["":""]],
              uuid: "8D31B96A-02AC-4531-976F-A455686F8FE3",
              firestorePath: "")
    ]
    

    static let fallbackGroup = [
        Group(name: "Unnamed Group",
              backgroundColor: 0,
              audioFileNames: [],
              transcript: [["":""]],
              uuid: "8D31B96A-02AC-4531-976F-A455686F8FE3",
              firestorePath: "")
    ]
    
    static func getGroups(username: String) -> [Group] {
        let firebase = Fire()
        let groupsCollection = firebase.firestore.collection("users/\(username)/groups")
        var groups: [Group] = []
        
        let dispatch = DispatchGroup()
        
        dispatch.enter()
        print("ssss")
        groupsCollection.getDocuments() { documents, error in
            print(documents, error)
            if (error == nil) {
                for document in documents!.documents {
                    let data = document.data()
                    groups.append(
                        Group(name: data["name"] as! String,
                              backgroundColor: data["backgroundColor"] as! Int,
                              audioFileNames: data["audioFilePaths"] as! [String],
                              transcript: data["transcript"] as! [[String: String]],
                              uuid: data["uuid"] as! String,
                              firestorePath: "users/\(username)/groups/\(String(describing: data["name"]))")
                    )
                }
                dispatch.leave()
            } else {
                dispatch.leave()
            }
        }
        dispatch.wait()
        
        print(groups)
        
        return groups
    }
    
    static func pushGroup(group: Group) {
        let firebase = Fire()
        firebase.firestore.document(group.firestorePath).setData([
            "name": group.name,
            "backgroundColor": group.backgroundColor,
            "audioFilePaths": group.audioFileNames,
            "transcript": group.transcript,
            "uuid": group.uuid,
        ])
        
        for i in 0..<self.currentGroups.count {
            if (group.uuid == self.currentGroups[i].uuid) {
                self.currentGroups[i] = group
            }
        }
    }
    
    static func nameToDate(audioFileName: String) -> String {
        let timeInterval = Date(timeIntervalSinceReferenceDate: Double(audioFileName)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        
        return formatter.string(from: timeInterval)
    }
}

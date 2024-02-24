//
//  TranscriptSheet.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/14/21.
//

import SwiftUI

struct TranscriptSheetBody: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var index: Int
    var audioFilePath: String
    var audioPlayer: AudioPlayer
    var speechRecognizer = SpeechRecognizer()
    
    @State var transcript: [[String: String]] = [[:]]
    @State var group: Group
    @State var groupIndex: Int = 0
    @State var showingAlert = false
    
    @Binding var deleted: Bool
    
    var body: some View {
        
        let audioFileName = audioFilePath.replacingOccurrences(of: ".wav", with: "")
        let date = Group.nameToDate(audioFileName: audioFileName)
        
        
        
        return ScrollView {
            VStack {
                HStack {
                    Text("\(date)")
                        .font(.title .weight(.semibold))
                        .padding(.leading, UIScreen.padding)
                    Spacer()
                    HStack {
                        Button {
                            showingAlert = true
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .foregroundColor(Color("Red"))
                                .font(.system(size: UIScreen.titleIcon))
                        }.alert(isPresented: $showingAlert) {
                            Alert(title: Text("Delete Audio?"),
                                  message: Text("This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                    do {
                                        try FileManager.default.removeItem(atPath: audioPlayer.getDocumentsDirectory() + "/" + audioFilePath)
                                        group.audioFileNames.remove(at: index)
                
                                        deleted = true
                                        Group.pushGroup(group: group)
                                        
                                        presentationMode.wrappedValue.dismiss()
                                    } catch {
                                        print("couldn't remove audio")
                                    }
                                  },
                                  secondaryButton: .cancel())
                        }
                        
                        Spacer()
                            .frame(width: UIScreen.padding / 2)
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color("Grey").opacity(0.6))
                                .font(.system(size: UIScreen.titleIcon))
                        }.padding(.trailing, UIScreen.padding)
                    }
                }.padding(.top, UIScreen.padding)
                
//                if (Group.currentGroups[groupIndex].transcript[audioFilePath] != nil && Group.currentGroups[groupIndex].transcript[audioFilePath]![0]["error"] == "false") {
//                    ForEach(0..<(Group.currentGroups[groupIndex].transcript[audioFilePath]!.count)) { i in
//                        VStack(alignment: .leading) {
//                            Text(transcript == [[:]]
//                                    ? "" : transcript[i]["timeStamp"]!)
//                                .fontWeight(.semibold)
//
//                            Text(transcript == [[:]]
//                                    ? "" : transcript[i]["transcript"]!)
//
//                        }.frame(width: UIScreen.width - UIScreen.padding * 2,
//                                alignment: .leading)
//                        .padding(.top, UIScreen.padding)
//                    }
//                } else {
//                    ZStack {
//                        Text("loading transcript, reopen later...")
//                    }
//                }
                Text("loading transcript, reopen later...")
            }.frame(alignment: .top)
        }.onAppear() {
            //transcript = speechRecognizer.transcript(audioFilePath: audioFilePath)
            
            
//            var groups = Group.currentGroups
//            for i in 0..<groups.count {
//                if (groups[i].uuid == group.uuid) {
//                    groupIndex = i
//                }
//            }
//
//            let transcriptCurrent = Group.currentGroups[groupIndex].transcript[audioFilePath]
//            if (transcriptCurrent != nil && transcriptCurrent![0]["error"] == "false") {
//                print("already transcribed")
//            } else {
//                let transcriptString = speechRecognizer.transcript(audioFileName: audioFilePath)
//
//                var transcriptJson = try? JSONSerialization.jsonObject(with: transcriptString.data(using: .utf8)!)
//                    as? [String: [[String: Any]]]
//
//                if (transcriptJson == nil) {
//                    transcriptJson = [
//                        "results": [
//                            [
//                                "alternatives": [
//                                    [
//                                        "transcript": transcriptString,
//                                        "resultEndTime": "0.00s",
//                                    ]
//                                ]
//                            ]
//                        ]
//                    ]
//
//                    group = Group.currentGroups[groupIndex].setTranscript(
//                        transcriptRaw_: transcriptJson!,
//                        audioFileName: audioFilePath,
//                        error: true)
//                } else {
//                    group = Group.currentGroups[groupIndex].setTranscript(
//                        transcriptRaw_: transcriptJson!,
//                        audioFileName: audioFilePath,
//                        error: false)
//                }
//
//                var groups = Group.currentGroups
//                for i in 0..<groups.count {
//                    if (groups[i].id == group.id) {
//                        groups[i] = group
//                    }
//                }
//                Group.pushGroups(groups: groups)
//            }
//            transcript = Group.currentGroups[groupIndex].transcript[audioFilePath]!
        }
    }
}

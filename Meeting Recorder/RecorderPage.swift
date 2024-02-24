//
//  RecorderPage.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/10/21.
//

import SwiftUI
import AVFoundation

struct RecorderPage: View {
    
    @State var recordingGroupIndex: Int = 0
    @State var recording: Bool = false
    @State var bodyColor: String = "White"
    @State var currentGroups: [Group] = Group.currentGroups
    @State var group: Group = Group.currentGroups[0]
    @State var audioFileName: String = ""
    @State var paused = false
    var micIcon: CGFloat = 95

    let audioRecorder = AudioRecorder()
    
    var body: some View {
        
        return VStack {
            Spacer().frame(height: UIScreen.topEdgeInset + UIScreen.padding)
            
            ZStack {
                Picker(selection: $recordingGroupIndex,
                       label: Text(currentGroups[recordingGroupIndex].name)
                        .font(.system(size: 22).weight(.semibold))
                        .foregroundColor(!recording ? Color("White") : Color(bodyColor))
                        .padding(UIScreen.padding)) {
                        ForEach(0..<currentGroups.count) { i in
                            Text(currentGroups[i].name)
                    }
                }.pickerStyle(MenuPickerStyle())
                .onChange(of: recordingGroupIndex) { i in
                    bodyColor = Group.uiColors[currentGroups[i].backgroundColor]
                    group = currentGroups[i]
                }
                
            }.frame(width: UIScreen.width - UIScreen.padding * 8,
                    height: 50,
                    alignment: .center)
            .background(recording ? Color("White") : Color(Group.uiColors[currentGroups[recordingGroupIndex].backgroundColor]))
            .cornerRadius(UIScreen.cornerRadius)
            .shadow(color: Color(bodyColor).opacity(0.2),
                    radius: 5, x: 0, y: 8)
            Spacer()
            
            Text(recording ? "Tap to Pause" : "Tap to Record")
                .font(.system(size: 22) .weight(.bold))
                .foregroundColor(recording ? Color("White") : Color(Group.uiColors[currentGroups[recordingGroupIndex].backgroundColor]))
            
            Spacer().frame(height: UIScreen.padding)
            
            VStack {
                ZStack {
                    Image(systemName: recording ? "mic.circle.fill" : "mic")
                        .foregroundColor(recording ? Color("White") : Color(Group.uiColors[currentGroups[recordingGroupIndex].backgroundColor]))
                        //.background(Color("White"))
                        .font(.system(size: recording ? micIcon : micIcon - 35))
                }.frame(width: micIcon, height: micIcon)
                .background(recording ? Color(bodyColor) : Color("White"))
                .clipShape(Circle())
            }.shadow(color: Color("Black").opacity(0.15), radius: 5, x: 0, y: 6)
            .onTapGesture {
                if (recording) {
                    withAnimation(.spring()) {
                        bodyColor = "White"
                    }
                }
                recording.toggle()
                
                if (recording == true) {
                    
                    if (audioRecorder.requestAudioPermission()) {
                        if (!paused) {
                            audioFileName = audioRecorder.startRecording(unpause: paused)
                        } else {
                            audioRecorder.startRecording(unpause: paused)
                        }
                        paused = false
                        
                        withAnimation(.spring()) {
                            bodyColor = Group.uiColors[currentGroups[recordingGroupIndex].backgroundColor]
                        }
                    }
                } else {
                    
                    if (audioRecorder.requestAudioPermission()) {
                        
                        audioRecorder.pauseRecording()
                        paused = true
                    }
                }
            }
            
            Spacer()
            
            Button {
                if (audioRecorder.requestAudioPermission() && recording) {
                    let success = audioRecorder.finishRecording(success: true,
                                                                audioFileName: audioFileName)
                    if (success && audioFileName != "") {
                        
                        withAnimation(.spring()) {
                            bodyColor = "White"
                        }
                        recording = false
                        
                        group.audioFileNames.insert(audioFileName, at: 0)
                        Group.currentGroups[recordingGroupIndex].audioFileNames.append(audioFileName)
                        //print(Group.currentGroups)
                        for group in Group.currentGroups {
                            Group.pushGroup(group: group)
                        }
                    }
                }
            } label: {
                ZStack {
                    Text("Save & Stop Audio")
                        .font(.system(size: 22).weight(.semibold))
                        .foregroundColor(!recording ? Color("White") : Color(bodyColor))
                        .padding(UIScreen.padding)
                }.frame(width: UIScreen.width - UIScreen.padding * 8,
                       height: 50,
                       alignment: .center)
               .background(recording ? Color("White") : Color(Group.uiColors[currentGroups[recordingGroupIndex].backgroundColor]))
               .cornerRadius(UIScreen.cornerRadius)
               .shadow(color: Color(Group.uiColors[currentGroups[recordingGroupIndex].backgroundColor]).opacity(0.2),
                       radius: 5, x: 0, y: 8)
            }
            
            Spacer()
                .frame(height: UIScreen.topEdgeInset + UIScreen.padding)
            
        }.frame(width: UIScreen.width,
                height: UIScreen.height,
                alignment: .top)
        .background(!recording ? Color("White").ignoresSafeArea() : Color(bodyColor).ignoresSafeArea())
        .onAppear() {
            audioRecorder.requestAudioPermission()
            currentGroups = Group.fallbackGroup
        }
    }
}

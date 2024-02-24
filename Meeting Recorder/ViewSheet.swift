//
//  ViewSheet.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/12/21.
//

import SwiftUI
import AVFoundation

struct SheetViewBody: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var group: Group
    @State var playing = false
    @State var showingEditSheet = false
    @State var availableTransctips: [String] = []
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(group.name)
                        .font(.title .weight(.semibold))
                        .padding(.leading, UIScreen.padding)
                    Spacer()
                    HStack {
                        Button {
                            showingEditSheet.toggle()
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .foregroundColor(Color(Group.uiColors[group.backgroundColor]))
                                .font(.system(size: UIScreen.titleIcon))
                            
                        }.sheet(isPresented: $showingEditSheet) {
                            SheetBody(group: self.$group)
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
                
                
                ForEach(0..<group.audioFileNames.count) { i in
                    Spacer()
                        .frame(height: UIScreen.padding)
                    
                    AudioFileViewer(
                        index: i,
                        audioFilePath: group.audioFileNames[i],
                        transcriptAvailable: availableTransctips.contains(group.audioFileNames[i]),
                        group: group,
                        playingGlobal: $playing,
                        backgroundColor: $group.backgroundColor)
                }
            }
            Spacer()
        }.onAppear() {
            let speechRecognizer = SpeechRecognizer()
            speechRecognizer.availableTranscripts() { i in
                let json = try? JSONSerialization.jsonObject(with: i.data(using: .utf8)!) as? [String: Any]
                print(json)
                
                let items = json!["items"] as! [[String: Any]]
                
                for item in items {
                    print(item["name"])
                    availableTransctips.append((item["name"] as! String)
                                                .replacingOccurrences(of: "transcripts/", with: ""))
                }
                print(availableTransctips)
            }
        }
    }
}


struct AudioFileViewer: View {
    var index: Int
    var audioFilePath: String
    var transcriptAvailable: Bool
    
    let groupWidgetSize = UIScreen.width - UIScreen.padding * 2
    let audioPlayer = AudioPlayer()
    let avaudioplayer = AVAudioPlayer()
    let ZStackHeight: CGFloat = 120
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State var deleted = false
    @State var group: Group
    @State var playingLocal = false
    @State var showingActionSheet = false
    @State var currentTime: Double = 0
    @State var traveringScrubber = false
    @State var showingTranscriptSheet = false
    
    @Binding var playingGlobal: Bool
    @Binding var backgroundColor: Int
    
    var body: some View {
        let duration = audioPlayer.audioDuration(audioFilePath: audioFilePath)
        let durationMaxSeconds = Int(round(duration.truncatingRemainder(dividingBy: 60)))
        let durationMaxMinutes = Int(floor(duration / 60))
        
        return VStack {
            ZStack {
                HStack {
                    Text(transcriptAvailable ? "Open Transcript" : "Transcript Unavailable")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(!deleted ? Color(Group.uiColors[backgroundColor]) : Color("Grey"))
                    
                }.frame(width: groupWidgetSize - UIScreen.padding * 2, height: 40, alignment: .bottomLeading)
                .padding(UIScreen.padding)
                .background(Color("White"))
                .cornerRadius(UIScreen.cornerRadius)
                .shadow(color: Color("Black").opacity(0.15), radius: 5, x: 0, y: 6)
                .offset(y: ZStackHeight / 2)
                .onTapGesture {
                    showingTranscriptSheet = !deleted ? true : false
                }.fullScreenCover(isPresented: $showingTranscriptSheet) {
                    TranscriptSheetBody(index: index,
                                        audioFilePath: audioFilePath,
                                        audioPlayer: audioPlayer,
                                        group: group,
                                        deleted: $deleted)
                }
                
                HStack {
                    Button {
                        if (!playingLocal) {
                            playingLocal = true
                            playingGlobal = true
                            audioPlayer.playSound(audioFilePath: audioFilePath, currentTime: 0)
                            
                        } else {
                            playingLocal = false
                            playingGlobal = false
                            currentTime = 0
                            audioPlayer.pauseSound()
                        }
                        
                    } label: {
                        Image(systemName: playingLocal ? "pause.circle.fill" : "play.circle.fill")
                            .foregroundColor(Color("White"))
                            .font(.system(size: 40))
                    }
                    Spacer()
                    
                    Spacer().frame(width: UIScreen.padding / 2)
                    
                    VStack {
                        Slider(value: $currentTime,
                               in: 0...Double(duration)) { i in
                            
                            traveringScrubber = i
                            
                            if (i == false) {
                                playingLocal = true
                                playingGlobal = true
                                audioPlayer.playSound(audioFilePath: audioFilePath, currentTime: currentTime)
                            }
                            
                        }.accentColor(Color("White"))
                        .onReceive(timer) { i in
                            if (playingLocal && currentTime <= duration) {
                                currentTime += 0.5 // must be same added value as the timer
                            } else {
                                playingLocal = false
                                playingGlobal = false
                                 
                                if (!traveringScrubber) {
                                    currentTime = 0
                                }
                            }
                        }
                        
                        HStack {
                            Text("0:00")
                                .fontWeight(.semibold)
                                .foregroundColor(Color("White"))
                            
                            Spacer()
                            
                            Text("\(durationMaxMinutes):\(durationMaxSeconds < 10 ? "0" + String(durationMaxSeconds) : String(durationMaxSeconds))")
                                .fontWeight(.semibold)
                                .foregroundColor(Color("White"))
                        }
                    }
                    
                    Spacer().frame(width: UIScreen.padding / 2)
                    Spacer()

                }.padding(UIScreen.padding)
                .frame(width: groupWidgetSize,
                        height: 90,
                         alignment: .leading)
                 .background(Color(deleted ? "Grey" : Group.uiColors[backgroundColor]))
                 .cornerRadius(UIScreen.cornerRadius)
                 .shadow(color: Color(deleted ? "Grey" : Group.uiColors[backgroundColor])
                            .opacity(0.2), radius: 5, x: 0, y: 8)
                
            }.frame(height: ZStackHeight)
            
            Spacer()
                .frame(height: UIScreen.padding)
        }
    }
}

//CUSTOM SLIDER
//            ZStack{
//                Capsule()
//                    .fill(Color("Black").opacity(0.3))
//                    .frame(width: UIScreen.width, height: 2)
//
//                Capsule()
//                    .fill(Color("White"))
//                    .frame(width: CGFloat(currentTime), height: 2)
//
//                Circle()
//                    .fill(Color("White"))
//                    .frame(height: 8)
//                    .offset(x: CGFloat(currentTime))
//                    .gesture(DragGesture().onChanged({ dragVal in
//                        print(dragVal)
//                    }))
//            }.padding(UIScreen.padding * 2)

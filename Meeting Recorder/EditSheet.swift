//
//  EditSheet.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/11/21.
//

import SwiftUI

struct SheetBody: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var group: Group
    @State var color: String = ""
    @State var text: String = ""
    @State var isEditing = false
    
    var backgroundColor = Color("Grey").opacity(0.12)
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.text
        }, set: {
            self.text = $0
            self.group.name = $0
        })
        
        return VStack {
            Spacer()
                .frame(height: UIScreen.padding)
            HStack{
                Spacer()
                Spacer().frame(width: UIScreen.padding * 3)
                Text("Edit Group")
                    .font(.system(size: 22, weight: .semibold))
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                    
                    Group.pushGroup(group: group)

                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .renderingMode(.template)
                        .foregroundColor(Color("Green"))
                        //.background(Color("White"))
                        .clipShape(Circle())
                        .font(.system(size: 30))
                }

                Spacer().frame(width: UIScreen.padding)
            }
            Spacer()
                .frame(height: UIScreen.padding)
            ScrollView {
                VStack {
                    VStack {
                        EditGroupWidget(group: $group)
                    }.frame(width: UIScreen.width,
                            height: UIScreen.width - 50)
                    .background(backgroundColor)
                    
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Group Name")
                                    .padding(EdgeInsets(
                                        top: UIScreen.padding * 2,
                                        leading: 0,
                                        bottom: UIScreen.padding / 2,
                                        trailing: 0))
                                    .font(.headline)
                                TextField("Enter a Group Name", text: binding) { isEditing in
                                    self.isEditing = isEditing
                                } onCommit : {
                                    self.group.name = text
                                }.padding(8)
                                .background(RoundedRectangle(cornerRadius: 50).fill(backgroundColor))
                                .font(.system(size: 20, weight: .semibold))
                                //.cornerRadius(15)
                                .frame(width: UIScreen.width - UIScreen.padding * 6,
                                       height: 20)
                            }
                            Spacer()
                        }
                    }.frame(width: UIScreen.width,
                            height: 25 + UIScreen.padding,
                            alignment: .leading)
                    
                    Spacer()
                        .frame(height: 40 + UIScreen.padding)
                    VStack {
                        ForEach(0..<Group.uiColors.count / 4) { i in
                            HStack {
                                Spacer()
                                ForEach(0..<4) { j in
                                    let width: CGFloat = 60.0
                                    let colorName: String = Group.uiColors[i * 4 + j]
                                    
                                    Button {
                                        self.group.backgroundColor = Group.uiColors.firstIndex(of: colorName)!
                                    } label: {
                                        RoundedRectangle(cornerRadius: width)
                                    }.frame(width: width, height: width)
                                    .foregroundColor(Color(colorName))
                                    .shadow(color: Color(colorName).opacity(0.3),
                                            radius: 6,
                                            x: 0,
                                            y: 10)
                                    Spacer()
                                }
                            }.padding(.top, UIScreen.padding)
                        }

                    }.frame(width: UIScreen.width,
                            height: UIScreen.width,
                            alignment: .top)
                    .background(backgroundColor)
                }
            }
        }.background(backgroundColor).ignoresSafeArea()
        .onAppear {
            self.group = group
            self.color = Group.uiColors[group.backgroundColor]
            self.text = group.name
        }
    }
}

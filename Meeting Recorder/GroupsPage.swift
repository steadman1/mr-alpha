//
//  GroupsPage.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/10/21.
//

import SwiftUI

struct GroupsPage: View {

    var getGroups: Array<Group> = Group.fallbackGroup
    
    var body: some View {
        
        return VStack(alignment: .leading) {
            Spacer()
                .frame(height: UIScreen.topEdgeInset)
            HStack {
                Text("Groups")
                    .font(.largeTitle .weight(.semibold))
                    .padding(UIScreen.padding)
                Spacer()
                Image(systemName: "gearshape")
                    .foregroundColor(Color("Black"))
                    .font(.system(size: UIScreen.titleIcon))
                    .padding(UIScreen.padding)
            }
            VStack {
                if (getGroups.count % 2 == 0) {
                    ForEach(0..<getGroups.count / 2) { i in
                        GroupHStack(index: i, groups: getGroups)
                        Spacer()
                            .frame(height: UIScreen.padding)
                    }
                } else {
                    ForEach(0..<(getGroups.count - 1) / 2) { i in
                        GroupHStack(index: i, groups: getGroups)
                        Spacer()
                            .frame(height: UIScreen.padding)
                    }
                    HStack {
                        Spacer()
                            .frame(width: UIScreen.padding)
                        GroupWidget(group: getGroups[getGroups.count - 1])
                        Spacer()
                    }
                }
            }
            Spacer()
        }.frame(width: UIScreen.width,
                height: UIScreen.height,
                alignment: .leading)
        
    }
}

struct GroupHStack: View {
    var index: Int
    var groups: Array<Group>
    
    var body: some View {
        //print($groups)
        return HStack {
            Spacer()
                .frame(width: UIScreen.padding)
            GroupWidget(group: groups[index * 2])
            Spacer()
                .frame(width: UIScreen.padding)
            GroupWidget(group: groups[index * 2 + 1])
            Spacer()
                .frame(width: UIScreen.padding)
        }
    }
}

struct GroupWidget: View {
    @State var group: Group
    @State var showingEditSheet = false
    @State var showingViewSheet = false
    
    var groupWidgetSize = UIScreen.width / 2 - UIScreen.padding - UIScreen.padding / 2
    
    var body: some View {
        VStack() {
            HStack {
                Spacer()
                Button {
                    showingEditSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(Color("White"))
                        .font(.system(size: 25))
                }.sheet(isPresented: $showingEditSheet) {
                    SheetBody(group: self.$group)
                }


            }.padding(UIScreen.padding)
            Spacer()
            HStack {
                Text(group.name)
                    .font(.headline)
                    .padding(UIScreen.padding)
                    .foregroundColor(Color("White"))
                Spacer()
            }
        }.frame(width: groupWidgetSize,
               height: groupWidgetSize + 10,
                alignment: .leading)
        .background(Color(Group.uiColors[group.backgroundColor]))
        .cornerRadius(UIScreen.cornerRadius)
        .shadow(color: Color(Group.uiColors[group.backgroundColor]).opacity(0.2), radius: 5, x: 0, y: 8)
        .onTapGesture {
            SpeechRecognizer().requestSpeechAccess()
            showingViewSheet.toggle()
        }.fullScreenCover(isPresented: $showingViewSheet) {
            SheetViewBody(group: $group)
        }.onAppear() {
            
            let groups = Group.currentGroups
            for i in 0..<groups.count {
                if (groups[i].uuid == group.uuid) {
                    group = groups[i]
                }
            }
        }
    }
}

struct EditGroupWidget: View {
    @Binding var group: Group
    
    @State var showingSheet = false
    var groupWidgetSize = UIScreen.width / 2 - UIScreen.padding - UIScreen.padding / 2
    
    var body: some View {
        VStack() {
            HStack {
                Spacer()
                Image(systemName: "ellipsis.circle.fill")
                    .foregroundColor(Color("White"))
                    .font(.system(size: 25 + 8))


            }.padding(UIScreen.padding)
            Spacer()
            HStack {
                Text(group.name)
                    .font(.system(size: 17 + 5.5, weight: .semibold))
                    .padding(UIScreen.padding)
                    .foregroundColor(Color("White"))
                Spacer()
            }
        }.frame(width: groupWidgetSize + 50,
                height: groupWidgetSize + 60,
                alignment: .leading)
        .background(Color(Group.uiColors[group.backgroundColor]))
        .cornerRadius(UIScreen.cornerRadius)
        .shadow(color: Color(Group.uiColors[group.backgroundColor]).opacity(0.3), radius: 6, x: 0, y: 10)
    }
}

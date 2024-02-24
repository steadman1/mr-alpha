//
//  ContentView.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/9/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    init() {
        FirebaseApp.configure()
        
        let username = "s_steadman"
        let firebase = Fire()
        
        let groups = firebase.firestore.collection("user/\(username)/groups")
        
        let getGroups = Group.getGroups(username: username)
        
        Group.currentGroups = getGroups.isEmpty ? Group.currentGroups : getGroups
        
        print(Group.currentGroups[0].name)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                PageView()
            }
        }.edgesIgnoringSafeArea(.vertical)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PageView: View {
    
    var body: some View {
        TabView {
            RecorderPage()
            GroupsPage()
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.height + 100)
        .tabViewStyle(PageTabViewStyle())
        .onAppear(perform: {
            UIScrollView.appearance().bounces = false
            UITableView.appearance().showsHorizontalScrollIndicator = false
        })
    }
}

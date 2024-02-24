//
//  FirebaseFunctions.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 10/2/21.
//

import Foundation
import Firebase

struct Fire {
    var firestore: Firestore
    var fireSQL: Storage
    
    init() {
        self.fireSQL = Storage.storage()
        self.firestore = Firestore.firestore()
    }
}

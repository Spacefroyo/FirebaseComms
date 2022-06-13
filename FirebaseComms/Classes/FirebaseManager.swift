//
//  FirebaseManager.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import FirebaseFirestore
import Firebase

class FirebaseManager: NSObject {
    
    let auth: Auth
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}

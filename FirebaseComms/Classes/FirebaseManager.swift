//
//  FirebaseManager.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import FirebaseFirestore
import Firebase
import SwiftUI

class FirebaseManager: NSObject {
    
    let auth: Auth
    let data: [String: Any?]
    
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        self.auth = Auth.auth()
        @AppStorage("givenName") var givenName : String!
        @AppStorage("familyName") var familyName : String!
        @AppStorage("profilePicUrl") var profilePicUrl : URL!
        self.data = ["email": auth.currentUser?.email, "familyName": familyName, "givenName": givenName, "profilePicUrl": profilePicUrl]
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
    static var seenUsers: [String: [String: Any]] = [:]
    static func getUserData(email: String, completion: @escaping ([String:Any]) -> ()){
        shared.firestore.collection("users").document(email).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            seenUsers[email] = data
            completion(data)
        }
   }
}

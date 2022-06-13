//
//  NewGroupView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/12/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct NewFollowView: View {
    @State var email = ""
    @State var from: BroadcastsView? = nil
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                
                Spacer()
                
                Button {
                    newFollow(email: email)
                    from?.expand = false
                } label: {
                    Text("Follow")
                }
            }
            .navigationTitle("New Follow")
        }
    }
    
    func newFollow(email: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("follows").document(uid)
        document.getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch broadcastId document: ", error)
                return
            }
            FirebaseManager.shared.firestore.collection("uids").document(email.lowercased()).getDocument { snapshot2, error in
                if let error = error {
                    print("Failed to fetch current user: ", error)
                    return
                }
                guard let data2 = snapshot2?.data() else { return }
                print("done1")
                let data = snapshot?.data() ?? ["follows":[]]
                var follows = data["follows"] as? [String] ?? []
                follows.append(data2["uid"] as! String)
                from?.storeFollow(uid: data2["uid"] as! String)
                from?.receivedBroadcastViews()
                document.setData(["follows": follows]) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
            }
        }
        print("done")
    }
}

struct NewFollowView_Previews: PreviewProvider {
    static var previews: some View {
        NewFollowView()
    }
}

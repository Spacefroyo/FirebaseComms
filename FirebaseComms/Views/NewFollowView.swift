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
    @State var follow = ""
    @State var from: BroadcastsView? = nil
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $follow)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
//                    .textCase(.lowercase)
                
                Spacer()
                
                Button {
                    newFollow(follow: follow)
                    from?.expand = false
                } label: {
                    Text("Follow")
                }
            }
            .navigationTitle("New Follow")
        }
        .onChange(of: follow, perform: {_ in follow = follow.lowercased()})
    }
    
//    func lowercaseFollow() {
//        follow = follow.lowercased()
//    }
    
    func newFollow(follow: String) {
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        
        let document = FirebaseManager.shared.firestore.collection("follows").document(email)
        document.getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch broadcastId document: ", error)
                return
            }
            FirebaseManager.shared.firestore.collection("users").document(follow).getDocument { snapshot2, error in
                if let error = error {
                    print("Failed to fetch user to follow: ", error)
                    return
                }
                let data = snapshot?.data() ?? ["follows":[]]
                var follows = data["follows"] as? [String] ?? []
                if follows.contains(follow.lowercased()) {
                    print("Already followed")
                    return
                }
                follows.append(follow)
                from?.storeFollow(email: follow)
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

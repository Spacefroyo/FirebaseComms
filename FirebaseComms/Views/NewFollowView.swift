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
    @State var emailError: String = ""
    @State var success: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                VStack {
                    TextField("Email", text: $follow)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.theme.accent)
                        .cornerRadius(15)
                        .onTapGesture {
                            emailError = ""
                            success = true
                        }
                        .onSubmit {
                            newFollow(follow: follow)
                        }
                    
                    Text(emailError)
                        .foregroundColor(success ? Color.green : Color.red)
                    
                    Spacer()
                    
                    Button {
                        newFollow(follow: follow)
                        
                    } label: {
                        Text("Follow")
                    }
                }
                .foregroundColor(Color.theme.foreground)
                .padding()
                .navigationTitle("New Follow")
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButtonView(dismiss: self.dismiss)
                    }
                }
            }
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
                print("Failed to fetch follows document: ", error)
                return
            }
            let document2 = FirebaseManager.shared.firestore.collection("followers").document(follow)
            document2.getDocument(completion: { snapshot2, err in
                if let error = error {
                    print("Failed to fetch followers document: ", error)
                    return
                }
                FirebaseManager.shared.firestore.collection("users").document(follow).getDocument { snapshot3, error in
                    if let error = error {
                        print("Failed to fetch user to follow: ", error)
                        return
                    }
                    
//                    print(follow)
//                    print(email)
                    
                    if let snapshot3 = snapshot3, !snapshot3.exists {
                        emailError = "Could not find user"
                        success = false
                        return
                    }
                    let data = snapshot?.data() ?? ["follows":[]]
                    var follows = data["follows"] as? [String] ?? []
                    if follow.lowercased() == email {
                        emailError = "You can't follow yourself"
                        success = false
                        return
                    } else if follows.contains(follow.lowercased()) {
                        emailError = "You are already following this user"
                        success = false
                        return
                    }
                    follows.append(follow)
                    let data2 = snapshot2?.data() ?? ["followers":[]]
                    var followers = data2["followers"] as? [String] ?? []
                    followers.append(email)
//                    from?.storeFollow(email: follow)
                    from?.receivedBroadcastViews()
                    document.setData(["follows": follows]) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                    }
                    document2.setData(["followers": followers]) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                    }
//                    from?.expand = false
                    emailError = "You have successfully followed " + follow
                    success = true
                    self.follow = ""
                }
            })
        }
    }
}

struct NewFollowView_Previews: PreviewProvider {
    static var previews: some View {
        NewFollowView()
    }
}

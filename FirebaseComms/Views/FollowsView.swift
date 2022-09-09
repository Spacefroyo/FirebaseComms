//
//  NewGroupView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/12/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct FollowsView: View {
    @State var other = ""
    @State var emailError: String = ""
    @State var success: Bool = true
    @State var toggleBool: Bool = false
    @AppStorage("givenName") var givenName: String!
    @AppStorage("familyName") var familyName: String!
//    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        HStack {
                            Text("Friends")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            Spacer()
                        }
                        Divider()
                        let uv = UserListView(broadcast: Broadcast(data: ["id": -1, "email": FirebaseManager.shared.auth.currentUser?.email ?? ""]), connectionType: "friends", path:
                                        FirebaseManager.shared.firestore
                                            .collection("messages")
                                            .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                            .collection("privateChannels"), appendView: {(email: String) -> AnyView? in
                                                return AnyView(
                                                    Button {
                                                        manageConnection(other: email, selfConnection: "friends", otherConnection: "friends", add: false)
                                                    } label: {
                                                        Image(systemName: "x.circle.fill")
                                                            .foregroundColor(Color.red)
                                                    }
                                                )}, expandable: true)
                        uv
                            .onChange(of: emailError, perform: {_ in
                                uv.getUserData(after: {
                                    toggleBool.toggle()
                                })
                            })
                        let uv2 = UserListView(broadcast: Broadcast(data: ["id": -1, "email": FirebaseManager.shared.auth.currentUser?.email ?? ""]), connectionType: "pendingOutFriends", path:
                                        FirebaseManager.shared.firestore
                                            .collection("messages")
                                            .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                            .collection("privateChannels"), appendView: {(email: String) -> AnyView? in
                                                return AnyView(
                                                HStack{
                                                    Text("Pending")
                                                        .foregroundColor(Color.theme.accent)
                                                    Button {
                                                        manageConnection(other: email, selfConnection: "pendingOutFriends", otherConnection: "pendingInFriends", add: false)
                                                    } label: {
                                                        Image(systemName: "x.circle.fill")
                                                            .foregroundColor(Color.red)
                                                    }
                                                })}, expandable: false)
                        uv2
                            .onChange(of: emailError, perform: {_ in
                                uv2.getUserData(after: {
                                    toggleBool.toggle()
                                })
                            })
                        let uv3 = UserListView(broadcast: Broadcast(data: ["id": -1, "email": FirebaseManager.shared.auth.currentUser?.email ?? ""]), connectionType: "pendingInFriends", path:
                                        FirebaseManager.shared.firestore
                                            .collection("messages")
                                            .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                            .collection("privateChannels"), appendView: {(email: String) -> AnyView? in
                                        AnyView(
                                        HStack {
                                            Text("Pending")
                                                .foregroundColor(Color.theme.accent)
                                            Button {
                                                manageConnection(other: email, selfConnection: "pendingInFriends", otherConnection: "pendingOutFriends", add: false)
                                                manageConnection(other: email, selfConnection: "friends", otherConnection: "friends", add: true)
                                            } label: {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color.green)
                                            }
                                            Button {
                                                manageConnection(other: email, selfConnection: "pendingInFriends", otherConnection: "pendingOutFriends", add: false)
                                            } label: {
                                                Image(systemName: "x.circle.fill")
                                                            .foregroundColor(Color.red)
                                            }
                                        })}, expandable: false)
                        uv3
                            .onChange(of: emailError, perform: {_ in
                                uv3.getUserData(after: {
                                    toggleBool.toggle()
                                })
                            })
                        VStack {
                            TextField("Email", text: $other)
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
                                    manageConnection(other: other, selfConnection: "pendingOutFriends", otherConnection: "pendingInFriends", add: true)
                                    self.other = ""
                                }
                            
                            Text(emailError)
                                .foregroundColor(success ? Color.green : Color.red)
                            
                            Spacer()
                            
                            Button {
                                manageConnection(other: other, selfConnection: "pendingOutFriends", otherConnection: "pendingInFriends", add: true)
                                self.other = ""
                            } label: {
                                Text("Add friend")
                            }
                        }
                    }
                    
                    Spacer()
                        .padding(.vertical)
                    
                    VStack {
                        HStack {
                            Text("Following")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            Spacer()
                        }
                        Divider()
                        let uv = UserListView(broadcast: Broadcast(data: ["id": -1, "email": FirebaseManager.shared.auth.currentUser?.email ?? ""]), connectionType: "follows", path:
                                        FirebaseManager.shared.firestore
                                            .collection("messages")
                                            .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                            .collection("privateChannels"), appendView: {(email: String) -> AnyView? in
                                                return AnyView(
                                                    Button {
                                                        manageConnection(other: email, selfConnection: "follows", otherConnection: "followers", add: false)
                                                    } label: {
                                                        Image(systemName: "x.circle.fill")
                                                            .foregroundColor(Color.red)
                                                    }
                                                )}, expandable: true)
                        uv
                            .onChange(of: emailError, perform: {_ in
                                uv.getUserData(after: {
                                    toggleBool.toggle()
                                })
                            })
                        let uv2 = UserListView(broadcast: Broadcast(data: ["id": -1, "email": FirebaseManager.shared.auth.currentUser?.email ?? ""]), connectionType: "pendingFollows", path:
                                        FirebaseManager.shared.firestore
                                            .collection("messages")
                                            .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                            .collection("privateChannels"), appendView: {(email: String) -> AnyView? in
                                                return AnyView(
                                                HStack{
                                                    Text("Pending")
                                                        .foregroundColor(Color.theme.accent)
                                                    Button {
                                                        manageConnection(other: email, selfConnection: "pendingFollows", otherConnection: "pendingFollowers", add: false)
                                                    } label: {
                                                        Image(systemName: "x.circle.fill")
                                                            .foregroundColor(Color.red)
                                                    }
                                                })}, expandable: false)
                        uv2
                            .onChange(of: emailError, perform: {_ in
                                uv2.getUserData(after: {
                                    toggleBool.toggle()
                                })
                            })
                        VStack {
                            TextField("Email", text: $other)
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
                                    manageConnection(other: other, selfConnection: "pendingFollows", otherConnection: "pendingFollowers", add: true)
                                    self.other = ""
                                }
                            
                            Text(emailError)
                                .foregroundColor(success ? Color.green : Color.red)
                            
                            Spacer()
                            
                            Button {
                                manageConnection(other: other, selfConnection: "pendingFollows", otherConnection: "pendingFollowers", add: true)
                                self.other = ""
                            } label: {
                                Text("Follow")
                            }
                        }
                    }
                    
                    Spacer()
                        .padding(.vertical)
                    
                    VStack {
                        HStack {
                            Text("Followers")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            Spacer()
                        }
                        Divider()
                        let uv = UserListView(broadcast: Broadcast(data: ["id": -1, "email": FirebaseManager.shared.auth.currentUser?.email ?? ""]), connectionType: "followers", path:
                                        FirebaseManager.shared.firestore
                                            .collection("messages")
                                            .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                            .collection("privateChannels"), appendView: {(email: String) -> AnyView? in
                                                return AnyView(
                                                    Button {
                                                        manageConnection(other: email, selfConnection: "followers", otherConnection: "follows", add: false)
                                                    } label: {
                                                        Image(systemName: "x.circle.fill")
                                                            .foregroundColor(Color.red)
                                                    }
                                                )}, expandable: true)
                        uv
                            .onChange(of: emailError, perform: {_ in
                                uv.getUserData(after: {
                                    toggleBool.toggle()
                                })
                            })
                        let uv2 = UserListView(broadcast: Broadcast(data: ["id": -1, "email": FirebaseManager.shared.auth.currentUser?.email ?? ""]), connectionType: "pendingFollowers", path:
                                        FirebaseManager.shared.firestore
                                            .collection("messages")
                                            .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                            .collection("privateChannels"), appendView: {(email: String) -> AnyView? in
                                        AnyView(
                                        HStack {
                                            Text("Pending")
                                                .foregroundColor(Color.theme.accent)
                                            Button {
                                                manageConnection(other: email, selfConnection: "pendingFollowers", otherConnection: "pendingFollows", add: false)
                                                manageConnection(other: email, selfConnection: "followers", otherConnection: "follows", add: true)
                                            } label: {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color.green)
                                            }
                                            Button {
                                                manageConnection(other: email, selfConnection: "pendingFollowers", otherConnection: "pendingFollows", add: false)
                                            } label: {
                                                Image(systemName: "x.circle.fill")
                                                            .foregroundColor(Color.red)
                                            }
                                        })}, expandable: false)
                        uv2
                            .onChange(of: emailError, perform: {_ in
                                uv2.getUserData(after: {
                                    toggleBool.toggle()
                                })
                            })
                    }
                }
                .foregroundColor(Color.theme.foreground)
                .padding([.leading, .trailing])
            }
            .navigationTitle("People")
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onChange(of: other, perform: {_ in other = other.lowercased()})
    }
    
    func manageConnection(other: String, selfConnection: String, otherConnection: String, add: Bool) {
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        
        if other.lowercased() == email {
            emailError = "You can't add yourself"
            success = false
            return
        }
        
        if add && (selfConnection == "followers" || selfConnection == "friends") {
            var userSort: [String] = [email, other]
            userSort.sort (by: {
                $0.compare($1) == .orderedAscending
            })
            FirebaseManager.shared.firestore
                .collection("messages")
                .document(userSort[0])
                .collection("privateChannels")
                .document(userSort[1])
                .setData([:])
        }
        
        let document = FirebaseManager.shared.firestore.collection("connections").document(email)
        document.getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch self connections document: ", error)
                return
            }
            let document2 = FirebaseManager.shared.firestore.collection("connections").document(other)
            document2.getDocument(completion: { snapshot2, err in
                if let error = error {
                    print("Failed to fetch other connections document: ", error)
                    return
                }
                FirebaseManager.shared.firestore.collection("users").document(other).getDocument { snapshot3, error in
                    if let error = error {
                        print("Failed to fetch user: ", error)
                        return
                    }
                    if let snapshot3 = snapshot3, !snapshot3.exists {
                        emailError = "Could not find user"
                        success = false
                        return
                    }
                    let data = snapshot?.data() ?? [selfConnection:[]]
                    var selfData = data[selfConnection] as? [String] ?? []
                    let data2 = snapshot2?.data() ?? [otherConnection:[]]
                    var otherData = data2[otherConnection] as? [String] ?? []
                    
                    if add {
                        if selfData.contains(other.lowercased()) {
                            emailError = other + " is already one of your " + selfConnection
                            success = false
                            return
                        }
                        selfData.append(other)
                        otherData.append(email)
                    } else {
                        if !selfData.contains(other.lowercased()) {
                            emailError = other + " is not one of your " + selfConnection
                            success = false
                            return
                        }
                        let selfIndex = selfData.firstIndex(of: other) ?? -1
                        if selfIndex > -1 {
                            selfData.remove(at: selfIndex)
                        }
                        let otherIndex = otherData.firstIndex(of: email) ?? -1
                        if otherIndex > -1 {
                            otherData.remove(at: otherIndex)
                        }
//                        selfData = selfData.filter {$0 != other}
//                        otherData = otherData.filter {$0 != email}
                    }
                    
                    document.setData([selfConnection: selfData], merge: true) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                    }
                    document2.setData([otherConnection: otherData], merge: true) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                    }
                    emailError = "Success"
                    success = true
                    
                    var title = ""
                    var body = ""
                    if add {
                        switch selfConnection {
                        case "friends": do {
                            title = "Friend request accepted"
                            body = " has accepted your friend request"
                        } case "followers": do {
                            title = "Follow request accepted"
                            body = " has accepted your follow request"
                        } case "pendingOutFriends": do {
                            title = "Friend request"
                            body = " has sent you a friend request"
                        } case "pendingFollows": do {
                            title = "Follow request"
                            body = " has sent you a follow request"
                        } default: do {}
                        }
                    } else {
                        switch selfConnection {
                        case "pendingFollowers": do {
                            title = "Follow request denied"
                            body = " has denied your follow request"
                        } case "pendingInFriends": do {
                            title = "Friend request denied"
                            body = " has denied your friend request"
                        } default: do {}
                        }
                    }
                    if title != "" {
                        PushNotificationSender().push(emails: [other], title: title, body: "\(String(describing: givenName)) \(String(describing: familyName)) \(body)")
                    }
                }
            })
        }
    }
}

struct NewFollowView_Previews: PreviewProvider {
    static var previews: some View {
        FollowsView()
    }
}

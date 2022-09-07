//
//  BroadcastView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct BroadcastView: View, Identifiable {
    var id: Int
    
    var broadcast: Broadcast
    var data: [String: Any] //user data
    @State var expand: Bool = false
    @State var from: BroadcastsView? = nil
    @State var read: Bool = true
    
    var body: some View {
        Button {
            expand = true
        } label: {
            VStack(alignment: .leading) {
                HStack(spacing:16) {
                    Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: data["profilePicUrl"] as? String ?? constants.defaultUrlString)!))!)
                        .resizable()
                        .clipped()
                        .frame(width: 32, height: 32)
                        .cornerRadius(16)
    //                    .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.theme.foreground, lineWidth: 1))
//                        .padding(.leading)
    //                        .frame(width: 32, height: 32))
                    VStack(alignment:.leading){
                        Text("\(data["givenName"] as? String ?? "Anon") \(data["familyName"] as? String ?? "Anon")")
                            .font(.system(size:16, weight:.bold))
                            .foregroundColor(Color.theme.foreground)
                        Text(utils.timeSince(timestamp:broadcast.data["timestamp"] as? Timestamp ?? Timestamp()))
                            .font(.system(size:14))
                            .foregroundColor(Color.theme.accent)
                    }
                    Spacer()
                    
                    if !read {
                        Circle()
                            .foregroundColor(.red)
                            .frame(width:12, height:12)
                    }
                            
//                        Text()
//                            .font(.system(size:14, weight:.semibold))
//                            .foregroundColor(Color.theme.foreground)
                    
//                    .padding(.trailing)
                }
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 8)
                
                switch utils.broadcastType(broadcast: broadcast) {
                case "announcement":
                    Text(broadcast.data["name"] as? String ?? "Unknown Content")
                        .font(.system(size:16, weight:.regular))
                        .foregroundColor(Color.theme.foreground)
                        .padding([.leading, .trailing, .bottom])
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                case "event":
                    Text("Event: \(broadcast.data["name"] as? String ?? "Unknown Content")")
                        .font(.system(size:24, weight:.bold))
                        .foregroundColor(Color.theme.foreground)
                        .padding([.leading, .trailing, .bottom])
                        .lineLimit(1)
                default:
                    Text("Unrecognized broadcast type")
                        .font(.system(size:24, weight:.bold))
                        .foregroundColor(Color.red)
                        .padding([.leading, .trailing, .bottom])
                }
                
                    
                
                Divider()
//                    .padding(.bottom, 8)
            }
//            .frame(alignment: .leading)
        }
        .fullScreenCover(isPresented: $expand) {
//            Button {
//                expand = false
//            } label: {
//                Text("< Back")
//            }
            
            ExpandedBroadcastView(id: id, broadcast: broadcast, from: self)
                .onAppear(perform: updateRead)
                .onDisappear {
                    updateRead()
                    isRead()
                }
        }
        .onAppear(perform: isRead)
    }
    
    private func isRead() {
        if broadcast.data["email"] as? String ?? "" != FirebaseManager.shared.auth.currentUser?.email ?? "" {
            FirebaseManager.shared.firestore
                .collection("broadcasts")
                .document(broadcast.data["email"] as? String ?? "")
                .collection("sent")
                .document("\(broadcast.data["id"] as? Int ?? -1)")
                .collection("privateChannels")
                .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                .getDocument { snapshot, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    read = snapshot?.data()?["commentsReadByReceiver"] as? Bool ?? false && snapshot?.data()?["read"] as? Bool ?? false
                }
        } else {
            read = true
            FirebaseManager.shared.firestore.collection("connections").document(FirebaseManager.shared.auth.currentUser?.email ?? "").getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user: ", error)
                    return
                }
                let followers = snapshot?.data()?["followers"] as? [String] ?? []
                for follower in followers {
                    FirebaseManager.shared.firestore
                        .collection("broadcasts")
                        .document(broadcast.data["email"] as? String ?? "")
                        .collection("sent")
                        .document("\(broadcast.data["id"] as? Int ?? -1)")
                        .collection("privateChannels")
                        .document(follower)
                        .getDocument { snapshot, error in
                            if let error = error {
                                print(error)
                                return
                            }
                            read = snapshot?.data()?["commentsReadBySender"] as? Bool ?? false && read
                        }
                }
            }
        }
    }
    
    private func updateRead() {
        if broadcast.data["email"] as? String ?? "" != FirebaseManager.shared.auth.currentUser?.email ?? "" {
            FirebaseManager.shared.firestore
                .collection("broadcasts")
                .document(broadcast.data["email"] as? String ?? "")
                .collection("sent")
                .document("\(broadcast.data["id"] as? Int ?? -1)")
                .collection("privateChannels")
                .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                .getDocument { snapshot, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    read = snapshot?.data()?["commentsReadByReceiver"] as? Bool ?? false
                }
            FirebaseManager.shared.firestore
                .collection("broadcasts")
                .document(broadcast.data["email"] as? String ?? "")
                .collection("sent")
                .document("\(broadcast.data["id"] as? Int ?? -1)")
                .collection("privateChannels")
                .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                .setData(["read": true], merge: true)
        } else {
            read = true
        }
    }
}

struct BroadcastView_Previews: PreviewProvider {
    static var displayEvent: Bool = false
    static var previews: some View {
        if displayEvent {
            BroadcastView(id: -1, broadcast: Broadcast(data: ["email": "", "name": "testEvent", "id": -1, "timestamp": Timestamp(), "description": "testEvent description goes something like this. blah blah blah blah blah", "startDate": Date(), "endDate": Date(), "location": "testLocation"]), data: ["email": "email", "givenName": "first", "familyName": "last", "profilePicUrl": constants.defaultUrlString]).preferredColorScheme(.dark).background(Color.theme.background)
        } else {
            BroadcastView(id: -1, broadcast: Broadcast(data: ["email": "", "name": "testAnnouncement goes something like this. blah blah blah blah blah", "id": -1, "timestamp": Timestamp()]), data: ["email": "email", "givenName": "first", "familyName": "last", "profilePicUrl": constants.defaultUrlString]).preferredColorScheme(.dark)
        }
    }
}

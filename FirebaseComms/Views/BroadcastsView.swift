//
//  AnnouncementsView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/6/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

class BroadcastsViewModel: ObservableObject {
    init() {
        fetchCurrentUser()
    }
    
    @Published var dat = ""
    @AppStorage("email") var email : String!
    @AppStorage("givenName") var givenName : String!
    @AppStorage("familyName") var familyName : String!
    @AppStorage("profilePicUrl") var profilePicUrl : URL!
//    @AppStorage("log_Status") var log_Status = false

    private func fetchCurrentUser() {
        guard let email = FirebaseManager.shared.auth.currentUser?.email else {return}
        
        FirebaseManager.shared.firestore.collection("users").document(email).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            guard let data = snapshot?.data() else {
//                self.dat = "No data"
                return
            }
//            let uid = data["uid"] as? String ?? ""
            self.email = data["email"] as? String ?? ""
            self.givenName = data["givenName"] as? String ?? ""
            self.familyName = data["familyName"] as? String ?? ""
            self.profilePicUrl = URL(string: data["profilePicUrl"] as? String ?? "")
//            let user = User(uid: uid)
            self.dat = "Data: \(data.description)"
        }
        
    }
}

struct BroadcastsView: View {
    
    @ObservedObject private var vm = BroadcastsViewModel()
    @AppStorage("log_Status") var log_Status = true
    
    
//    private func storeUserInformation(email: String, givenName: String, familyName: String, profilePicUrl: URL) {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
//        let userData = ["uid": uid, "email": email, "givenName": givenName, "familyName": familyName, "profilePicUrl": profilePicUrl.absoluteString]
//        FirebaseManager.shared.firestore.collection("users")
//            .document(uid).setData(userData) { err in
//                if let err = err {
//                    print(err)
//                    return
//                }
//            }
//    }
    
    @AppStorage("email") var email : String?
    @AppStorage("givenName") var givenName : String?
    @AppStorage("familyName") var familyName : String?
    @AppStorage("profilePicUrl") var profilePicUrl : URL?
//    @State var isEditing: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
//                Button("Logout"){
//                    GIDSignIn.sharedInstance.signOut()
//                    try? FirebaseManager.shared.auth.signOut()
//                    withAnimation {
//                        log_Status = false
//                    }
//                }
//                Text("User data: \(vm.dat)")
                HStack(spacing:16) {
                    Image(uiImage: UIImage(data: try! Data(contentsOf: profilePicUrl ?? Constants.defaultUrl))!)
                        .resizable()
                        .clipped()
                        .cornerRadius(16)
                        .frame(width: 32, height: 32)
                        
                    Text("\(givenName ?? "First") \(familyName ?? "Last")")
                        .font(.system(size:24, weight:.bold))
                    
                    Spacer()
                    
                    Button {
                        view_Sent = !view_Sent
                    } label: {
                        Text(view_Sent ? "Sent" : "Received")
                    }
                }
                .padding()
                
                if view_Sent {
                    sent
                } else {
                    received
                }
            }
            
        }
//        .onAppear(perform: {sentBroadcasts = ""})
    }
    
    @State var view_Sent = false
    @AppStorage("sentBroadcasts") var sentBroadcasts: String?
    @State var loadedSentBroadcasts: [Broadcast] = []
    
    private func getSentBroadcasts() -> [Broadcast] {
//        sentBroadcasts = ""
        let arr: [String] = sentBroadcasts?.components(separatedBy: Constants.seperator) ?? []
        var loadedSentBroadcasts: [Broadcast] = []
        for str in arr {
            if !str.isEmpty {
                loadedSentBroadcasts.append(Broadcast(str: str))
            }
        }
        loadedSentBroadcasts.sort (by: {
            $0.data["id"] as? Int ?? -1 > $1.data["id"] as? Int ?? -1
        })
        return loadedSentBroadcasts
    }
    
    private func getUserData(email: String, completion: @escaping ([String:Any]) -> ()){
        FirebaseManager.shared.firestore.collection("users").document(email).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            completion(data)
        }
   }
    
    @State var broadcastViews: [BroadcastView] = []
    func setBroadcastViews() {
        loadedSentBroadcasts = getSentBroadcasts()
        broadcastViews = []
        var viewId = 0
        for broadcast in loadedSentBroadcasts {
            getUserData(email: broadcast.data["email"] as! String) { data in
                broadcastViews.append(BroadcastView(id: viewId, broadcast: broadcast, data: data, from: self))
                viewId += 1
            }
//            FirebaseManager.shared.firestore.collection("uids").document(broadcast.data["email"] as! String).getDocument { snapshot, error in
//                if let error = error {
//                    print("Failed to fetch current user: ", error)
//                    return
//                }
//                guard let data = snapshot?.data() else { return }
//
//            }
        }
//        print("done")
    }
    
    private var sent: some View {
        ScrollView {
            if broadcastViews.count > 0 {
                ForEach(broadcastViews) { broadcastView in
                    broadcastView
                }
            } else {
                Text("No sent announcements or events")
                    .foregroundColor(Color.gray)
                    .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: setBroadcastViews)
    }
    
    @AppStorage("follows") var follows: String?
    @State var loadedFollows: [String] = []
    func storeFollow(email: String) {
        follows = "\(email)~\(follows ?? "")"
    }
    
    private func getFollows() -> [String] {
        if loadedFollows.count > 0 {
            return loadedFollows
        }
//        print("start")
        let arr: [String] = follows?.components(separatedBy: Constants.seperator) ?? []
//        print("arr: ", arr)
        var loadedFollows: [String] = []
        for str in arr {
            if !str.isEmpty {
                loadedFollows.append(str)
            }
        }
        self.loadedFollows = loadedFollows
        return loadedFollows
    }
    
//completion: @escaping ([String:Any]) -> ()
    @AppStorage("receivedBroadcasts") var receivedBroadcasts: String?
    @State var loadedReceivedBroadcasts: [Broadcast] = []
    @State var inGroup = false
    private let group = DispatchGroup()
//    private var firestoreListener: ListenerRegistration?
    func updateReceivedBroadcasts() {
//        firestoreListener?.remove()
        let loadedFollows = getFollows()
        inGroup = true
        for follow in loadedFollows {
            group.enter()
            let collection = FirebaseManager.shared.firestore
                .collection("broadcasts")
                .document(follow)
                .collection("sent")
//                        .order(by: "timestamp")
            collection.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                var n = querySnapshot?.documentChanges.count ?? 0
                querySnapshot?.documentChanges.forEach({ change in
//                        group.enter()
                    let data = change.document.data()
                    if change.type == .added {
                        loadedReceivedBroadcasts.append(Broadcast(data: data))
                    } else if change.type == .modified {
                        changeBroadcast(broadcast: Broadcast(data: data))
                    } else if change.type == .removed {
                        changeBroadcast(broadcast: Broadcast(data: ["id": data["id"] as? Int ?? -1]))
                    }
//                    print("change occured \(data)")
                    n -= 1
                    print(n)
                    if (n == 0) {
                        if inGroup { group.leave() }
                    }
//                        group.leave()
                })
//                if inGroup { group.leave() }
            }
//            group.leave()
        }
        receivedBroadcasts = ""
        for broadcast in loadedReceivedBroadcasts {
            storeBroadcast(broadcast: broadcast)
        }
    }
    
    func getBroadcasts() {
//        let arr: [String] = receivedBroadcasts?.components(separatedBy: Constants.seperator) ?? []
        loadedReceivedBroadcasts = []
//        for str in arr {
//            if !str.isEmpty {
//                loadedReceivedBroadcasts.append(Broadcast(str: str))
//            }
//        }
        updateReceivedBroadcasts()
//        print(loadedReceivedBroadcasts.count)
    }
    
    private func storeBroadcast(broadcast: Broadcast) {
        receivedBroadcasts = "\(broadcast.toString())~\(receivedBroadcasts ?? "")"
    }
    
    private func changeBroadcast(broadcast: Broadcast) {
        for i in 0..<loadedReceivedBroadcasts.count {
            if loadedReceivedBroadcasts[i].data["id"] as? Int ?? -1 == broadcast.data["id"] as? Int ?? -1 {
                if broadcast.data.count != 1 {
                    loadedReceivedBroadcasts[i] = broadcast
                } else {
                    loadedReceivedBroadcasts.remove(at: i)
                }
                return
            }
        }
    }
    
    private let viewGroup = DispatchGroup()
    func receivedBroadcastViews() {
        getBroadcasts()
//        print(loadedReceivedBroadcasts.count)
        group.notify(queue: .main) {
            inGroup = false
//            loadedReceivedBroadcasts.sort (by: {
//                $0.data["id"] as? Int ?? -1 > $1.data["id"] as? Int ?? -1
//            })
//            print(loadedReceivedBroadcasts.description)
            var viewId = 0
            var broadcastViews: [BroadcastView] = []
            for broadcast in loadedReceivedBroadcasts {
                viewGroup.enter()
                getUserData(email: broadcast.data["email"] as! String) { data in
                    broadcastViews.append(BroadcastView(id: viewId, broadcast: broadcast, data: data, from: self))
                    viewId += 1
//                        print(broadcast.data["id"] as? Int ?? -1)
                    viewGroup.leave()
                }
//                print(broadcast.data["id"] as? Int ?? -1)
//                FirebaseManager.shared.firestore.collection("uids").document(broadcast.data["email"] as! String).getDocument { snapshot, error in
//                    if let error = error {
//                        print("Failed to fetch current user: ", error)
//                        return
//                    }
//                    guard let data = snapshot?.data() else { return }
//
//                }
            }
            viewGroup.notify(queue: .main) {
                broadcastViews.sort (by: {
                    $0.broadcast.data["id"] as? Int ?? -1 > $1.broadcast.data["id"] as? Int ?? -1
                })
                self.broadcastViews = broadcastViews
            }

        }
    }
    
    @State var expand: Bool = false
    
    private var received: some View {
        ScrollView {
//            Text("\(loadedReceivedBroadcasts.count)")
            if broadcastViews.count > 0 {
                ForEach(broadcastViews) { broadcastView in
                    broadcastView
                }
            } else {
                Text("No received announcements or events")
                    .foregroundColor(Color.gray)
                    .padding()
            }
        }
        .overlay(
            Button {
                expand = true
            } label: {
                HStack{
                    Spacer()
                    Text("+ New Follow")
                        .font(.system(size:16, weight: .bold))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .shadow(radius:15)
            }, alignment: .bottom)
        .navigationBarHidden(true)
        .onAppear(perform: receivedBroadcastViews)
        .fullScreenCover(isPresented: $expand) {
            Button {
                expand = false
            } label: {
                Text("Back")
            }
            NewFollowView(from: self)
        }
    }
}

struct AnnouncementsView_Previews: PreviewProvider {
    static var previews: some View {
        BroadcastsView()
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

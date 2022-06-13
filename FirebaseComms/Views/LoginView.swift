//
//  LoginPage.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/6/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

struct LoginView: View {
    
    @State var isLoading: Bool = false
    
    @AppStorage("log_Status") var log_Status = false
    
    var body: some View {
        Button {
            handleLogin()
        } label: {
            HStack(spacing: 15) {
                Image("google")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                
                Text("Login with Google")
                    .font(.title3)
                    .fontWeight(.medium)
                    .kerning(1.1)
            }
//            .foregroundColor(Color("Blue"))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .strokeBorder(.blue)
                    .frame(width:300)
            )
        }
        .overlay(
            ZStack{
                if isLoading{
                    Color.black
                        .opacity(0.25)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(.white)
                        .cornerRadius(10)
                }
            }
        )
    }
    
    @AppStorage("email") var email = ""
    @AppStorage("givenName") var givenName = ""
    @AppStorage("familyName") var familyName = ""
    @AppStorage("profilePicUrl") var profilePicUrl = Constants.defaultUrl
    
    func handleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        
        isLoading = true
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()) { [self] user, err in
            if let error = err {
                isLoading = false
                print(error.localizedDescription)
                return
              }

              guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
              else {
                  isLoading = false
                return
              }

            email = user?.profile?.email ?? ""

            givenName = user?.profile?.givenName ?? ""
            familyName = user?.profile?.familyName ?? ""

            profilePicUrl = user?.profile?.imageURL(withDimension: 320) ?? Constants.defaultUrl
            
              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: authentication.accessToken)
            
            FirebaseManager.shared.auth.signIn(with: credential) { result, err in
                
                guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
                    if let error = error {
                        print("Failed to fetch current user: ", error)
                        return
                    }
                    guard let data = snapshot?.data() else {
                        storeUserInformation(email: email, givenName: givenName, familyName: familyName, profilePicUrl: profilePicUrl)
                        return
                    }
                }
                isLoading = false
                
                if let error = err {
                    print(error.localizedDescription)
                    return
                  }
                guard let user = result?.user else{
                    return
                }
//                print(user.displayName ?? "Success!")
                
                FirebaseManager.shared.firestore.collection("uids")
                    .document(email).setData(["uid": user.uid]) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                    }
                
                loadFollows(uid: uid)
                loadSentBroadcasts(uid: uid)
                
                withAnimation{
                    log_Status = true
                }
            }
            print(log_Status)
        }
        
    }
    
    private func storeUserInformation(email: String, givenName: String, familyName: String, profilePicUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["uid": uid, "email": email, "givenName": givenName, "familyName": familyName, "profilePicUrl": profilePicUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    return
                }
            }
    }
    
    @AppStorage("receivedBroadcasts") var receivedBroadcasts: String?
    func loadReceivedBroadcasts() {
        receivedBroadcasts = ""
        for follow in loadedFollows {
            FirebaseManager.shared.firestore
                .collection("broadcasts")
                .document(follow)
                .collection("sent")
                .getDocuments { snapshot, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    let documents: [QueryDocumentSnapshot] = snapshot?.documents ?? []
                    
                    for document in documents {
                        receivedBroadcasts = "\(Broadcast(data: document.data()).toString())~\(receivedBroadcasts ?? "")"
                    }
                }
        }
    }
    
    @AppStorage("follows") var follows: String?
    @State var loadedFollows: [String] = []
    func loadFollows(uid: String) {
        follows = ""
        FirebaseManager.shared.firestore.collection("follows").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            guard let data = snapshot?.data() else {return}
            loadedFollows = data["follows"] as? [String] ?? []
            for follow in loadedFollows {
                follows = "\(follow)~\(follows ?? "")"
            }
            loadReceivedBroadcasts()
        }
    }
    
    @AppStorage("sentBroadcasts") var sentBroadcasts: String?
    func loadSentBroadcasts(uid: String) {
        sentBroadcasts = ""
        FirebaseManager.shared.firestore
            .collection("broadcasts")
            .document(uid)
            .collection("sent")
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                let documents: [QueryDocumentSnapshot] = snapshot?.documents ?? []
                
                for document in documents {
                    sentBroadcasts = "\(Broadcast(data: document.data()).toString())~\(sentBroadcasts ?? "")"
                }
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View{
    func getRect() -> CGRect{
        return UIScreen.main.bounds
    }
    
    func getRootViewController() -> UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else{
            return .init()
        }
        
        return root
    }
}

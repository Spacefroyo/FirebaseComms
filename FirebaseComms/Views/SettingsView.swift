//
//  SettingsView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/7/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct SettingsView: View {
    
    
    
    //Add profilePicUrl changer here!!!!!
    
    @AppStorage("email") var email: String!
    @AppStorage("givenName") var givenName: String!
    @AppStorage("familyName") var familyName: String!
    @AppStorage("profilePicUrl") var profilePicUrl: URL!
    @AppStorage("log_Status") var log_Status = true
    @AppStorage("view_Id") var view_Id = 1
    @State var firstName = "First Name"
    @State var lastName = "Last Name"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                ScrollView{
                    Group{
                        TextField("First Name", text: $firstName)
                            .font(.system(size:24))
                        
                        TextField("Last Name", text: $lastName)
                            .font(.system(size:24))
                    }
                    .padding()
                    .background(Color.theme.accent)
                    .foregroundColor(Color.theme.foreground)
                    .cornerRadius(15)
                    
                    
                    
                    Button {
                        givenName = firstName
                        familyName = lastName
                        storeUserInformation(givenName: givenName, familyName: familyName, profilePicUrl: profilePicUrl)
                    } label: {
                        Text("Save Changes")
                            .padding()
                            .foregroundColor(Color.theme.foreground)
                    }
                    
                    Button{
                        GIDSignIn.sharedInstance.signOut()
                        try? FirebaseManager.shared.auth.signOut()
                        withAnimation {
                            log_Status = false
                            view_Id = 0
                        }
                    } label: {
                        Text("Logout")
                            .foregroundColor(Color.red)
                    }
                }
                .padding()
                .frame(alignment: .top)
                .onAppear(perform: {
                    firstName = givenName
                    lastName = familyName
                })
                .navigationTitle("Settings")
            }
        }
    }
    
    private func storeUserInformation(givenName: String, familyName: String, profilePicUrl: URL) {
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        let userData = ["email": email, "givenName": givenName, "familyName": familyName, "profilePicUrl": profilePicUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(email).setData(userData) { err in
                if let err = err {
                    print(err)
                    return
                }
            }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}

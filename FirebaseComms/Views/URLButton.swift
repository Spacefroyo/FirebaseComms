//
//  URLButton.swift
//  FirebaseComms
//
//  Created by Peter Gao on 9/6/22.
//

import SwiftUI

struct URLButton<Content: View>: View {
    // What to display on the buton/ the link
    var content: Content
    var url: String
    
    @AppStorage("LinkDestination") var linkDestination = 0
    
    @State var showSafariView = false
    
    // Use this to explicitly open the url in Safari. With iOS 14 the user can change the default browser.
    var safariURL: String {
        if url.contains("https://") {
            return url.replacingOccurrences(of: "https://", with: "x-web-search://")
        } else if url.contains("http://") {
            return url.replacingOccurrences(of: "http://", with: "x-web-search://")
        } else {
            return "x-web-search://\(url)"
        }
    }
    
    @ViewBuilder var body: some View {
        switch linkDestination {
        case 0:
            // A button, that toggles a full screen cover with a SFSafariViewController
            Button(action: {
                showSafariView = true
            }) {
                content.fullScreenCover(isPresented: $showSafariView) {
                    SafariView(url: URL(string: url)!).edgesIgnoringSafeArea(.all)
                }
            }
            .disabled(!UIApplication.shared.canOpenURL(URL(string: url) ?? constants.defaultUrl))
            
        case 1:
            // Opens the URL in Safari
            Link(destination: URL(string: safariURL)!) {
                content
            }
        default:
            content
        }
    }
}

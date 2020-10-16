//
//  ContentView.swift
//  WebPKitExample-macOS
//
//  Created by Tim Oliver on 16/10/20.
//

import SwiftUI

struct ContentView: View {
    var webpLogo: NSImage {
        return NSImage.webpNamed("WebPKitLogo")!
    }

    var body: some View {
        Image(nsImage: webpLogo)
            .resizable()
            .scaledToFit()
            .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

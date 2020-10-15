//
//  ContentView.swift
//  WebPKitExample-macOS
//
//  Created by Tim Oliver on 16/10/20.
//

import SwiftUI

struct ContentView: View {
    var webpLogo: NSImage {
        let url = Bundle.main.url(forResource: "WebPKitLogo",
                                  withExtension: "webp")!
        return NSImage(contentsOfWebPFile: url)!
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

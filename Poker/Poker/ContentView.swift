//
//  ContentView.swift
//  Poker
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var appState: AppState = AppState()

    var body: some View {
        GameView()
            .padding(10)
            .preferredColorScheme(.light)
            .environmentObject(appState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

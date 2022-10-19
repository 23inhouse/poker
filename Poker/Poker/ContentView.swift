//
//  ContentView.swift
//  Poker
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView()
            .padding(10.000)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

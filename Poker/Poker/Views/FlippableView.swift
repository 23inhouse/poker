//
//  FlippableView.swift
//  Poker
//
//  Created by Benjamin Lewis on 9/11/2022.
//

import SwiftUI

struct FlippableView<FrontView: View, BackView: View>: View {
    var isFlipped: Bool = false

    @ViewBuilder let frontView: () -> FrontView
    @ViewBuilder let backView: () -> BackView

    @State private var isShowingAnimation = false

    @State private var backDegree: CGFloat = -89.999
    @State private var frontDegree: CGFloat = 0

    @State private var isShowingFront: Bool = true

    var frontOpacity: CGFloat { isShowingFront ? 1 : 0 }
    var backOpacity: CGFloat { !isShowingFront ? 1 : 0 }

    let durationAndDelay: CGFloat = 0.075

    var body: some View {
        ZStack() {
            frontView()
                .opacity(frontOpacity)
                .rotation3DEffect(Angle(degrees: frontDegree), axis: (x: 0, y: 1, z: 0))
                .animation(!isShowingAnimation ? .none : .linear(duration: durationAndDelay), value: frontDegree)
            backView()
                .opacity(backOpacity)
                .rotation3DEffect(Angle(degrees: backDegree), axis: (x: 0, y: 1, z: 0))
                .animation(!isShowingAnimation ? .none : .linear(duration: durationAndDelay), value: backDegree)
        }
        .onChange(of: isFlipped) { isFlipped in
            flip(isFlipped)
        }
        .onAppear {
            guard isFlipped else { return }
            backDegree = 0
            frontDegree = 89.999
            isShowingFront = false
        }
    }

    private func flip(_ isFlipped: Bool) {
        isShowingAnimation = true
        if !isFlipped {
            self.backDegree = -89.999
            DispatchQueue.main.asyncAfter(deadline: .now() + durationAndDelay) {
                self.frontDegree = 0
                self.isShowingFront = true
            }
        } else {
            self.frontDegree = 89.999
            DispatchQueue.main.asyncAfter(deadline: .now() + durationAndDelay) {
                self.backDegree = 0
                self.isShowingFront = false
            }
        }
    }
}

struct FlippableView_Previews: PreviewProvider {
    static var frontView: some View {
        Text("Front View")
            .padding()
            .border(.blue)
    }
    static var backView: some View {
        Text("Back View")
            .padding()
            .border(.red)
    }

    static var previews: some View {
        VStack {
            FlippableView(isFlipped: false, frontView: { frontView }, backView: { backView } )
            Divider()
            FlippableView(isFlipped: true, frontView: { frontView }, backView: { backView } )
        }
    }
}

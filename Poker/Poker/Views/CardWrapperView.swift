//
//  CardWrapperView.swift
//  Poker
//
//  Created by Benjamin Lewis on 9/11/2022.
//

import SwiftUI

struct CardWrapperView<Content: View>: View {
    var width: CGFloat = 100
    var color: Color = .secondary
    var opacity: CGFloat = 1
    var offset: CGFloat = 0

    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .containerShape(Rectangle())
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(width: width)
            .frame(height: width * 1.5)
            .padding(.horizontal, width * 0.1)
            .padding(.vertical, width * 0.1)
            .background(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(color, lineWidth: 1.4)
                    .padding(1)
            )
            .opacity(opacity)
            .animation(.none, value: opacity)
            .offset(y: offset)
            .animation(.default, value: offset)

    }
}
struct FlippableCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardWrapperView(width: 40) {
                Text("CardView")
            }
            CardWrapperView(width: 80) {
                Text("CardView")
            }
            CardWrapperView(width: 160) {
                Text("CardView")
            }
        }
    }
}

//
//  CardView.swift
//  Poker
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import SwiftUI

struct CardView: View {
    let card: Card?
    var isFaceUp: Bool
    var isInBestHand: Bool = false

    static let width: CGFloat = UIScreen.main.bounds.size.width * 0.122

    var body: some View {
        ZStack {
            if let card = card {
                FlipView(isFlipped: !isFaceUp) {
                    CardFaceUpView(card: card, isInBestHand: isInBestHand)
                } backView: {
                    CardFaceDownView(isInBestHand: isInBestHand)
                }
            } else {
                CardPlaceHolderView()
            }
        }
    }
}

struct CardFaceUpView: View {
    @EnvironmentObject var game: Game

    let card: Card
    var isInBestHand: Bool = false

    var color: Color {
        return [.clubs, .spades].contains(card.suit) ? .black : .red
    }

    var position: RiverPosition { game.riverPosition }

    var opacity: CGFloat {
        guard position == .over else { return 1 }
        return isInBestHand ? 1 : 0.25
    }

    var offset: CGFloat {
        guard position == .over else { return 0 }
        return isInBestHand ? -5 : 5
    }
    var body: some View {
        CardWrapperView(color: color, opacity: opacity, offset: offset) {
            ZStack {
                Color.white
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "suit.\(card.suit.description).fill")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: CardView.width * 0.34)
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    Text(card.rank.rawValue)
                        .fontWeight(.bold)
                        .font(.system(size: 500))
                        .minimumScaleFactor(0.01)
                        .frame(height: CardView.width)
                        .padding(.bottom, CardView.width * 0.1)
                }
            }
        }
    }
}

struct CardFaceDownView: View {
    @EnvironmentObject var game: Game

    var isInBestHand: Bool = false

    var color: Color = .secondary
    var position: RiverPosition { game.riverPosition }

    var opacity: CGFloat {
        guard position == .over else { return 1 }
        return isInBestHand ? 1 : 0.25
    }

    var offset: CGFloat = 0

    var body: some View {
        CardWrapperView(color: color, opacity: opacity, offset: offset) {
            ZStack {
                Text("💩")
                    .fontWeight(.bold)
                    .font(.system(size: 500))
                    .minimumScaleFactor(0.01)
                    .frame(height: CardView.width * 0.68)
                    .opacity(0.21625)
                Color.brown.opacity(0.5)
                    .cornerRadius(5)
            }
        }
    }
}

struct CardPlaceHolderView: View {
    var color: Color = .secondary
    var opacity: CGFloat = 0.5
    var offset: CGFloat = 0

    var body: some View {
        CardWrapperView(color: color, opacity: opacity, offset: offset) {
            ZStack {
                Text("💩")
                    .fontWeight(.bold)
                    .font(.system(size: 500))
                    .minimumScaleFactor(0.01)
                    .frame(height: CardView.width)
                    .opacity(0.025)
            }
        }
    }
}

struct CardWrapperView<Content: View>: View {
    var color: Color = .secondary
    var opacity: CGFloat = 1
    var offset: CGFloat = 0

    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .containerShape(Rectangle())
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(width: CardView.width)
            .frame(height: CardView.width * 1.5)
            .padding(.horizontal, CardView.width * 0.1)
            .padding(.vertical, CardView.width * 0.1)
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


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                CardView(card: nil, isFaceUp: true)
                CardView(card: nil, isFaceUp: true)
                CardView(card: nil, isFaceUp: false)

            }
            HStack {
                CardView(card: Card(rank: .ten, suit: .diamonds), isFaceUp: true)
                CardView(card: Card(), isFaceUp: true)
                CardView(card: Card(), isFaceUp: false)

            }
            HStack {
                CardView(card: Card(), isFaceUp: true)
                CardView(card: Card(), isFaceUp: false)
                CardView(card: Card(), isFaceUp: true)

            }
            HStack {
                CardView(card: Card(), isFaceUp: false)
                CardView(card: Card(), isFaceUp: true)
                CardView(card: Card(), isFaceUp: true)

            }
        }
        .padding(10)
        .environmentObject(Game())
    }
}

struct FlipView<FrontView: View, BackView: View>: View {
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

//
//  CardView.swift
//  Poker
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import SwiftUI

extension CardView {
    static let width: CGFloat = UIScreen.main.bounds.size.width * 0.122
}

struct CardView: View {
    @EnvironmentObject var appState: AppState

    let card: Card?
    let isFaceUp: Bool
    var isReavelable: Bool = false
    var isInBestHand: Bool = false

    var cardVM: CardViewModel {
        CardViewModel(card: card, isRevealable: isReavelable, isInBestHand: isInBestHand, isPoopMode: appState.isPoopMode)
    }

    var body: some View {
        ZStack {
            if card != nil {
                FlippableView(isFlipped: !isFaceUp) {
                    CardFaceUpView(cardVM: cardVM)
                } backView: {
                    CardFaceDownView(cardVM: cardVM)
                }
            } else {
                CardPlaceHolderView()
            }
        }
    }
}

extension CardView {
    struct CardFaceUpView: View {
        @EnvironmentObject var appState: AppState

        let cardVM: CardViewModel

        var body: some View {
            CardWrapperView(width: CardView.width, color: cardVM.color, opacity: cardVM.opacity, offset: cardVM.offset) {
                ZStack {
                    Color.white
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: cardVM.suitImageSystemName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: CardView.width * 0.34)
                            Spacer()
                        }
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        Text(cardVM.rankDescription)
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
        @EnvironmentObject var appState: AppState

        let cardVM: CardViewModel

        var color: Color = .secondary
        var offset: CGFloat = 0

        var body: some View {
            CardWrapperView(width: CardView.width, color: color, opacity: cardVM.opacity, offset: offset) {
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
            CardWrapperView(width: CardView.width, color: color, opacity: opacity, offset: offset) {
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
}

struct CardView_Previews: PreviewProvider {
    static let appState = AppState()

    static var previews: some View {
        VStack {
            HStack {
                CardView(card: nil, isFaceUp: true)
                CardView(card: nil, isFaceUp: true)
                CardView(card: nil, isFaceUp: false)

            }
            Divider()
            Text("isFaceUp = false")
            HStack {
                CardView(card: Card(), isFaceUp: false, isReavelable: false, isInBestHand: true)
                CardView(card: Card(), isFaceUp: false, isReavelable: true, isInBestHand: true)
                CardView(card: Card(), isFaceUp: false, isReavelable: true, isInBestHand: false)

            }
            Divider()
            Text("isFaceUp = .random()")
            HStack {
                CardView(card: Card(rank: .ten, suit: .diamonds), isFaceUp: true)
                CardView(card: Card(), isFaceUp: true)
                CardView(card: Card(), isFaceUp: false)

            }
            Divider()
            Text("isRevealable = true")
            HStack {
                CardView(card: Card(), isFaceUp: false, isReavelable: true, isInBestHand: true)
                CardView(card: Card(), isFaceUp: true, isReavelable: true, isInBestHand: true)
                CardView(card: Card(), isFaceUp: true, isReavelable: true, isInBestHand: false)

            }
        }
        .padding(10)
        .environmentObject(appState)
    }
}

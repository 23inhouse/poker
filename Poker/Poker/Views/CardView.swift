//
//  CardView.swift
//  Poker
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import SwiftUI

struct CardView: View {
    let card: Card
    var faceUp: Bool = true

    var body: some View {
        let color: Color = [.clubs, .spades].contains(card.suit) ? .black : .red

        GeometryReader { geo in
            ZStack {
                if true || faceUp {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "suit.\(card.suit.description).fill")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: geo.size.width * 0.34)
                                .frame(width: geo.size.width * 0.34)
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
                            .frame(height: geo.size.width * 1)
                    }
                } else {
                    Color.secondary
                        .cornerRadius(5)
                }
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(minHeight: geo.size.width * 1.1)
            .frame(maxHeight: geo.size.width * 1.4)
            .padding(geo.size.width / 10)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(faceUp ? color : .secondary, lineWidth: 1.4)
            )
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                CardView(card: Card(rank: .ten, suit: .diamonds))
                CardView(card: Card())
                CardView(card: Card(), faceUp: false)

            }
            HStack {
                CardView(card: Card())
                CardView(card: Card(), faceUp: false)
                CardView(card: Card())

            }
            HStack {
                CardView(card: Card(), faceUp: false)
                CardView(card: Card())
                CardView(card: Card())

            }
        }
        .padding(10)
    }
}

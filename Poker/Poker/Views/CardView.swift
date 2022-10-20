//
//  CardView.swift
//  Poker
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import SwiftUI

struct CardView: View {
    let card: Card
    @Binding var faceUp: Bool

    @State var isFaceUp: Bool = true

    var up: Bool {
        faceUp
    }

    var body: some View {
        let color: Color = [.clubs, .spades].contains(card.suit) ? .black : .red

        GeometryReader { geo in
            ZStack {
                Color.white
                if isFaceUp {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "suit.\(card.suit.description).fill")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: geo.size.width * 0.34)
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
                            .frame(height: geo.size.width)
                    }
                } else {
                    Text("💩")
                        .fontWeight(.bold)
                        .font(.system(size: 500))
                        .minimumScaleFactor(0.01)
                        .frame(height: geo.size.width * 0.68)
                        .opacity(0.21625)
                    Color.secondary
                        .cornerRadius(5)
                        .onTapGesture {
                            isFaceUp.toggle()
                        }
                }
            }
            .onAppear {
                isFaceUp = faceUp
            }
            .onChange(of: up, perform: { newValue in
                isFaceUp = newValue
            })
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(minHeight: geo.size.width * 1.1)
            .frame(maxHeight: geo.size.width * 1.4)
            .padding(geo.size.width / 10)
            .background(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(faceUp ? color : .secondary, lineWidth: 1.4)
                    .padding(1)
            )
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                CardView(card: Card(rank: .ten, suit: .diamonds), faceUp: .constant(true))
                CardView(card: Card(), faceUp: .constant(true))
                CardView(card: Card(), faceUp: .constant(false))

            }
            HStack {
                CardView(card: Card(), faceUp: .constant(true))
                CardView(card: Card(), faceUp: .constant(false))
                CardView(card: Card(), faceUp: .constant(true))

            }
            HStack {
                CardView(card: Card(), faceUp: .constant(false))
                CardView(card: Card(), faceUp: .constant(true))
                CardView(card: Card(), faceUp: .constant(true))

            }
        }
        .padding(10)
    }
}

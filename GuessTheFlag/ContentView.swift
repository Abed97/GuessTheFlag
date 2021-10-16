//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Abed Atassi on 2021-09-09.
//

import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func shake(attempt: CGFloat) -> some View {
        self.modifier(Shake(animatableData: attempt))
    
    }
}

struct FlagImage: View {
    var img: String
    
    var body: some View {
        Image(img)
            .renderingMode(.original)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
            .overlay(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)).stroke(Color.black, lineWidth: 1))
            .shadow(color: .black, radius: 2)
    }
}

struct ContentView: View {
    
    @State private var showingAlert = false
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var errorMsg = ""
    @State private var score = 0
    @State private var buttonPressed = false
    @State private var userTap = 0
    @State private var attempts: Int = 0
    @State private var opacity = 0.25
    @State private var animationAmount = 0.0
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"]
        .shuffled()
    
    @State private var correctAnswer = Int.random(in: 0...2)
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack(spacing: 50) {
                VStack {
                    
                    Text("Tap the flag of")
                        .foregroundColor(.white)
                        
                    Text(countries[correctAnswer])
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
                VStack {
                    Text("Score: \(score)")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                ForEach(0 ..< 3) { number in
                    
                        Button(action: {
                            self.checkFlagTapped(number)
                            buttonPressed = true
                        }) {
                            FlagImage(img: self.countries[number])
                        }
                        .rotation3DEffect(
                            .degrees(animationAmount), axis: (x: 0.0, y: number == correctAnswer ? 1.0: 0.0, z: 0.0)
                        )
                        .opacity(buttonPressed && number != userTap ? self.opacity : 1.0)
                        .shake(attempt: CGFloat(userTap == number ? self.attempts : 0))
                                    
                }
                .alert(isPresented: $showingScore) {
                    Alert(title: Text(scoreTitle), message: Text(" \(errorMsg) \r Your score is \(score)") , dismissButton: .default(Text("Continue")) {
                        self.askQuestion()
                    })
                }
            }
        }
    }
    
    func checkFlagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            errorMsg = ""
            score += 1
            userTap = number
            
            withAnimation {
                self.animationAmount += 360
            }
        } else {
            scoreTitle = "Incorrect"
            errorMsg = "Wrong! That’s the flag of \(countries[number])"
            userTap = number
            
            withAnimation(.default) {
                self.attempts += 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingScore = true
        }
        
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        buttonPressed = false
        self.attempts = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  Word Games
//
//  Created by Dylan Conklin on 7/31/23.
//

import SwiftUI

extension String {
    subscript(index: Int) -> String {
        String(dropLast(count - (index + 1)).dropFirst(index))
    }
}

struct ContentView: View {
    @State var wordleLength: Int = 7
    @State private var wordSet: Set<String> = []
    @State private var wordle: String = ""
    @State private var guess: String = ""
    @State private var attemptedWordles: [String] = []
    @State private var score: Int = 0
    @State private var limit: Int = 5

    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingError: Bool = false

    /// Load word library and start game
    func initGame() {
        if let startWords: String = try? String(contentsOf: Bundle.main.url(forResource: "\(wordleLength)", withExtension: "txt")!) {
            wordSet = Set(startWords.components(separatedBy: .newlines))
            newGame()
        }
    }

    /// Start a new game
    func newGame() {
        wordle = wordSet.randomElement()!
        guess = ""
        attemptedWordles = []
    }

    /// Insert guessed word if it is valid
    func submitGuess() {
        let result: String = guess.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if isValid(word: result) {
            attemptedWordles.insert(result, at: 0)
            if attemptedWordles.contains(wordle) {
                score += result.count
                newGame()
            } else if attemptedWordles.count > limit {
                error("You Lose", "The wordle was \(wordle).")
                newGame()
            }
        }
        guess = ""
    }

    /// Check if the guess qualifies for insertion
    /// - Parameter word: The user's guess
    /// - Returns: Boolean indicating whether the guess qualifies
    func isValid(word: String) -> Bool {
        var result: Bool = false
        checker: if word.isEmpty {
            break checker
        } else if word.count < wordle.count {
            error("Invalid Word", "Your guess is shorter than the Wordle.")
            break checker
        } else if word.count > wordle.count {
            error("Invalid Word", "Your guess is longer than the Wordle.")
            break checker
        } else if !wordSet.contains(word) {
            error("Invalid Word", "Your guess is not a real word.")
            break checker
        } else {
            result = true
        }
        return result
    }

    /// Display an error message
    /// - Parameters:
    ///   - title: Heading for the error
    ///   - message: Details of what the error means
    func error(_ title: String, _ message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }

    var body: some View {
        VStack {
            Text("Wordle")
                .font(Font.largeTitle)
            if score > 0 {
                Text("Score \(score)")
                    .font(Font.headline)
            }
            List {
                Section {
                    TextField("Enter your word: ", text: $guess)
                        .fontDesign(.monospaced)
                        .autocorrectionDisabled(true)
                }
                Stepper("Wordle Length: \(wordleLength)", value: $wordleLength, in: 1 ... 22) { _ in
                    initGame()
                }
                Button("Get new Word") {
                    newGame()
                }
                Section {
                    ForEach(attemptedWordles.reversed(), id: \.self) { word in
                        HStack {
                            ForEach(Array(word.enumerated()), id: \.offset) { index, letter in
                                if wordle[index] == String(letter) {
                                    Text(String(letter))
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(Color.green)
                                } else if wordle.contains(String(letter)) {
                                    Text(String(letter))
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(Color.yellow)
                                } else {
                                    Text(String(letter))
                                        .fontDesign(.monospaced)
                                }
                            }
                        }
                    }
                }
            }
            .onSubmit(submitGuess)
            .onAppear(perform: initGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

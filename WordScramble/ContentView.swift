//
//  ContentView.swift
//  WordScramble
//
//  Created by Frank Grullon on 27/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var useWords : [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    @State private var scoreTitle = ""
    
    var body: some View {
        NavigationStack{
            List {
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(useWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {} message: {
                Text(errorMessage)
            }
            .toolbar{
                HStack(alignment: .firstTextBaseline, spacing: 50){
                    Text(scoreTitle)

                    Button("Start Game") {
                        startGame()
                    }
                }

            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count >= 3 else {
            wordError(title: "Length not meet", message: "Word shorter than three letters")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Can't be \(rootWord)", message: "You can't use \(rootWord) as your answer")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPosible(word: answer) else {
            wordError(title: "Word not posibble", message: "You can't spell that word fro \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "word not recognized", message: "You can't  me them up, you know!")
            return
        }
        
        score += answer.count
        scoreTitle = "\(score) Points"
        withAnimation{
            useWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame(){
        score = 0
        scoreTitle = ""
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt file bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !useWords.contains(word)
    }
    
    func isPosible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}

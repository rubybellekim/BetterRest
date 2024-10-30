//
//  ContentView.swift
//  BetterRest
//
//  Created by Ruby Kim on 2024-04-24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
        
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var showingAlert = false
    
    @State private var title = ""
    @State private var msg = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp, initial: true, calculatedBedtime)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount, calculatedBedtime)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
//                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20, step: 1)
                    Picker("coffee cups", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text($0.description)
                        }
                    }
                    .onChange(of: coffeeAmount, calculatedBedtime)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("See Results")
                        .font(.headline)
                    Text("\(title)")
                        .font(.caption)
                    Text("\(msg)")
                        .font(.largeTitle.bold())
                }
            }
            .navigationTitle("BetterRest")
        }
    }

func calculatedBedtime() {
    do {
        let config = MLModelConfiguration()
        let model = try SleepCalculator(configuration: config)
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        let prediction = try model.prediction(wake: Double(hour + minute),
            estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
        
        let sleepTime = wakeUp - prediction.actualSleep
        
        title = "Your ideal bedtime is..."
        msg = sleepTime.formatted(date: .omitted, time: .shortened)
    } catch {
        title = "Error"
        msg = "Sorry, there was a problem calculating your bedtime."
    }
}
}

#Preview {
    ContentView()
}

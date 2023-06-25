import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State var showImmersiveSpace = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @State var toDoItems = [ToDoItem]()

    @State var newToDoItem = ""
    @State private var showingAlert = false
    @State var selectedDate = Date()
    @State var selectedTime = Date()
    @State var showCustomDurationPicker = false // Add a state to control the pop-up visibility
    @State var selectedDuration: DurationOption = .fifteenMinutes
    @State var isCustomDurationActive = false
    @State var sidebarIsOpen = false
    
    @State var isNotifyFiveMinutesBefore = false
    @State var isNotifyAtStart = false
    @State var isNotifyAtEnd = false

    @FocusState private var datePickerFocus: Bool
    
    private var groupedToDoItems: [(date: Date, items: [ToDoItem])] {
        Dictionary(grouping: toDoItems, by: { Calendar.current.startOfDay(for: $0.date) })
            .sorted(by: { $0.key > $1.key })
            .map { (date: $0.key, items: $0.value) }
    }

    var body: some View {
        NavigationSplitView {
            List {
                if(groupedToDoItems.isEmpty){
                    Text("You have nothing to do today? 🤣")
                }
                ForEach(groupedToDoItems, id: \.date) { group in
                    Section(header: Text(formatDate(group.date))) {
                            ForEach(group.items) { toDoItem in
                                VStack(alignment: .leading) {
                                    CheckboxListItemView(toDoItem: toDoItem)
                                        .swipeActions {
                                                Button(action: {
                                                    removeToDoItem(toDoItem)
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.white)
                                                        .background(Color.red)
                                                }
                                            }
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("To-Do List")
            .padding(0)
        } detail: {
            ScrollView{
                VStack (alignment: .leading){
                    Text("What do you want to")
                        .font(.extraLargeTitle).fontWeight(.heavy).animation(.smooth)
                    Text("do today?")
                        .font(.extraLargeTitle).foregroundColor(Color.yellow).fontWeight(.heavy)
                    
                    TextField("I want to...", text: $newToDoItem)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(100)
                        .foregroundColor(.black).accentColor(.gray)
                    
                    DatePicker(selection: $selectedDate, in: Date()..., displayedComponents: .date) {
                        Text("Select date")
                    }
                    .frame(maxWidth: .infinity)
                    .onChange(of: selectedDate) {
                        datePickerFocus = false
                    }

                    DatePicker(selection: $selectedTime, displayedComponents: .hourAndMinute) {
                        Text("Select time:")
                    }
                    .frame(maxWidth: .infinity)
                    .onChange(of: selectedTime) {
                        datePickerFocus = false
                    }

                    
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach([DurationOption.fifteenMinutes, DurationOption.thirtyMinutes, DurationOption.oneHour, DurationOption.oneAndHalfHours], id: \.self) { option in
                            Text(option.stringValue)
                        }
                        Text("Custom")
                            .tag(DurationOption.custom(hours: selectedDuration.customHours, minutes: selectedDuration.customMinutes))
                    }
                    .foregroundColor(.yellow)
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)
                    .onChange(of: selectedDuration) {
                        if case .custom = selectedDuration {
                            showCustomDurationPicker = true
                        } else {
                            showCustomDurationPicker = false
                        }
                    }

                    Text("Notify...")
                            .font(.headline)
                    HStack(spacing: 0){
                        CheckboxView(isChecked: $isNotifyFiveMinutesBefore, label: "5 minutes before")
                                .padding(.vertical, 4)
                        Spacer()
                            CheckboxView(isChecked: $isNotifyAtStart, label: "At the start")
                                .padding(.vertical, 4)
                        Spacer()
                            CheckboxView(isChecked: $isNotifyAtEnd, label: "At the end")
                                .padding(.vertical, 4)
                        Spacer()
                    }
                    
                   
                    
                    Button(action: {
                        withAnimation {
                                if newToDoItem.isEmpty {
                                    showingAlert = true
                                } else {
                                    let todo = ToDoItem(text: newToDoItem, date: selectedDate, time: selectedTime, duration: selectedDuration, isNotifyFiveMinutesBefore: isNotifyFiveMinutesBefore, isNotifyAtStart: isNotifyAtStart, isNotifyAtEnd: isNotifyAtEnd)
                                    toDoItems.append(todo)
                                    newToDoItem = ""
                                    selectedDate = Date()
                                    selectedTime = Date()
                                    selectedDuration = .fifteenMinutes
                                    isNotifyFiveMinutesBefore = false
                                    isNotifyAtStart = false
                                    isNotifyAtEnd = false
                                }
                            }
                    }) {
                        Text("Add Task")
                            .foregroundColor(.white)
                            .padding().frame(maxWidth: .infinity)
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity) // Make the button full-width

                }.alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Empty Field"),
                        message: Text("Please enter a task."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding()
                .sheet(isPresented: $showCustomDurationPicker) {
                    CustomDurationPicker(selectedDuration: $selectedDuration, isCustomDurationActive: $isCustomDurationActive) {
                        showCustomDurationPicker = false // Close the pop-up by setting the flag to false
                    }.animation(.easeInOut, value: showCustomDurationPicker)
                }
            }.navigationBarHidden(true).padding()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    private func dismissDatePicker() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func scheduleLocalNotification(for toDoItem: ToDoItem) {
            let content = UNMutableNotificationContent()
            content.title = "ToDo Item Reminder"
            content.body = "Don't forget: \(toDoItem.text)"
            content.sound = .default
            
            let calendar = Calendar.current
            let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: toDoItem.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: toDoItem.id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling local notification: \(error.localizedDescription)")
                }
            }
        }
}

extension DurationOption {
    var stringValue: String {
        switch self {
        case .fifteenMinutes:
            return "15 Minutes"
        case .thirtyMinutes:
            return "30 Minutes"
        case .oneHour:
            return "1 Hour"
        case .oneAndHalfHours:
            return "1.5 Hours"
        case .custom(let hours, let minutes):
            return "\(hours) Hours \(minutes) Minutes"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

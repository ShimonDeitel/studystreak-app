import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StudystreakStore
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: StudystreakItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    if store.items.isEmpty {
                        emptyState
                    } else {
                        list
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Theme.accent)
                    }
                    .accessibilityIdentifier("settingsButton")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddItemView(store: store) { didAdd in
                    if !didAdd { showingPaywall = true }
                }
            }
            .sheet(item: $editingItem) { item in
                AddItemView(store: store, editing: item) { _ in }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Studystreak")
                        .font(Theme.titleFont(30))
                        .foregroundStyle(Theme.ink)
                    Text("Log a daily study check-in and build a visible streak.")
                        .font(Theme.bodyFont(13))
                        .foregroundStyle(Theme.mutedInk)
                        .lineLimit(2)
                }
                Spacer()
                Button {
                    if store.canAddMore {
                        showingAdd = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.accent)
                }
                .accessibilityIdentifier("addItemButton")
            }
            HStack {
                Text("\(store.items.count) check-ins logged")
                    .font(Theme.labelFont())
                    .foregroundStyle(Theme.mutedInk)
                Spacer()
                Text(String(format: "%.1f minutes", store.totalValue))
                    .font(Theme.labelFont())
                    .foregroundStyle(Theme.accent)
            }
            .padding(.top, 4)
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.mutedInk)
            Text("No check-ins yet")
                .font(Theme.bodyFont(17))
                .foregroundStyle(Theme.mutedInk)
            Button("Add your first entry") {
                showingAdd = true
            }
            .font(Theme.labelFont())
            .foregroundStyle(Theme.accent)
            .accessibilityIdentifier("addFirstEntryButton")
            Spacer()
        }
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                StudystreakRowView(item: item)
                    .listRowBackground(Theme.card)
                    .contentShape(Rectangle())
                    .onTapGesture { editingItem = item }
                    .accessibilityIdentifier("itemRow_\(item.title)")
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
    }
}

struct StudystreakRowView: View {
    let item: StudystreakItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(Theme.bodyFont(16))
                    .foregroundStyle(Theme.ink)
                Text(item.category)
                    .font(Theme.labelFont(12))
                    .foregroundStyle(Theme.accent)
            }
            Spacer()
            Text(String(format: "%.1f", item.value))
                .font(Theme.bodyFont(15))
                .foregroundStyle(Theme.mutedInk)
            if item.isResolved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.vertical, 6)
    }
}

struct AddItemView: View {
    @ObservedObject var store: StudystreakStore
    var editing: StudystreakItem?
    var onComplete: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var category: String = StudystreakCategory.allCases.first?.rawValue ?? ""
    @State private var value: String = ""
    @State private var notes: String = ""

    init(store: StudystreakStore, editing: StudystreakItem? = nil, onComplete: @escaping (Bool) -> Void) {
        self.store = store
        self.editing = editing
        self.onComplete = onComplete
        _title = State(initialValue: editing?.title ?? "")
        _category = State(initialValue: editing?.category ?? (StudystreakCategory.allCases.first?.rawValue ?? ""))
        _value = State(initialValue: editing != nil ? String(editing!.value) : "")
        _notes = State(initialValue: editing?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("titleField")
                    Picker("Category", selection: $category) {
                        ForEach(StudystreakCategory.allCases, id: \.rawValue) { cat in
                            Text(cat.rawValue).tag(cat.rawValue)
                        }
                    }
                    TextField("Value (minutes)", text: $value)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("valueField")
                    TextField("Notes", text: $notes)
                        .accessibilityIdentifier("notesField")
                }
                if let editing {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(editing)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
            )
            .navigationTitle(editing == nil ? "Add Check-in" : "Edit Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .tint(Theme.accent)
    }

    private func save() {
        let doubleValue = Double(value) ?? 0
        if var editing {
            editing.title = title
            editing.category = category
            editing.value = doubleValue
            editing.notes = notes
            store.update(editing)
            onComplete(true)
        } else {
            let added = store.add(title: title, category: category, value: doubleValue, notes: notes)
            onComplete(added)
        }
        dismiss()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

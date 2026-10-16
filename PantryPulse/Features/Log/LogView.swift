import SwiftUI
import SwiftData

/// Log tab: everything eaten or planned today, with an empty state for a fresh day.
struct LogView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \LogEntry.date) private var entries: [LogEntry]
    @State private var showingAdd = false

    private var today: [LogEntry] {
        entries.filter { Calendar.current.isDateInToday($0.date) }
    }
    private var eaten: [LogEntry] { today.filter { !$0.isPlanned } }
    private var planned: [LogEntry] { today.filter { $0.isPlanned } }

    var body: some View {
        Group {
            if today.isEmpty {
                EmptyStateView(
                    symbol: "list.bullet.clipboard",
                    overline: "Daily log",
                    title: "Nothing logged yet",
                    message: "Add a grocery item or meal to start building your nutrition history.",
                    actionTitle: "Add your first item",
                    action: { showingAdd = true }
                )
            } else {
                list
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .sheet(isPresented: $showingAdd) {
            LogMealSheet()
        }
    }

    private var list: some View {
        List {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Overline("Daily log", color: Theme.inkMuted)
                    Text("Today")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundStyle(Theme.ink)
                }
                Spacer()
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Theme.sage, in: Circle())
                }
                .accessibilityLabel("Log a meal")
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 8, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if !eaten.isEmpty {
                Section {
                    ForEach(eaten) { entry in
                        row(for: entry)
                    }
                    .onDelete { offsets in delete(offsets, from: eaten) }
                } header: {
                    sectionHeader("Eaten today")
                }
            }

            if !planned.isEmpty {
                Section {
                    ForEach(planned) { entry in
                        row(for: entry)
                            .swipeActions(edge: .leading) {
                                Button {
                                    markEaten(entry)
                                } label: {
                                    Label("Eaten", systemImage: "checkmark")
                                }
                                .tint(Theme.sage)
                            }
                    }
                    .onDelete { offsets in delete(offsets, from: planned) }
                } header: {
                    sectionHeader("Planned")
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func sectionHeader(_ text: String) -> some View {
        Overline(text, color: Theme.inkMuted)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textCase(nil)
    }

    private func row(for entry: LogEntry) -> some View {
        LogEntryRow(entry: entry)
            .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    private func delete(_ offsets: IndexSet, from source: [LogEntry]) {
        for index in offsets {
            context.delete(source[index])
        }
    }

    private func markEaten(_ entry: LogEntry) {
        entry.isPlanned = false
        entry.date = Date()
    }
}

private struct LogEntryRow: View {
    let entry: LogEntry

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: entry.meal.symbol)
                .font(.title3)
                .foregroundStyle(Theme.sageInk)
                .frame(width: 48, height: 48)
                .background(Theme.sageSoft, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text("\(entry.meal.title) · \(entry.date.formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkMuted)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(entry.calories) kcal")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text("\(entry.protein)g P")
                    .font(.caption)
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .combine)
    }
}

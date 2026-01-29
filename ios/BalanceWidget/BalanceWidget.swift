import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(
            date: Date(),
            balance: 1234.56,
            currency: "USD",
            userName: "User",
            lastTransaction: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> ()) {
        let entry = loadWidgetData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = loadWidgetData()

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func loadWidgetData() -> BalanceEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.joonapay.usdcwallet")

        let balance = sharedDefaults?.double(forKey: "widget_balance") ?? 0.0
        let currency = sharedDefaults?.string(forKey: "widget_currency") ?? "USD"
        let userName = sharedDefaults?.string(forKey: "widget_user_name")

        var lastTransaction: LastTransaction?
        if let transactionJson = sharedDefaults?.string(forKey: "widget_last_transaction"),
           let transactionData = transactionJson.data(using: .utf8) {
            if let json = try? JSONSerialization.jsonObject(with: transactionData) as? [String: Any] {
                lastTransaction = LastTransaction(
                    type: json["type"] as? String ?? "",
                    amount: json["amount"] as? Double ?? 0.0,
                    currency: json["currency"] as? String ?? "USD",
                    recipientName: json["recipientName"] as? String
                )
            }
        }

        return BalanceEntry(
            date: Date(),
            balance: balance,
            currency: currency,
            userName: userName,
            lastTransaction: lastTransaction
        )
    }
}

struct BalanceEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let currency: String
    let userName: String?
    let lastTransaction: LastTransaction?

    var formattedBalance: String {
        if currency == "XOF" {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            formatter.groupingSeparator = " "
            let formatted = formatter.string(from: NSNumber(value: balance)) ?? "0"
            return "XOF \(formatted)"
        } else {
            return String(format: "$%.2f", balance)
        }
    }
}

struct LastTransaction {
    let type: String
    let amount: Double
    let currency: String
    let recipientName: String?

    var description: String {
        let formattedAmount = String(format: "$%.2f", amount)
        if type == "send" {
            if let name = recipientName {
                return "Sent \(formattedAmount) to \(name)"
            }
            return "Sent \(formattedAmount)"
        } else if type == "receive" {
            if let name = recipientName {
                return "Received \(formattedAmount) from \(name)"
            }
            return "Received \(formattedAmount)"
        }
        return ""
    }
}

// MARK: - Small Widget View
struct BalanceWidgetSmallView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.05), // obsidian
                    Color(red: 0.10, green: 0.10, blue: 0.12)  // graphite
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                // App name
                Text("JoonaPay")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.79, green: 0.66, blue: 0.38)) // gold500

                Spacer()

                // Balance
                Text(entry.formattedBalance)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.94)) // textPrimary
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                // Label
                Text("Balance")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.62)) // textSecondary
            }
            .padding(12)
        }
        .widgetURL(URL(string: "joonapay://home"))
    }
}

// MARK: - Medium Widget View
struct BalanceWidgetMediumView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.05), // obsidian
                    Color(red: 0.10, green: 0.10, blue: 0.12)  // graphite
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 0) {
                // Left: Balance section
                VStack(alignment: .leading, spacing: 8) {
                    Text("JoonaPay")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.79, green: 0.66, blue: 0.38))

                    Spacer()

                    Text(entry.formattedBalance)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.94))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    if let userName = entry.userName {
                        Text(userName)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.62))
                    } else {
                        Text("Your Balance")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.62))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)

                // Right: Quick actions
                VStack(spacing: 8) {
                    // Send button
                    Link(destination: URL(string: "joonapay://send")!) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.79, green: 0.66, blue: 0.38))
                            Text("Send")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.94))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 0.13, green: 0.13, blue: 0.16))
                        .cornerRadius(8)
                    }

                    // Receive button
                    Link(destination: URL(string: "joonapay://receive")!) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.79, green: 0.66, blue: 0.38))
                            Text("Receive")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(Color(red: 0.96, green: 0.96, blue: 0.94))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 0.13, green: 0.13, blue: 0.16))
                        .cornerRadius(8)
                    }
                }
                .frame(width: 80)
                .padding(.trailing, 16)
                .padding(.vertical, 16)
            }
        }
    }
}

// MARK: - Widget Configuration
@main
struct BalanceWidget: Widget {
    let kind: String = "BalanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BalanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Balance Widget")
        .description("View your JoonaPay balance at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BalanceWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            BalanceWidgetSmallView(entry: entry)
        case .systemMedium:
            BalanceWidgetMediumView(entry: entry)
        default:
            BalanceWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Preview
struct BalanceWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BalanceWidgetEntryView(entry: BalanceEntry(
                date: Date(),
                balance: 1234.56,
                currency: "USD",
                userName: "Amadou Diallo",
                lastTransaction: LastTransaction(
                    type: "send",
                    amount: 50.0,
                    currency: "USD",
                    recipientName: "Fatou Traore"
                )
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            BalanceWidgetEntryView(entry: BalanceEntry(
                date: Date(),
                balance: 1234.56,
                currency: "USD",
                userName: "Amadou Diallo",
                lastTransaction: nil
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

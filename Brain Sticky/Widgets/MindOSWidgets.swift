//
//  MindOSWidgets.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import WidgetKit
import SwiftUI

// MARK: - 1. Urgent Todo Widget
struct UrgentTodoTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> UrgentTodoEntry {
        UrgentTodoEntry(date: Date(), urgentTitle: "厨房小火炖汤 (15分钟)", remainingCount: 2)
    }

    func getSnapshot(in context: Context, completion: @escaping (UrgentTodoEntry) -> ()) {
        let entry = UrgentTodoEntry(date: Date(), urgentTitle: "厨房小火炖汤 (15分钟)", remainingCount: 2)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UrgentTodoEntry>) -> ()) {
        let entry = UrgentTodoEntry(date: Date(), urgentTitle: "10分钟后关火、取快递", remainingCount: 3)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
        completion(timeline)
    }
}

struct UrgentTodoEntry: TimelineEntry {
    let date: Date
    let urgentTitle: String
    let remainingCount: Int
}

struct UrgentTodoWidgetEntryView: View {
    var entry: UrgentTodoTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle().fill(Color.red.opacity(0.15)).frame(width: 24, height: 24)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.red)
                }
                Text("待办闪念")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Spacer()
                Text("\(entry.remainingCount)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
            
            Text(entry.urgentTitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer(minLength: 0)
            
            HStack {
                Text("即想即做，绝不遗忘")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }
}

public struct UrgentTodoWidget: Widget {
    public let kind: String = "UrgentTodoWidget"
    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UrgentTodoTimelineProvider()) { entry in
            UrgentTodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("待办闪念速览")
        .description("在锁屏或桌面快速查看最近的紧急待办事项。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - 2. Sticky Note Widget
struct StickyNoteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StickyNoteEntry {
        StickyNoteEntry(date: Date(), content: "人类的大脑是用来思考的，不是用来当琐事硬盘的。", mood: "💡", colorHex: "#FEF3C7")
    }

    func getSnapshot(in context: Context, completion: @escaping (StickyNoteEntry) -> ()) {
        let entry = StickyNoteEntry(date: Date(), content: "人类的大脑是用来思考的，不是用来当琐事硬盘的。", mood: "💡", colorHex: "#FEF3C7")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StickyNoteEntry>) -> ()) {
        let entry = StickyNoteEntry(date: Date(), content: "放下焦虑，即想即记。今天也是充满能量的一天 ✨", mood: "✨", colorHex: "#DCFCE7")
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct StickyNoteEntry: TimelineEntry {
    let date: Date
    let content: String
    let mood: String
    let colorHex: String
}

struct StickyNoteWidgetEntryView: View {
    var entry: StickyNoteTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.mood)
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
            }
            
            Text(entry.content)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color.black.opacity(0.85))
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(BentoColors.colorForHex(entry.colorHex))
    }
}

public struct StickyNoteWidget: Widget {
    public let kind: String = "StickyNoteWidget"
    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StickyNoteTimelineProvider()) { entry in
            StickyNoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("随身便利贴")
        .description("在桌面放置随时可见的心情便签与灵感碎片。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - 3. Grocery List Widget
struct GroceryWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> GroceryWidgetEntry {
        GroceryWidgetEntry(date: Date(), items: ["西红柿 4个", "鲜牛奶 1瓶", "抽纸 1提"], progress: 0.4)
    }

    func getSnapshot(in context: Context, completion: @escaping (GroceryWidgetEntry) -> ()) {
        let entry = GroceryWidgetEntry(date: Date(), items: ["西红柿 4个", "鲜牛奶 1瓶", "抽纸 1提"], progress: 0.4)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GroceryWidgetEntry>) -> ()) {
        let entry = GroceryWidgetEntry(date: Date(), items: ["普罗旺斯西红柿 4个", "潮汕肥牛卷 1盒", "加厚抽纸 1提"], progress: 0.6)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
        completion(timeline)
    }
}

struct GroceryWidgetEntry: TimelineEntry {
    let date: Date
    let items: [String]
    let progress: Double
}

struct GroceryWidgetEntryView: View {
    var entry: GroceryWidgetTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack {
                    Circle().fill(BentoColors.groceryMint.opacity(0.15)).frame(width: 22, height: 22)
                    Image(systemName: "cart.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BentoColors.groceryMint)
                }
                Text("买菜清单")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Spacer()
                ProgressView(value: entry.progress)
                    .frame(width: 50)
                    .tint(BentoColors.groceryMint)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(entry.items.prefix(3), id: \.self) { name in
                    HStack(spacing: 6) {
                        Image(systemName: "circle")
                            .font(.system(size: 10))
                            .foregroundColor(BentoColors.groceryMint)
                        Text(name)
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }
}

public struct GroceryWidget: Widget {
    public let kind: String = "GroceryWidget"
    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GroceryWidgetTimelineProvider()) { entry in
            GroceryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("超市买菜清单")
        .description("在桌面快速核对未买生鲜与百货。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
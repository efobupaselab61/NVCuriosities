import Foundation
import SwiftUI

struct NVCuriosityEntry: Identifiable, Hashable {
    let id: Int
    let title: String
    let hook: String
    let story: String
    let category: String
    let rarity: String
    let mood: String
    let location: String
    let firstSeen: String
    let tinyDetail: String
    let readTime: String
    let imageName: String
    let tags: [String]
}

struct NVQuizPrompt: Identifiable {
    let id = UUID()
    let prompt: String
    let choices: [String]
    let correct: String
    let explanation: String
}

struct NVDiscoveryShelf: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let imageName: String
}

@MainActor
final class NVCuriosityAtlas: ObservableObject {
    @AppStorage("nv.onboardingComplete") var onboardingComplete = false
    @AppStorage("nv.vaultedEntryIDs") private var vaultedRaw = "1,2,5"
    @AppStorage("nv.starredEntryIDs") private var starredRaw = "1"
    @AppStorage("nv.chartedEntryIDs") private var chartedRaw = "1,2,3,4,6,8,9"
    @AppStorage("nv.preferredSignalMoods") private var signalMoodsRaw = "Mysteries,Nature,Strange Places"

    @Published var focusedEntry: NVCuriosityEntry?
    @Published var surpriseEntry: NVCuriosityEntry?

    let entries: [NVCuriosityEntry] = [
        NVCuriosityEntry(
            id: 1,
            title: "The Blood Falls of Antarctica",
            hook: "A red-colored waterfall flowing from a glacier.",
            story: "In Antarctica, a waterfall appears to be bleeding from the cold face of Taylor Glacier. The red color comes from iron-rich water that has been sealed beneath the glacier for millions of years and reacts with oxygen when it reaches the surface. The result is part science lesson, part impossible-looking postcard: a rust-red stream pouring through blue-white ice in one of the planet's most severe landscapes.",
            category: "Nature Oddity",
            rarity: "Rare",
            mood: "Mysterious",
            location: "Taylor Valley, Antarctica",
            firstSeen: "1911",
            tinyDetail: "The water has been trapped for at least 1.5 million years.",
            readTime: "45 sec",
            imageName: "BloodFalls",
            tags: ["Rare", "Natural", "Mysterious", "Scientific"]
        ),
        NVCuriosityEntry(
            id: 2,
            title: "The Door to Hell",
            hook: "A burning gas crater that has glowed for decades.",
            story: "In Turkmenistan's Karakum Desert, the Darvaza gas crater has burned since the early 1970s. Its glowing pit looks like a portal in the sand, especially at night, when orange fire lights the surrounding desert. The site became famous because it feels mythic, but its origin is modern: a drilling accident exposed natural gas, and the fire was expected to burn out quickly. It did not.",
            category: "Strange Places",
            rarity: "Hidden",
            mood: "Beautiful",
            location: "Darvaza, Turkmenistan",
            firstSeen: "1971",
            tinyDetail: "Its nickname comes from the crater's fiery appearance after dark.",
            readTime: "50 sec",
            imageName: "DoorHell",
            tags: ["Strange", "Hidden", "Beautiful", "Forgotten"]
        ),
        NVCuriosityEntry(
            id: 3,
            title: "Singing Sand Dunes",
            hook: "Some desert dunes can produce a deep humming sound.",
            story: "In several deserts, certain dunes create a low musical vibration when dry grains slide down their slopes. The sound can feel like a distant engine or a natural instrument under the sand. Scientists connect it to grain size, dryness and the way countless particles move together, turning a quiet landscape into a resonant body.",
            category: "Nature Oddity",
            rarity: "Unusual",
            mood: "Mysterious",
            location: "Several deserts",
            firstSeen: "Ancient reports",
            tinyDetail: "Not every dune can sing; the sand needs very specific conditions.",
            readTime: "40 sec",
            imageName: "CuriositySingingDunes",
            tags: ["Natural", "Mysterious", "Scientific"]
        ),
        NVCuriosityEntry(
            id: 4,
            title: "The Voynich Manuscript",
            hook: "A mysterious book written in an unknown language.",
            story: "The Voynich Manuscript is filled with strange plants, circular diagrams and writing that no one has convincingly decoded. It has been studied by cryptographers, historians and linguists, yet it still resists a simple explanation. Its charm is that it looks purposeful and beautifully organized, while keeping its meaning just out of reach.",
            category: "Mystery Object",
            rarity: "Rare",
            mood: "Unknown",
            location: "Yale Beinecke Library",
            firstSeen: "15th century",
            tinyDetail: "Radiocarbon dating places its parchment in the early 1400s.",
            readTime: "55 sec",
            imageName: "CuriosityVoynich",
            tags: ["Ancient", "Mysterious", "Forgotten"]
        ),
        NVCuriosityEntry(
            id: 5,
            title: "The Stone Spheres",
            hook: "Perfectly rounded prehistoric stone balls found in Costa Rica.",
            story: "Hundreds of stone spheres were discovered in Costa Rica, ranging from small objects to massive boulders. Their exact purpose is unknown, though they may have marked status, territory or ceremonial spaces. What makes them magnetic is their precision: quiet, heavy geometry left behind by people whose full story is still incomplete.",
            category: "Ancient Object",
            rarity: "Ancient",
            mood: "Mysterious",
            location: "Diquis Delta, Costa Rica",
            firstSeen: "Pre-Columbian era",
            tinyDetail: "Some spheres weigh many tons but are impressively round.",
            readTime: "48 sec",
            imageName: "CuriosityStoneSpheres",
            tags: ["Ancient", "Cultural", "Mysterious"]
        ),
        NVCuriosityEntry(
            id: 6,
            title: "Lake Hillier",
            hook: "A bright pink lake on an island off Western Australia.",
            story: "Lake Hillier looks edited by imagination: a compact pink lake ringed by green forest and blue ocean. The color is linked to salt-loving organisms and algae that thrive in its unusual water. Even when removed from the lake, the water can keep its pink tone for a while, making the place feel like a natural color swatch.",
            category: "Nature Oddity",
            rarity: "Beautiful",
            mood: "Beautiful",
            location: "Middle Island, Australia",
            firstSeen: "1802",
            tinyDetail: "The lake is separated from the ocean by a narrow strip of land.",
            readTime: "42 sec",
            imageName: "CuriosityLakeHillier",
            tags: ["Natural", "Beautiful", "Scientific"]
        )
    ]

    let quiz = NVQuizPrompt(
        prompt: "Which place is known for a red-colored waterfall?",
        choices: ["Iceland", "Antarctica", "Peru", "Japan"],
        correct: "Antarctica",
        explanation: "The Blood Falls in Antarctica gets its red color from iron-rich water reacting with oxygen."
    )

    let categories: [NVDiscoveryShelf] = [
        NVDiscoveryShelf(title: "Mystery Objects", count: 24, imageName: "CategoryMysteryObjects"),
        NVDiscoveryShelf(title: "Nature Oddities", count: 31, imageName: "CategoryNatureOddities"),
        NVDiscoveryShelf(title: "Strange Places", count: 28, imageName: "CategoryStrangePlaces"),
        NVDiscoveryShelf(title: "Human Rituals", count: 26, imageName: "CategoryHumanRituals"),
        NVDiscoveryShelf(title: "Science Wonders", count: 22, imageName: "CategoryScienceWonders"),
        NVDiscoveryShelf(title: "History Bizarre", count: 23, imageName: "CategoryHistoryBizarre")
    ]

    var today: NVCuriosityEntry { entries[Calendar.current.component(.day, from: Date()) % entries.count] }
    var vaultedEntryIDs: Set<Int> { Set(vaultedRaw.split(separator: ",").compactMap { Int($0) }) }
    var starredEntryIDs: Set<Int> { Set(starredRaw.split(separator: ",").compactMap { Int($0) }) }
    var chartedEntryIDs: Set<Int> { Set(chartedRaw.split(separator: ",").compactMap { Int($0) }) }
    var preferredSignalMoods: Set<String> { Set(signalMoodsRaw.split(separator: ",").map(String.init)) }

    func toggleVaulted(_ entry: NVCuriosityEntry) {
        update(raw: &vaultedRaw, id: entry.id)
    }

    func toggleStarred(_ entry: NVCuriosityEntry) {
        update(raw: &starredRaw, id: entry.id)
    }

    func markCharted(_ entry: NVCuriosityEntry) {
        var ids = chartedEntryIDs
        ids.insert(entry.id)
        chartedRaw = ids.sorted().map(String.init).joined(separator: ",")
    }

    func toggleSignalMood(_ mood: String) {
        var moods = preferredSignalMoods
        if moods.contains(mood) {
            moods.remove(mood)
        } else {
            moods.insert(mood)
        }
        signalMoodsRaw = moods.sorted().joined(separator: ",")
    }

    func drawSurpriseEntry(signalMood: String?) {
        let pool = signalMood == nil || signalMood == "Any" ? entries : entries.filter { $0.mood == signalMood || $0.category.contains(signalMood ?? "") }
        surpriseEntry = (pool.isEmpty ? entries : pool).randomElement()
    }

    private func update(raw: inout String, id: Int) {
        var ids = Set(raw.split(separator: ",").compactMap { Int($0) })
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        raw = ids.sorted().map(String.init).joined(separator: ",")
    }
}

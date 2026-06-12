import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas

    var body: some View {
        Group {
            if store.onboardingComplete {
                MainTabs()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
        .tint(.nvPink)
    }
}

struct MainTabs: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "calendar") }
            ExploreView()
                .tabItem { Label("Explore", systemImage: "magnifyingglass.circle") }
            RandomView()
                .tabItem { Label("Random", systemImage: "shippingbox") }
            QuizView()
                .tabItem { Label("Quiz", systemImage: "questionmark.app") }
            ProfileView()
                .tabItem { Label("My NV", systemImage: "person") }
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            NVTelemetryService.shared.logAppOpen()
            PushNotificationService.shared.configureNotificationsIfNeeded()
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    @State private var onboardingStep = 0
    private let moods = ["Mysteries", "Nature", "Ancient Objects", "Strange Places", "Human Stories", "Science Oddities", "Lost Traditions", "Weird Animals"]

    var body: some View {
        ZStack {
            NVBackground()
            TabView(selection: $onboardingStep) {
                onboardingPanel(title: "Welcome to NV Curiosities", subtitle: "Explore unusual facts, mysterious objects and surprising stories from around the world.", image: "MysteryMask", action: "Start Exploring") {
                    onboardingStep = 1
                }
                .tag(0)

                VStack(alignment: .leading, spacing: 22) {
                    NVLogo()
                    Text("Tune Your Wonder Radar")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                        ForEach(moods, id: \.self) { signalMood in
                            Button {
                                store.toggleSignalMood(signalMood)
                            } label: {
                                HStack {
                                    Image(systemName: store.preferredSignalMoods.contains(signalMood) ? "checkmark.circle.fill" : "circle")
                                    Text(signalMood)
                                        .font(.caption.weight(.semibold))
                                    Spacer()
                                }
                                .padding(13)
                                .background(store.preferredSignalMoods.contains(signalMood) ? Color.nvPink.opacity(0.25) : Color.white.opacity(0.07))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(store.preferredSignalMoods.contains(signalMood) ? Color.nvPink : Color.white.opacity(0.12)))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    PrimaryButton(title: "Continue", icon: "arrow.right") { onboardingStep = 2 }
                }
                .padding(28)
                .tag(1)

                onboardingPanel(title: "One strange discovery every day", subtitle: "Open the app daily to reveal a new card and grow your collection.", image: "RandomCube", action: "Enter NV") {
                    NVTelemetryService.shared.logOnboardingCompleted(preferredSignalMoods: Array(store.preferredSignalMoods))
                    store.onboardingComplete = true
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private func onboardingPanel(title: String, subtitle: String, image: String, action: String, tap: @escaping () -> Void) -> some View {
        VStack(spacing: 26) {
            Spacer()
            NVLogo()
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.nvPink.opacity(0.65), lineWidth: 1))
                .shadow(color: .nvPink.opacity(0.45), radius: 26)
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(Color.nvMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            PrimaryButton(title: action, icon: "arrow.right", action: tap)
            Spacer()
        }
        .padding(28)
    }
}

struct TodayView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    @State private var showDetail = false
    private var cardHeight: CGFloat {
        min(max(UIScreen.main.bounds.height * 0.38, 292), 340)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NVBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HeaderBar(title: "NV CURIOSITIES", subtitle: "TODAY'S DISCOVERY", trailing: "flame.fill", badge: "12")
                        DiscoveryCard(entry: store.today, large: true, height: cardHeight)
                            .onTapGesture { showDetail = true }
                        PrimaryButton(title: "Reveal Story", icon: "chevron.right") {
                            store.markCharted(store.today)
                            NVTelemetryService.shared.logRevealStory(store.today)
                            showDetail = true
                        }
                        HStack(spacing: 18) {
                            CircleAction(system: store.vaultedEntryIDs.contains(store.today.id) ? "bookmark.fill" : "bookmark") {
                                store.toggleVaulted(store.today)
                                NVTelemetryService.shared.logEntryVaulted(store.today, isVaulted: store.vaultedEntryIDs.contains(store.today.id))
                            }
                            CircleAction(system: "cube.transparent") {
                                store.drawSurpriseEntry(signalMood: nil)
                                NVTelemetryService.shared.logSignalDraw(signalMood: nil, result: store.surpriseEntry)
                            }
                            CircleAction(system: store.starredEntryIDs.contains(store.today.id) ? "heart.fill" : "heart") {
                                store.toggleStarred(store.today)
                                NVTelemetryService.shared.logEntryStarred(store.today, isStarred: store.starredEntryIDs.contains(store.today.id))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        DashboardStrip()
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 130)
                }
            }
            .navigationDestination(isPresented: $showDetail) {
                DetailView(entry: store.today)
            }
            .sheet(item: $store.surpriseEntry) { entry in
                DetailView(entry: entry)
            }
            .onAppear {
                NVTelemetryService.shared.logScreen("Today")
            }
        }
    }
}

struct DetailView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    let entry: NVCuriosityEntry

    var body: some View {
        ZStack {
            NVBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    GeometryReader { proxy in
                        Image(entry.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: 250)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(alignment: .bottomLeading) {
                                LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .top, endPoint: .bottom)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                            .overlay(alignment: .bottomLeading) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.title)
                                        .font(.system(size: 28, weight: .bold, design: .serif))
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.85)
                                    TagRow(entry: entry)
                                }
                                .padding(18)
                            }
                    }
                    .frame(height: 250)

                    SectionTitle("The Story")
                    Text(entry.story)
                        .font(.callout)
                        .foregroundStyle(Color.nvMuted)
                        .lineSpacing(5)

                    SectionTitle("Quick Facts")
                    VStack(spacing: 0) {
                        FactRow(label: "Location", value: entry.location)
                        FactRow(label: "Category", value: entry.category)
                        FactRow(label: "First Seen", value: entry.firstSeen)
                        FactRow(label: "Why It's Unusual", value: entry.hook)
                        FactRow(label: "Mood", value: entry.mood)
                    }
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    SectionTitle("Tiny Detail")
                    Label(entry.tinyDetail, systemImage: "quote.opening")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(Color.nvMuted)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    HStack(spacing: 14) {
                        BottomAction(active: store.vaultedEntryIDs.contains(entry.id), icon: "bookmark.fill") {
                            store.toggleVaulted(entry)
                            NVTelemetryService.shared.logEntryVaulted(entry, isVaulted: store.vaultedEntryIDs.contains(entry.id))
                        }
                        BottomAction(active: store.starredEntryIDs.contains(entry.id), icon: "heart.fill") {
                            store.toggleStarred(entry)
                            NVTelemetryService.shared.logEntryStarred(entry, isStarred: store.starredEntryIDs.contains(entry.id))
                        }
                        BottomAction(active: false, icon: "square.and.arrow.up") { }
                    }
                }
                .padding(20)
                .padding(.bottom, 90)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.markCharted(entry)
            NVTelemetryService.shared.logScreen("Wonder Detail")
            NVTelemetryService.shared.logEntryViewed(entry, source: "detail")
        }
    }
}

struct ExploreView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    @State private var selectedShelfFilter = "All"
    private let filters = ["All", "Mysteries", "Nature", "Places", "Objects"]

    var body: some View {
        NavigationStack {
            ZStack {
                NVBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        HeaderBar(title: "EXPLORE", subtitle: nil, trailing: "magnifyingglass", badge: nil)
                        PickerPills(items: filters, selection: $selectedShelfFilter)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(store.categories) { category in
                                NavigationLink {
                                    CategoryListView(category: category.title)
                                } label: {
                                    CategoryTile(category: category)
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    NVTelemetryService.shared.logCategoryOpened(category.title)
                                })
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 84)
                }
            }
            .onAppear {
                NVTelemetryService.shared.logScreen("Explore")
            }
        }
    }
}

struct CategoryListView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    let category: String

    var body: some View {
        ZStack {
            NVBackground()
            List(store.entries, id: \.id) { entry in
                NavigationLink {
                    DetailView(entry: entry)
                } label: {
                    HStack(spacing: 12) {
                        Image(entry.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 74, height: 62)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 5) {
                            Text(entry.title).font(.headline)
                            Text(entry.hook).font(.caption).foregroundStyle(Color.nvMuted).lineLimit(2)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(category)
        .onAppear {
            NVTelemetryService.shared.logScreen("Category \(category)")
        }
    }
}

struct RandomView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    @State private var signalMood = "Any"
    @State private var cubeDrift = false
    private let moods = ["Any", "Beautiful", "Creepy", "Ancient", "Funny"]

    var body: some View {
        NavigationStack {
            ZStack {
                NVBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        HeaderBar(title: "RANDOM DISCOVERY", subtitle: nil, trailing: nil, badge: nil)
                        Text("SURPRISE ME")
                            .font(.system(size: 31, weight: .bold, design: .serif))
                        Text("Draw a hidden wonder\nfrom the NV atlas")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.nvMuted)
                        Image("RandomCube")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280)
                            .rotation3DEffect(.degrees(cubeDrift ? 12 : -12), axis: (x: 0, y: 1, z: 0))
                            .shadow(color: .nvPink.opacity(0.65), radius: cubeDrift ? 34 : 18)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: cubeDrift)
                            .onAppear { cubeDrift = true }
                        PrimaryButton(title: "Surprise Me", icon: "sparkles") {
                            store.drawSurpriseEntry(signalMood: signalMood)
                            NVTelemetryService.shared.logSignalDraw(signalMood: signalMood, result: store.surpriseEntry)
                        }
                        VStack(alignment: .leading, spacing: 14) {
                            SectionTitle("Choose a Mood")
                            HStack(spacing: 12) {
                                ForEach(moods, id: \.self) { item in
                                    MoodButton(title: item, selected: signalMood == item) { signalMood = item }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 90)
                }
            }
            .sheet(item: $store.surpriseEntry) { entry in
                DetailView(entry: entry)
            }
            .onAppear {
                NVTelemetryService.shared.logScreen("Random")
            }
        }
    }
}

struct QuizView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    @State private var selectedAnswer: String?

    var body: some View {
        NavigationStack {
            ZStack {
                NVBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        HeaderBar(title: "QUIZ TIME", subtitle: "Question 2 of 10", trailing: nil, badge: nil)
                        ProgressView(value: 0.35)
                            .tint(.nvPink)
                        VStack(alignment: .leading, spacing: 16) {
                            Text(store.quiz.prompt)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                            ForEach(Array(store.quiz.choices.enumerated()), id: \.offset) { index, choice in
                                QuizChoice(index: index, choice: choice, selected: selectedAnswer == choice, correct: store.quiz.correct == choice, answered: selectedAnswer != nil) {
                                    selectedAnswer = choice
                                    NVTelemetryService.shared.logQuizAnswered(question: store.quiz.prompt, selectedAnswer: choice, isCorrect: store.quiz.correct == choice)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        if let selectedAnswer {
                            ResultPanel(correct: selectedAnswer == store.quiz.correct)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 88)
                }
            }
            .onAppear {
                NVTelemetryService.shared.logScreen("Quiz")
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    @State private var vaultMode = "Saved"
    private let tabs = ["Saved", "Seen", "Favorites", "Archive"]

    var body: some View {
        NavigationStack {
            ZStack {
                NVBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        HeaderBar(title: "MY NV", subtitle: nil, trailing: nil, badge: nil)
                        ProfileCard()
                        SectionTitle("Achievements")
                        HStack(spacing: 14) {
                            Badge(title: "First\nDiscovery", icon: "sparkle")
                            Badge(title: "7-Day\nExplorer", icon: "flame.fill")
                            Badge(title: "Mystery\nSeeker", icon: "cube")
                            Badge(title: "Nature\nCollector", icon: "leaf.fill")
                        }
                        HeaderBar(title: "COLLECTION", subtitle: nil, trailing: nil, badge: nil)
                        PickerPills(items: tabs, selection: $vaultMode)
                        CollectionList(mode: vaultMode)
                        HeaderBar(title: "DAILY ARCHIVE", subtitle: nil, trailing: nil, badge: nil)
                        ArchiveView()
                    }
                    .padding(20)
                    .padding(.bottom, 90)
                }
            }
            .onAppear {
                NVTelemetryService.shared.logScreen("My NV")
            }
        }
    }
}

struct CollectionList: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    let mode: String

    private var items: [NVCuriosityEntry] {
        switch mode {
        case "Seen": return store.entries.filter { store.chartedEntryIDs.contains($0.id) }
        case "Favorites": return store.entries.filter { store.starredEntryIDs.contains($0.id) }
        case "Archive": return store.entries
        default: return store.entries.filter { store.vaultedEntryIDs.contains($0.id) }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                let entry = items[index]
                NavigationLink {
                    DetailView(entry: entry)
                } label: {
                    HStack(spacing: 13) {
                        Image(entry.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 5) {
                            Text(entry.title)
                                .font(.headline)
                            Text(entry.hook)
                                .font(.caption)
                                .foregroundStyle(Color.nvMuted)
                                .lineLimit(2)
                            Text(entry.category)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.cyan)
                        }
                        Spacer()
                        Image(systemName: store.vaultedEntryIDs.contains(entry.id) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(Color.nvPink)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.045))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ArchiveView: View {
    @EnvironmentObject private var store: NVCuriosityAtlas
    private let days = Array(1...31)
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 16) {
            Text("MAY 2024")
                .font(.headline)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Text("\(day)")
                        .font(.caption.weight(.bold))
                        .frame(width: 34, height: 34)
                        .background(day == 22 ? Color.white.opacity(0.16) : (day % 3 == 0 || day % 5 == 0 ? Color.nvPink.opacity(0.55) : Color.white.opacity(0.06)))
                        .clipShape(Circle())
                }
            }
            HStack(spacing: 12) {
                Image(store.today.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading) {
                    Text("Today's Wonder").font(.caption).foregroundStyle(Color.nvPink)
                    Text(store.today.title).font(.headline)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill").font(.title2).foregroundStyle(Color.nvPink)
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct DiscoveryCard: View {
    let entry: NVCuriosityEntry
    let large: Bool
    var height: CGFloat? = nil
    private var resolvedHeight: CGFloat { height ?? (large ? 330 : 220) }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                Image(entry.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: resolvedHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                LinearGradient(colors: [.black.opacity(0.08), .black.opacity(0.2), .black.opacity(0.88)], startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.title)
                        .font(.system(size: large ? 26 : 22, weight: .bold, design: .serif))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(entry.hook)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    TagRow(entry: entry)
                }
                .padding(16)
            }
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.nvPink, lineWidth: 1.3))
            .shadow(color: .nvPink.opacity(0.24), radius: 14)
        }
        .frame(height: resolvedHeight)
    }
}

struct CategoryTile: View {
    let category: NVDiscoveryShelf

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                Image(category.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                LinearGradient(colors: [.clear, .black.opacity(0.82)], startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title).font(.subheadline.weight(.bold)).lineLimit(2)
                    Text("\(category.count) wonders").font(.caption).foregroundStyle(Color.nvMuted)
                }
                .padding(12)
            }
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12)))
        }
        .frame(height: 150)
    }
}

struct DashboardStrip: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            StatTile(title: "Signal Draw", value: "Ready", icon: "sparkles")
            StatTile(title: "Daily Streak", value: "12 days", icon: "flame")
            StatTile(title: "Saved This Week", value: "7 cards", icon: "bookmark")
            StatTile(title: "Quiz Progress", value: "2 / 10", icon: "questionmark.circle")
        }
    }
}

struct ProfileCard: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image("MysteryMask")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 76, height: 76)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.nvPink, lineWidth: 2))
                VStack(alignment: .leading, spacing: 6) {
                    Text("NV Wonder Seeker").font(.headline)
                    Text("Level 7").foregroundStyle(Color.nvMuted)
                    ProgressView(value: 0.52).tint(.nvPink)
                }
            }
            Divider().overlay(Color.white.opacity(0.12))
            StatLine(label: "Curiosities Seen", value: "87", icon: "eye")
            StatLine(label: "Saved Cards", value: "36", icon: "bookmark")
            StatLine(label: "Favorites", value: "18", icon: "heart")
            StatLine(label: "Daily Streak", value: "12 days", icon: "flame")
            StatLine(label: "Quizzes Completed", value: "7", icon: "trophy")
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct NVLogo: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("N").font(.system(size: 34, weight: .black))
            Text("V").font(.system(size: 34, weight: .black)).foregroundStyle(Color.nvPink)
            Text("CURIOSITIES")
                .font(.system(size: 18, weight: .medium))
                .tracking(4)
        }
    }
}

struct HeaderBar: View {
    let title: String
    let subtitle: String?
    let trailing: String?
    let badge: String?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .tracking(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.nvPink)
                        .tracking(0.8)
                }
            }
            Spacer()
            if let trailing {
                HStack(spacing: 5) {
                    Image(systemName: trailing)
                    if let badge { Text(badge).font(.caption.weight(.bold)) }
                }
                .padding(10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(trailing.contains("flame") ? .orange : .white)
            }
        }
    }
}

struct TagRow: View {
    let entry: NVCuriosityEntry

    var body: some View {
        HStack {
            Tag(text: entry.category, color: .cyan)
            Tag(text: entry.rarity, color: .purple)
            Spacer()
            Text(entry.readTime)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
        }
    }
}

struct Tag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .foregroundStyle(color)
            .background(color.opacity(0.15))
            .overlay(Capsule().stroke(color.opacity(0.75)))
            .clipShape(Capsule())
    }
}

struct PrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title.uppercased())
                    .font(.subheadline.weight(.bold))
                Image(systemName: icon)
                Spacer()
            }
            .padding(.vertical, 17)
            .background(LinearGradient(colors: [.nvPink, .pink.opacity(0.85)], startPoint: .leading, endPoint: .trailing))
            .clipShape(Capsule())
            .shadow(color: .nvPink.opacity(0.4), radius: 18)
        }
        .buttonStyle(.plain)
    }
}

struct PickerPills: View {
    let items: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Button(item) { selection = item }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(selection == item ? Color.nvPink : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

struct MoodButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(selected ? Color.nvPink : .nvMuted)
            .background(selected ? Color.nvPink.opacity(0.16) : Color.white.opacity(0.055))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(selected ? Color.nvPink : Color.white.opacity(0.12)))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var icon: String {
        switch title {
        case "Beautiful": return "diamond"
        case "Creepy": return "skull"
        case "Ancient": return "building.columns"
        case "Funny": return "face.smiling"
        default: return "dial.low"
        }
    }
}

struct QuizChoice: View {
    let index: Int
    let choice: String
    let selected: Bool
    let correct: Bool
    let answered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(["A", "B", "C", "D"][index])
                    .font(.caption.bold())
                    .frame(width: 26, height: 26)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                Text(choice).font(.headline)
                Spacer()
            }
            .padding()
            .background(background)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12)))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(answered)
    }

    private var background: Color {
        if answered && correct { return .green.opacity(0.72) }
        if selected { return .nvPink.opacity(0.55) }
        return .white.opacity(0.045)
    }
}

struct ResultPanel: View {
    let correct: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image("MysteryMask")
                .resizable()
                .scaledToFill()
                .frame(width: 76, height: 76)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(correct ? "Correct!" : "Almost!")
                    .font(.title3.bold())
                    .foregroundStyle(correct ? .green : .orange)
                Text("The Blood Falls in Antarctica gets its red color from iron-rich water reacting with oxygen.")
                    .font(.caption)
                    .foregroundStyle(Color.nvMuted)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct FactRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(Color.nvMuted)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1) }
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(Color.nvPink)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(Color.nvMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StatLine: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon).frame(width: 20).foregroundStyle(Color.nvMuted)
            Text(label).font(.caption)
            Spacer()
            Text(value).font(.headline)
        }
    }
}

struct Badge: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 52, height: 52)
                .background(LinearGradient(colors: [.orange, .nvPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Hexagon())
                .shadow(color: .nvPink.opacity(0.34), radius: 12)
            Text(title)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.bold))
            .tracking(0.8)
            .foregroundStyle(Color.nvPink)
    }
}

struct CircleAction: View {
    let system: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.title3)
                .frame(width: 48, height: 48)
                .background(system.contains("cube") ? Color.nvPink.opacity(0.22) : Color.white.opacity(0.08))
                .overlay(Circle().stroke(system.contains("cube") ? Color.nvPink : Color.white.opacity(0.1)))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct BottomAction: View {
    let active: Bool
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .frame(width: 48, height: 48)
                .background(active ? Color.nvPink : Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct NVBackground: View {
    var body: some View {
        LinearGradient(colors: [Color(red: 0.015, green: 0.014, blue: 0.045), Color(red: 0.06, green: 0.035, blue: 0.11), Color(red: 0.015, green: 0.014, blue: 0.045)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                RadialGradient(colors: [Color.nvPink.opacity(0.22), .clear], center: .center, startRadius: 0, endRadius: 210)
                    .frame(width: 320, height: 320)
                    .offset(x: 130, y: -130)
            }
            .overlay(alignment: .bottomLeading) {
                RadialGradient(colors: [Color.cyan.opacity(0.13), .clear], center: .center, startRadius: 0, endRadius: 240)
                    .frame(width: 360, height: 360)
                    .offset(x: -170, y: 150)
            }
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let points = stride(from: 0, to: 6, by: 1).map { index -> CGPoint in
            let angle = CGFloat(index) * .pi / 3 - .pi / 2
            return CGPoint(x: rect.midX + cos(angle) * rect.width * 0.46, y: rect.midY + sin(angle) * rect.height * 0.46)
        }
        var path = Path()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}

extension Color {
    static let nvPink = Color(red: 1.0, green: 0.05, blue: 0.43)
    static let nvMuted = Color.white.opacity(0.68)
}

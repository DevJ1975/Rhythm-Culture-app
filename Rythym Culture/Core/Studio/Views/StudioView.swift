// StudioView.swift
// Studio tab — Masterclasses · Store · Coaching · Consulting · Shows

import SwiftUI

private enum StudioTab: String, CaseIterable, Identifiable {
    case masterclasses = "Masterclasses"
    case store         = "Store"
    case coaching      = "Coaching"
    case consulting    = "Consulting"
    case shows         = "Shows"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .masterclasses: return "play.rectangle.fill"
        case .store:         return "cart.fill"
        case .coaching:      return "figure.dance"
        case .consulting:    return "briefcase.fill"
        case .shows:         return "theatermasks.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .masterclasses: return [.purple, .pink]
        case .store:         return [.indigo, .purple]
        case .coaching:      return [.orange, .pink]
        case .consulting:    return [.blue, .cyan]
        case .shows:         return [.red, .orange]
        }
    }
}

struct StudioView: View {
    @State private var selectedTab: StudioTab = .masterclasses

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Scrollable tab strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(StudioTab.allCases) { tab in
                            studioTabChip(tab)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                Divider()

                // Content
                Group {
                    switch selectedTab {
                    case .masterclasses: MasterclassHubView()
                    case .store:         StoreHubView()
                    case .coaching:      CoachingHubView()
                    case .consulting:    ConsultingHubView()
                    case .shows:         ShowCreationHubView()
                    }
                }
                .id(selectedTab)
            }
            .navigationTitle("Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: { Image(systemName: "plus").foregroundStyle(.primary) }
                }
            }
        }
    }

    private func studioTabChip(_ tab: StudioTab) -> some View {
        let isSelected = selectedTab == tab
        return Button { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = tab } } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon).font(.caption)
                Text(tab.rawValue).font(.subheadline)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(isSelected
                ? AnyShapeStyle(LinearGradient(colors: tab.gradient, startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(Color(.systemGray5)))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Masterclass Hub
struct MasterclassHubView: View {
    @State private var selectedFilter: ArtistType? = nil
    private let classes = MockData.masterclasses

    var filtered: [Masterclass] {
        guard let f = selectedFilter else { return classes }
        return classes.filter { $0.artistType == f }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // RC Revenue note
                HStack(spacing: 10) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title2).foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Teach & Earn")
                            .font(.subheadline.bold())
                        Text("You keep 80% · RC keeps 20%")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Start Teaching") {}
                        .font(.caption.bold())
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
                .padding(14)
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        filterChip(label: "All", isSelected: selectedFilter == nil) { selectedFilter = nil }
                        ForEach([ArtistType.dancer, .singer, .rapper, .dj, .producer]) { type in
                            filterChip(label: type.rawValue, isSelected: selectedFilter == type) { selectedFilter = type }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Class cards
                LazyVStack(spacing: 16) {
                    ForEach(filtered) { masterclass in
                        NavigationLink(destination: MasterclassDetailView(masterclass: masterclass)) {
                            MasterclassCardView(masterclass: masterclass)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .padding(.top, 16)
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isSelected ? AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color(.systemGray5)))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct MasterclassCardView: View {
    let masterclass: Masterclass

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            RemoteImage(url: masterclass.thumbnailURL)
                .frame(height: 180)
                .clipped()
                .overlay(alignment: .topLeading) {
                    Text(masterclass.artistType.emoji + " " + masterclass.artistType.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(10)
                }

            VStack(alignment: .leading, spacing: 8) {
                // Instructor row
                HStack(spacing: 8) {
                    RemoteImage(url: masterclass.instructorImageURL)
                        .frame(width: 28, height: 28).clipShape(Circle())
                    Text(masterclass.instructorDisplayName)
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(masterclass.tags.prefix(1).joined())
                        .font(.caption2).foregroundStyle(.secondary)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }

                Text(masterclass.title)
                    .font(.headline)

                HStack(spacing: 16) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.caption).foregroundStyle(.yellow)
                        Text(String(format: "%.1f", masterclass.rating)).font(.caption.bold())
                        Text("(\(masterclass.reviewCount.shortFormatted()))").font(.caption).foregroundStyle(.secondary)
                    }
                    Text("·").foregroundStyle(.secondary)
                    Text("\(masterclass.lessonCount) lessons").font(.caption).foregroundStyle(.secondary)
                    Text("·").foregroundStyle(.secondary)
                    Text(masterclass.formattedDuration).font(.caption).foregroundStyle(.secondary)
                }

                HStack {
                    Text(masterclass.enrolledCount.shortFormatted() + " enrolled")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "$%.0f", masterclass.price))
                        .font(.title3.bold())
                }
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 3)
    }
}

// MARK: - Masterclass Detail
struct MasterclassDetailView: View {
    let masterclass: Masterclass
    @State private var showEnrollAlert = false
    @State private var isEnrolled = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RemoteImage(url: masterclass.thumbnailURL)
                    .frame(height: 220).clipped()

                VStack(alignment: .leading, spacing: 16) {
                    Text(masterclass.title).font(.title2.bold())

                    HStack(spacing: 8) {
                        RemoteImage(url: masterclass.instructorImageURL)
                            .frame(width: 40, height: 40).clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(masterclass.instructorDisplayName).font(.subheadline.bold())
                            Text(masterclass.artistType.rawValue).font(.caption).foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 16) {
                        Label(String(format: "%.1f", masterclass.rating), systemImage: "star.fill")
                            .font(.subheadline).foregroundStyle(.yellow)
                        Label("\(masterclass.enrolledCount.shortFormatted()) enrolled", systemImage: "person.2")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Label(masterclass.formattedDuration, systemImage: "clock")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }

                    Divider()
                    Text("About This Class").font(.headline)
                    Text(masterclass.description).font(.subheadline).foregroundStyle(.secondary)

                    Divider()
                    Text("\(masterclass.lessonCount) Lessons").font(.headline)

                    ForEach(1...masterclass.lessonCount, id: \.self) { i in
                        HStack {
                            Text("\(i)").font(.caption).foregroundStyle(.secondary).frame(width: 24)
                            Text("Lesson \(i)").font(.subheadline)
                            Spacer()
                            Image(systemName: "lock").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                        Divider()
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                Text("Rhythm Culture earns 20% · You keep 80%")
                    .font(.caption2).foregroundStyle(.secondary)
                Button {
                    if !isEnrolled { showEnrollAlert = true }
                } label: {
                    Text(isEnrolled ? "Enrolled ✓" : "Enroll for \(String(format: "$%.0f", masterclass.price))")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity).padding()
                        .background(isEnrolled ? AnyShapeStyle(Color.green) : AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20).padding(.bottom, 8)
            }
            .background(.ultraThinMaterial)
        }
        .confirmationDialog("Enroll in \(masterclass.title)?", isPresented: $showEnrollAlert, titleVisibility: .visible) {
            Button("Enroll for $\(String(format: "%.0f", masterclass.price))") { isEnrolled = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Rhythm Culture earns 20% of this purchase. The instructor receives 80%.")
        }
    }
}

// MARK: - Store Hub
struct StoreHubView: View {
    @State private var selectedType: StoreItemType? = nil
    @State private var selectedTier: SellerTier? = nil
    private let items = MockData.storeItems

    var elitePicks: [StoreItem] { items.filter { $0.sellerTier == .elite } }

    var filtered: [StoreItem] {
        items.filter { item in
            (selectedType == nil || item.type == selectedType) &&
            (selectedTier == nil || item.sellerTier == selectedTier)
        }
    }

    var showElitePicks: Bool { selectedTier == nil && selectedType == nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Header banner
                HStack(spacing: 10) {
                    Image(systemName: "cart.fill").font(.title2).foregroundStyle(.purple)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sell Your Work")
                            .font(.subheadline.bold())
                        Text("Elite 90% · Established 87% · Up & Coming 85%")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("List Item") {}
                        .font(.caption.bold())
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.purple.opacity(0.12))
                        .foregroundStyle(.purple)
                        .clipShape(Capsule())
                }
                .padding(14)
                .background(Color.purple.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                // Tier filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        tierChip(tier: nil)
                        ForEach(SellerTier.allCases.reversed()) { tier in
                            tierChip(tier: tier)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Type filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        typeChip(label: "All Types", icon: "square.grid.2x2", type: nil)
                        ForEach(StoreItemType.allCases, id: \.self) { t in
                            typeChip(label: t.rawValue, icon: t.icon, type: t)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Elite Picks featured strip
                if showElitePicks && !elitePicks.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .font(.subheadline).foregroundStyle(SellerTier.elite.color)
                                Text("Elite Picks")
                                    .font(.headline.bold())
                            }
                            Spacer()
                            Button("See All") {
                                withAnimation { selectedTier = .elite }
                            }
                            .font(.caption.bold()).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(elitePicks) { item in
                                    NavigationLink(destination: StoreItemDetailView(item: item)) {
                                        ElitePickCardView(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    Divider().padding(.horizontal, 16)
                }

                // Main list
                LazyVStack(spacing: 14) {
                    ForEach(filtered) { item in
                        NavigationLink(destination: StoreItemDetailView(item: item)) {
                            StoreItemCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .padding(.top, 16)
        }
    }

    private func tierChip(tier: SellerTier?) -> some View {
        let isSelected = selectedTier == tier
        let label = tier.map { "\($0.emoji) \($0.label)" } ?? "All Tiers"
        let grad = tier?.gradient ?? [Color(.systemGray4), Color(.systemGray4)]
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTier = tier }
        } label: {
            Text(label).font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected
                    ? AnyShapeStyle(LinearGradient(colors: grad, startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color(.systemGray5)))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    private func typeChip(label: String, icon: String, type: StoreItemType?) -> some View {
        let isSelected = selectedType == type
        return Button { selectedType = type } label: {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption)
                Text(label).font(.subheadline)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(isSelected ? AnyShapeStyle(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color(.systemGray5)))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Elite Pick Card (compact horizontal)
struct ElitePickCardView: View {
    let item: StoreItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RemoteImage(url: item.thumbnailURL)
                    .frame(width: 160, height: 110)
                    .clipped()
                SellerTierBadgeView(tier: item.sellerTier, compact: true)
                    .padding(6)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.caption.bold()).lineLimit(1)
                Text(item.sellerDisplayName).font(.caption2).foregroundStyle(.secondary)
                Text(item.price == 0 ? "Free" : String(format: "$%.2f", item.price))
                    .font(.caption.bold()).foregroundStyle(.purple)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
        }
        .frame(width: 160)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Store Item Card
struct StoreItemCardView: View {
    let item: StoreItem
    @State private var isPlaying = false

    var licenseColor: Color {
        switch item.licenseType {
        case .exclusive:    return .yellow
        case .unlimited:    return .purple
        case .nonExclusive: return .blue
        case .free:         return .green
        case nil:           return .gray
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RemoteImage(url: item.thumbnailURL)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                if item.type == .beat || item.type == .musicTrack || item.type == .sample {
                    Button {
                        withAnimation { isPlaying.toggle() }
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.55))
                            .clipShape(Circle())
                    }
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(item.title).font(.subheadline.bold()).lineLimit(1)

                // Seller name + tier badge
                HStack(spacing: 6) {
                    Text(item.sellerUsername).font(.caption).foregroundStyle(.secondary)
                    SellerTierBadgeView(tier: item.sellerTier, compact: true)
                    if let genre = item.genre {
                        Text("·").foregroundStyle(.secondary)
                        Text(genre).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                }

                HStack(spacing: 8) {
                    if let bpm = item.bpm {
                        Text("\(bpm) BPM")
                            .font(.caption2).foregroundStyle(.secondary)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    if let key = item.keySignature {
                        Text(key)
                            .font(.caption2).foregroundStyle(.secondary)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    if let license = item.licenseType {
                        Text(license.rawValue)
                            .font(.caption2.bold()).foregroundStyle(licenseColor)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(licenseColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                HStack {
                    Text(item.playCount.shortFormatted() + " plays")
                        .font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                    Text(item.price == 0 ? "Free" : String(format: "$%.2f", item.price))
                        .font(.subheadline.bold())
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        // Gold border for Elite sellers
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(item.sellerTier == .elite ? SellerTier.elite.color.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - Store Item Detail
struct StoreItemDetailView: View {
    let item: StoreItem
    @State private var selectedLicense: LicenseType = .nonExclusive
    @State private var isPurchased = false
    @State private var showConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RemoteImage(url: item.thumbnailURL)
                    .frame(height: 220).clipped()

                VStack(alignment: .leading, spacing: 14) {
                    Text(item.title).font(.title2.bold())

                    // Seller row with tier badge
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.sellerDisplayName).font(.subheadline.bold())
                            SellerTierBadgeView(tier: item.sellerTier)
                        }
                        Spacer()
                        Text(item.type.rawValue)
                            .font(.caption.bold())
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }

                    if let bpm = item.bpm, let key = item.keySignature {
                        HStack(spacing: 16) {
                            Label("\(bpm) BPM", systemImage: "waveform").font(.subheadline)
                            Label(key, systemImage: "music.note").font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }

                    Text(item.description).font(.subheadline).foregroundStyle(.secondary)

                    if item.type == .beat || item.type == .musicTrack {
                        Divider()
                        Text("License Type").font(.headline)

                        ForEach([LicenseType.nonExclusive, .exclusive, .unlimited], id: \.self) { license in
                            Button { selectedLicense = license } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(license.rawValue).font(.subheadline.bold())
                                        Text(licenseDescription(license)).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if selectedLicense == license {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.purple)
                                    }
                                }
                                .padding(12)
                                .background(selectedLicense == license ? Color.purple.opacity(0.08) : Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedLicense == license ? Color.purple : Color.clear, lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Seller Tier card
                    Divider()
                    Text("About This Seller").font(.headline)
                    SellerTierCardView(
                        tier: item.sellerTier,
                        showPerks: true,
                        nextTierRequirement: item.sellerTier.nextTierRequirement
                    )

                    HStack(spacing: 4) {
                        Image(systemName: "cart").font(.caption).foregroundStyle(.secondary)
                        Text("\(item.purchaseCount.shortFormatted()) purchases · \(item.sellerTier.splitLabel)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                Text(item.sellerTier.splitLabel)
                    .font(.caption2).foregroundStyle(.secondary)
                Button { showConfirm = true } label: {
                    Text(isPurchased ? "Purchased ✓" : "Buy for \(String(format: "$%.2f", item.price))")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity).padding()
                        .background(isPurchased ? AnyShapeStyle(Color.green) : AnyShapeStyle(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20).padding(.bottom, 8)
            }
            .background(.ultraThinMaterial)
        }
        .confirmationDialog("Purchase \(item.title)?", isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Buy for $\(String(format: "%.2f", item.price))") { isPurchased = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(item.sellerTier.splitLabel). \(item.sellerDisplayName) is a \(item.sellerTier.label) seller.")
        }
    }

    private func licenseDescription(_ license: LicenseType) -> String {
        switch license {
        case .nonExclusive: return "Use on unlimited projects. Beat stays in store."
        case .exclusive:    return "You own it. Removed from store after purchase."
        case .unlimited:    return "Unlimited use — streaming, video, live. No royalties."
        case .free:         return "Free to download and use."
        }
    }
}

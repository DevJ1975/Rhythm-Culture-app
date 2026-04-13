// ShowCreationHubView.swift
// Show Creation & IP Licensing — catalog, tier selection, and co-creation agreement flow.

import SwiftUI

// MARK: - Hub (Catalog)
struct ShowCreationHubView: View {
    @State private var selectedScale: ShowScale? = nil
    private let listings = MockData.showListings

    var filtered: [ShowListing] {
        guard let s = selectedScale else { return listings }
        return listings.filter { $0.scale == s || $0.scale == .any }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Revenue banner
                HStack(spacing: 10) {
                    Image(systemName: "theatermasks.fill").font(.title2).foregroundStyle(.purple)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("License Your Show IP").font(.subheadline.bold())
                        Text("Sell your show concepts as licensable IP — you keep 85%")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Create Show") {}
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

                // License tier legend
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ShowLicenseTier.allCases) { tier in
                            HStack(spacing: 5) {
                                Image(systemName: tier.icon).font(.caption)
                                Text(tier.rawValue).font(.caption.bold())
                            }
                            .foregroundStyle(tier.color)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(tier.color.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Scale filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        scaleChip("All Scales", scale: nil)
                        ForEach(ShowScale.allCases) { scale in
                            scaleChip(scale.rawValue, scale: scale)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Show listings
                LazyVStack(spacing: 16) {
                    ForEach(filtered) { show in
                        NavigationLink(destination: ShowListingDetailView(show: show)) {
                            ShowCardView(show: show)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
    }

    private func scaleChip(_ label: String, scale: ShowScale?) -> some View {
        let isSelected = selectedScale == scale
        return Button { selectedScale = scale } label: {
            Text(label).font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected
                    ? AnyShapeStyle(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color(.systemGray5)))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Show Card
struct ShowCardView: View {
    let show: ShowListing

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Mood board image
            RemoteImage(url: show.moodBoardURLs.first ?? "")
                .frame(height: 180).clipped()
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill").font(.caption)
                        Text(show.scale.rawValue + " · " + show.scale.capacity)
                    }
                    .font(.caption.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(10)
                }
                .overlay(alignment: .bottomLeading) {
                    // Active concept licenses count
                    if show.activeConceptLicenses > 0 {
                        Text("\(show.activeConceptLicenses) active concept licenses")
                            .font(.caption2.bold()).foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding(10)
                    }
                }

            VStack(alignment: .leading, spacing: 10) {
                // Creator row
                HStack(spacing: 8) {
                    RemoteImage(url: show.sellerImageURL)
                        .frame(width: 28, height: 28).clipShape(Circle())
                    Text(show.sellerDisplayName).font(.caption).foregroundStyle(.secondary)
                    Spacer()
                }

                Text(show.title).font(.headline)
                Text(show.description).font(.caption).foregroundStyle(.secondary).lineLimit(2)

                // Genre tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(show.genreTags.prefix(3), id: \.self) { tag in
                            Text(tag).font(.caption2)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }

                // Available tier badges
                HStack(spacing: 6) {
                    Text("Tiers:").font(.caption2).foregroundStyle(.secondary)
                    ForEach(show.tiersAvailable) { tier in
                        Text(tier.tier.rawValue)
                            .font(.caption2.bold()).foregroundStyle(tier.tier.color)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(tier.tier.color.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                // Price range
                let prices = show.tiersAvailable.compactMap(\.price)
                if let min = prices.min() {
                    HStack {
                        Spacer()
                        Text("From $\(Int(min).shortFormatted())")
                            .font(.subheadline.bold())
                    }
                }
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 3)
    }
}

// MARK: - Show Detail
struct ShowListingDetailView: View {
    let show: ShowListing
    @State private var selectedTier: ShowTier? = nil
    @State private var showLicenseFlow = false
    @State private var moodBoardPage = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Mood board carousel
                TabView(selection: $moodBoardPage) {
                    ForEach(show.moodBoardURLs.indices, id: \.self) { i in
                        RemoteImage(url: show.moodBoardURLs[i])
                            .frame(height: 240).clipped()
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 240)

                VStack(alignment: .leading, spacing: 18) {
                    // Creator info
                    HStack(spacing: 12) {
                        RemoteImage(url: show.sellerImageURL)
                            .frame(width: 44, height: 44).clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(show.sellerDisplayName).font(.subheadline.bold())
                            Text("Show Creator").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(show.scale.rawValue)
                            .font(.caption.bold())
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }

                    Text(show.title).font(.title2.bold())
                    Text(show.description).font(.subheadline).foregroundStyle(.secondary)

                    // Genre + scale
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(show.genreTags, id: \.self) { tag in
                                Text(tag).font(.caption)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    // Transparency
                    if show.activeConceptLicenses > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle").foregroundStyle(.secondary)
                            Text("\(show.activeConceptLicenses) other buyers hold Concept Only licenses for this show.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Divider()

                    // License tiers
                    Text("Choose a License").font(.headline)
                    VStack(spacing: 12) {
                        ForEach(show.tiersAvailable) { tier in
                            tierCard(tier)
                        }
                    }

                    Text("Artist keeps 85% · RC keeps 15% on all show licenses.")
                        .font(.caption).foregroundStyle(.secondary)

                    Spacer(minLength: 80)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button { if selectedTier != nil { showLicenseFlow = true } } label: {
                Text(selectedTier == nil ? "Select a License Tier" : "License: \(selectedTier!.tier.rawValue)")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity).padding()
                    .background(selectedTier == nil
                        ? AnyShapeStyle(Color(.systemGray4))
                        : AnyShapeStyle(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedTier == nil)
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showLicenseFlow) {
            if let tier = selectedTier {
                LicenseAgreementSheet(show: show, tier: tier)
            }
        }
    }

    private func tierCard(_ tier: ShowTier) -> some View {
        let isSelected = selectedTier?.id == tier.id
        return Button { selectedTier = tier } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: tier.tier.icon).foregroundStyle(tier.tier.color)
                        Text(tier.tier.rawValue).font(.subheadline.bold())
                    }
                    Spacer()
                    if tier.isNegotiated {
                        Text("Negotiated").font(.caption.bold()).foregroundStyle(.orange)
                    } else if let price = tier.price {
                        Text("$\(Int(price).shortFormatted())").font(.subheadline.bold())
                    }
                }

                Text(tier.tier.subtitle).font(.caption).foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    if let territory = tier.territory {
                        Label(territory, systemImage: "globe").font(.caption2).foregroundStyle(.secondary)
                    }
                    if tier.exclusiveOptionAvailable, let ep = tier.exclusivePrice {
                        Label("Exclusive: $\(Int(ep).shortFormatted())", systemImage: "lock").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
            .background(isSelected ? tier.tier.color.opacity(0.08) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? tier.tier.color : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - License Agreement Sheet
struct LicenseAgreementSheet: View {
    let show: ShowListing
    let tier: ShowTier
    @Environment(\.dismiss) private var dismiss

    @State private var sellerSplit = 60
    @State private var isSigned = false
    @State private var isExclusive = false

    var isCoCreation: Bool { tier.tier == .coCreation }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isSigned {
                        signedConfirmation
                    } else {
                        agreementContent
                    }
                }
                .padding(20)
            }
            .navigationTitle(isCoCreation ? "Co-Creation Agreement" : "License Agreement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !isSigned {
                    Button { isSigned = true } label: {
                        Text(isCoCreation ? "Sign & Begin Co-Creation" : "Confirm License Purchase")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity).padding()
                            .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                }
            }
        }
    }

    private var agreementContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Summary card
            VStack(alignment: .leading, spacing: 8) {
                Text("License Summary").font(.headline)
                agreementRow("Show", show.title)
                agreementRow("Creator", show.sellerDisplayName)
                agreementRow("Tier", tier.tier.rawValue)
                if !isCoCreation, let price = tier.price {
                    agreementRow("License Fee", "$\(Int(price).shortFormatted())")
                    agreementRow("Creator receives (85%)", "$\(Int(price * 0.85).shortFormatted())")
                    agreementRow("Platform fee (15%)", "$\(Int(price * 0.15).shortFormatted())")
                }
                if let territory = tier.territory {
                    agreementRow("Territory", territory)
                }
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Exclusive option
            if tier.exclusiveOptionAvailable, let ep = tier.exclusivePrice {
                Toggle(isOn: $isExclusive) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Make Exclusive (+$\(Int(ep).shortFormatted()))").font(.subheadline.bold())
                        Text("Removes this concept from the store after purchase.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Co-creation IP split
            if isCoCreation {
                VStack(alignment: .leading, spacing: 12) {
                    Text("IP Ownership Split").font(.headline)
                    Text("Propose how intellectual property ownership is divided between you and \(show.sellerDisplayName).")
                        .font(.caption).foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        HStack {
                            Text(show.sellerDisplayName)
                            Spacer()
                            Text("\(sellerSplit)%").font(.headline.bold()).foregroundStyle(.purple)
                        }
                        Slider(value: Binding(
                            get: { Double(sellerSplit) },
                            set: { sellerSplit = Int($0) }
                        ), in: 10...90, step: 5)
                        .tint(.purple)
                        HStack {
                            Text("Your share")
                            Spacer()
                            Text("\(100 - sellerSplit)%").font(.headline.bold()).foregroundStyle(.indigo)
                        }
                    }
                    .padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("⚠️ This agreement requires legal review before activation. Rhythm Culture will notify both parties within 48 hours.")
                        .font(.caption).foregroundStyle(.orange)
                        .padding(10)
                        .background(Color.orange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            // Terms
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Terms").font(.headline)
                termRow("Creator retains original creator credit in all productions.")
                termRow("Buyer may not sublicense without written creator consent.")
                termRow(tier.tier == .conceptOnly
                    ? "Buyer receives conceptual framework only — not production materials."
                    : "Buyer receives full production materials as listed in the tier.")
                if isCoCreation {
                    termRow("Co-creation IP split is binding and recorded on the Rhythm Culture platform.")
                }
                termRow("Disputes are handled through Rhythm Culture's arbitration process.")
            }
        }
    }

    private var signedConfirmation: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64)).foregroundStyle(.purple)
            Text(isCoCreation ? "Co-Creation Initiated" : "License Activated").font(.title2.bold())
            Text(isCoCreation
                ? "\(show.sellerDisplayName) has been notified of your co-creation proposal. You'll hear back within 48 hours."
                : "Your license for \"\(show.title)\" is now active. A signed agreement has been saved to your Library.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Done") { dismiss() }
                .font(.headline.bold())
                .frame(maxWidth: .infinity).padding()
                .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .frame(maxWidth: .infinity)
    }

    private func agreementRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.bold())
        }
    }

    private func termRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5)).foregroundStyle(.secondary).padding(.top, 6)
            Text(text).font(.caption).foregroundStyle(.secondary)
        }
    }
}

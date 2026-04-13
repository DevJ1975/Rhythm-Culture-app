// CoachingHubView.swift
// Choreography & Movement Coaching — browse, detail, and booking flow.

import SwiftUI

// MARK: - Hub (Browse)
struct CoachingHubView: View {
    @State private var selectedStyle: String? = nil
    @State private var selectedFormat: CoachingFormatType? = nil
    private let listings = MockData.coachingListings

    private var allStyles: [String] {
        Array(Set(listings.flatMap(\.styleTags))).sorted()
    }

    var filtered: [CoachingListing] {
        listings.filter { listing in
            let styleMatch = selectedStyle == nil || listing.styleTags.contains(selectedStyle!)
            let formatMatch = selectedFormat == nil || listing.formats.contains(where: { $0.type == selectedFormat })
            return styleMatch && formatMatch
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Revenue banner
                revenueBanner

                // Format filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        formatChip(label: "All Sessions", format: nil)
                        ForEach(CoachingFormatType.allCases) { format in
                            formatChip(label: format.rawValue, format: format)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Listings
                LazyVStack(spacing: 16) {
                    ForEach(filtered) { listing in
                        NavigationLink(destination: CoachingDetailView(listing: listing)) {
                            CoachingCardView(listing: listing)
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

    private var revenueBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "figure.dance").font(.title2).foregroundStyle(.pink)
            VStack(alignment: .leading, spacing: 2) {
                Text("Offer Coaching").font(.subheadline.bold())
                Text("You keep 85% of every session booked")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Create Listing") {}
                .font(.caption.bold())
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.pink.opacity(0.12))
                .foregroundStyle(.pink)
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color.pink.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func formatChip(label: String, format: CoachingFormatType?) -> some View {
        let isSelected = selectedFormat == format
        return Button { selectedFormat = format } label: {
            HStack(spacing: 5) {
                if let f = format {
                    Image(systemName: f.icon).font(.caption)
                }
                Text(label).font(.subheadline)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(isSelected
                ? AnyShapeStyle(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(Color(.systemGray5)))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Coaching Card
struct CoachingCardView: View {
    let listing: CoachingListing

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            RemoteImage(url: listing.thumbnailURL)
                .frame(height: 160).clipped()
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 4) {
                        ForEach(listing.formats) { format in
                            Image(systemName: format.type.icon)
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(8)
                }

            VStack(alignment: .leading, spacing: 8) {
                // Coach row
                HStack(spacing: 8) {
                    RemoteImage(url: listing.sellerImageURL)
                        .frame(width: 30, height: 30).clipShape(Circle())
                    Text(listing.sellerDisplayName).font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                        Text(String(format: "%.1f", listing.rating)).font(.caption.bold())
                        Text("(\(listing.reviewCount.shortFormatted()))").font(.caption2).foregroundStyle(.secondary)
                    }
                }

                Text(listing.title).font(.headline)

                // Style tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(listing.styleTags.prefix(3), id: \.self) { tag in
                            Text(tag).font(.caption2)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }

                HStack {
                    Text("\(listing.totalStudents.shortFormatted()) students")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text("From $\(Int(listing.startingPrice))")
                        .font(.subheadline.bold())
                }
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 3)
    }
}

// MARK: - Coaching Detail
struct CoachingDetailView: View {
    let listing: CoachingListing
    @State private var selectedFormat: CoachingFormat?
    @State private var showBookingSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RemoteImage(url: listing.thumbnailURL)
                    .frame(height: 220).clipped()

                VStack(alignment: .leading, spacing: 18) {
                    // Coach info
                    HStack(spacing: 12) {
                        RemoteImage(url: listing.sellerImageURL)
                            .frame(width: 52, height: 52).clipShape(Circle())
                            .overlay(Circle().stroke(listing.sellerArtistType.color, lineWidth: 2))
                        VStack(alignment: .leading) {
                            Text(listing.sellerDisplayName).font(.headline)
                            Text(listing.sellerArtistType.emoji + " " + listing.sellerArtistType.rawValue)
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundStyle(.yellow)
                            Text(String(format: "%.1f", listing.rating)).font(.subheadline.bold())
                            Text("· \(listing.reviewCount.shortFormatted()) reviews").font(.caption).foregroundStyle(.secondary)
                        }
                    }

                    Text(listing.title).font(.title2.bold())
                    Text(listing.description).font(.subheadline).foregroundStyle(.secondary)

                    Divider()

                    // Format selector
                    Text("Choose a Format").font(.headline)
                    VStack(spacing: 10) {
                        ForEach(listing.formats) { format in
                            formatRow(format)
                        }
                    }

                    Divider()

                    // Verified credits
                    Text("Verified Credits").font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(listing.verifiedCredits, id: \.self) { credit in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(.blue).font(.caption)
                                Text(credit).font(.subheadline)
                            }
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                if let f = selectedFormat {
                    Text("You keep 85% · RC keeps 15%")
                        .font(.caption2).foregroundStyle(.secondary)
                    Button { showBookingSheet = true } label: {
                        Text("Book \(f.type.rawValue) — $\(Int(f.price))")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity).padding()
                            .background(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    Text("Select a format above to book")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showBookingSheet) {
            if let format = selectedFormat {
                CoachingBookingView(listing: listing, format: format)
            }
        }
    }

    private func formatRow(_ format: CoachingFormat) -> some View {
        let isSelected = selectedFormat?.id == format.id
        return Button { selectedFormat = format } label: {
            HStack(spacing: 14) {
                Image(systemName: format.type.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .pink : .secondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 3) {
                    Text(format.type.rawValue).font(.subheadline.bold())
                    Text(format.type.description).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    if let cap = format.groupCapacity {
                        Text("Max \(cap) students").font(.caption2).foregroundStyle(.secondary)
                    }
                    if let dur = format.durationMinutes {
                        Text("\(dur) min").font(.caption2).foregroundStyle(.secondary)
                    }
                }

                Spacer()
                Text("$\(Int(format.price))").font(.subheadline.bold())
            }
            .padding(14)
            .background(isSelected ? Color.pink.opacity(0.08) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Booking Flow Sheet
struct CoachingBookingView: View {
    let listing: CoachingListing
    let format: CoachingFormat
    @Environment(\.dismiss) private var dismiss
    @State private var step = 1
    @State private var sessionNotes = ""
    @State private var selectedDate = Date()
    @State private var isBooked = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i <= step ? Color.pink : Color(.systemGray4))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if step == 1 {
                            stepOne
                        } else if step == 2 {
                            stepTwo
                        } else {
                            stepThree
                        }
                    }
                    .padding(20)
                }

                // Nav buttons
                HStack(spacing: 12) {
                    if step > 1 && !isBooked {
                        Button("Back") { step -= 1 }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color(.systemGray5))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button(isBooked ? "Done" : (step == 3 ? "Confirm & Pay" : "Continue")) {
                        if isBooked { dismiss() }
                        else if step < 3 { step += 1 }
                        else { isBooked = true; step = 3 }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20).padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Book Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var stepOne: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 1 of 3 — Select Date & Time")
                .font(.headline)
            if format.type == .recorded {
                VStack(spacing: 12) {
                    Image(systemName: "play.circle.fill").font(.system(size: 48)).foregroundStyle(.pink)
                    Text("Recorded session — available immediately after purchase.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).padding(30)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                DatePicker("Select Date", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
            }
        }
    }

    private var stepTwo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 2 of 3 — Session Notes")
                .font(.headline)
            Text("Tell \(listing.sellerDisplayName) your goals, current level, and anything else that helps them prepare.")
                .font(.subheadline).foregroundStyle(.secondary)
            TextEditor(text: $sessionNotes)
                .frame(height: 140)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var stepThree: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isBooked {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64)).foregroundStyle(.green)
                    Text("You're Booked!").font(.title2.bold())
                    Text("\(listing.sellerDisplayName) has been notified and will confirm your session shortly.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).padding(20)
            } else {
                Text("Step 3 of 3 — Confirm & Pay").font(.headline)

                VStack(spacing: 10) {
                    summaryRow("Coach",   listing.sellerDisplayName)
                    summaryRow("Format",  format.type.rawValue)
                    if format.type != .recorded, let dur = format.durationMinutes {
                        summaryRow("Duration", "\(dur) minutes")
                    }
                    Divider()
                    summaryRow("Session fee", "$\(Int(format.price))")
                    summaryRow("Artist earns (85%)", "$\(Int(format.price * 0.85))")
                    summaryRow("Platform fee (15%)", "$\(Int(format.price * 0.15))")
                    Divider()
                    HStack {
                        Text("Total").font(.headline)
                        Spacer()
                        Text("$\(Int(format.price))").font(.headline)
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline)
        }
    }
}

// ConsultingHubView.swift
// Artistic Direction & Consulting — browse, detail, and project inquiry flow.

import SwiftUI

// MARK: - Hub (Browse)
struct ConsultingHubView: View {
    @State private var selectedSpecialty: String? = nil
    private let listings = MockData.consultingListings

    private var allSpecialties: [String] {
        Array(Set(listings.flatMap(\.specialties))).sorted()
    }

    var filtered: [ConsultingListing] {
        guard let s = selectedSpecialty else { return listings }
        return listings.filter { $0.specialties.contains(s) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Revenue banner
                HStack(spacing: 10) {
                    Image(systemName: "briefcase.fill").font(.title2).foregroundStyle(.indigo)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Offer Your Expertise").font(.subheadline.bold())
                        Text("List your AD & consulting services — you keep 85%")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("List Services") {}
                        .font(.caption.bold())
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.indigo.opacity(0.12))
                        .foregroundStyle(.indigo)
                        .clipShape(Capsule())
                }
                .padding(14)
                .background(Color.indigo.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                // Specialty filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        specialtyChip("All", isSelected: selectedSpecialty == nil) { selectedSpecialty = nil }
                        ForEach(allSpecialties, id: \.self) { spec in
                            specialtyChip(spec, isSelected: selectedSpecialty == spec) { selectedSpecialty = spec }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Listings
                LazyVStack(spacing: 16) {
                    ForEach(filtered) { listing in
                        NavigationLink(destination: ConsultingDetailView(listing: listing)) {
                            ConsultingCardView(listing: listing)
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

    private func specialtyChip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected
                    ? AnyShapeStyle(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color(.systemGray5)))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Consulting Card
struct ConsultingCardView: View {
    let listing: ConsultingListing

    var body: some View {
        HStack(spacing: 14) {
            // Avatar with availability ring
            ZStack(alignment: .bottomTrailing) {
                RemoteImage(url: listing.sellerImageURL)
                    .frame(width: 70, height: 70).clipShape(Circle())
                    .overlay(Circle().stroke(listing.availabilityStatus.color, lineWidth: 2.5))

                Circle().fill(listing.availabilityStatus.color)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                    .offset(x: 2, y: 2)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(listing.sellerDisplayName).font(.subheadline.bold())
                    Spacer()
                    Text(listing.availabilityStatus.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(listing.availabilityStatus.color)
                }

                Text(listing.tagline)
                    .font(.caption).foregroundStyle(.secondary).lineLimit(2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(listing.specialties.prefix(3), id: \.self) { spec in
                            Text(spec).font(.caption2)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.indigo.opacity(0.1))
                                .foregroundStyle(.indigo)
                                .clipShape(Capsule())
                        }
                    }
                }

                HStack {
                    Text("From $\(Int(listing.dayRate).shortFormatted())/day")
                        .font(.caption.bold())
                    Text("· Min $\(Int(listing.projectMinimum).shortFormatted())")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Consulting Detail
struct ConsultingDetailView: View {
    let listing: ConsultingListing
    @State private var showInquirySheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Hero header
                HStack(spacing: 14) {
                    RemoteImage(url: listing.sellerImageURL)
                        .frame(width: 80, height: 80).clipShape(Circle())
                        .overlay(Circle().stroke(listing.availabilityStatus.color, lineWidth: 3))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(listing.sellerDisplayName).font(.title2.bold())
                        Text(listing.sellerArtistType.emoji + " " + listing.sellerArtistType.rawValue)
                            .font(.subheadline).foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            Image(systemName: listing.availabilityStatus.icon)
                                .foregroundStyle(listing.availabilityStatus.color)
                            Text(listing.availabilityStatus.rawValue)
                                .font(.subheadline.bold())
                                .foregroundStyle(listing.availabilityStatus.color)
                            if let through = listing.bookedThrough {
                                Text("through \(through.formatted(.dateTime.month().day()))")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 20)

                // Tagline
                Text(listing.tagline)
                    .font(.headline)
                    .padding(.horizontal, 20)

                // Specialties
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(listing.specialties, id: \.self) { spec in
                            Text(spec).font(.subheadline)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.indigo.opacity(0.1))
                                .foregroundStyle(.indigo)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Divider().padding(.horizontal, 20)

                // Rates
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rates").font(.headline)
                    rateRow("Day Rate",          "$\(Int(listing.dayRate).shortFormatted())/day")
                    rateRow("Project Minimum",   "$\(Int(listing.projectMinimum).shortFormatted())")
                    if listing.retainerAvailable, let monthly = listing.retainerRateMonthly {
                        rateRow("Monthly Retainer", "$\(Int(monthly).shortFormatted())/mo")
                    }
                    Text("Artist keeps 85% · RC keeps 15%")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)

                Divider().padding(.horizontal, 20)

                // Scope statement
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scope of Work").font(.headline)
                    Text(listing.scopeStatement)
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)

                Divider().padding(.horizontal, 20)

                // Past projects
                VStack(alignment: .leading, spacing: 12) {
                    Text("Selected Credits").font(.headline)
                    ForEach(listing.pastProjects) { project in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name).font(.subheadline.bold())
                                Text(project.artist + " · " + String(project.year))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(project.role)
                                .font(.caption.bold())
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button { showInquirySheet = true } label: {
                Text("Submit Project Brief")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity).padding()
                    .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showInquirySheet) {
            ProjectBriefSheet(listing: listing)
        }
    }

    private func rateRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.bold())
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Project Brief Sheet
struct ProjectBriefSheet: View {
    let listing: ConsultingListing
    @Environment(\.dismiss) private var dismiss

    @State private var projectType = ""
    @State private var projectName = ""
    @State private var artistBrand = ""
    @State private var startDate = Date()
    @State private var description = ""
    @State private var budgetRange = ""
    @State private var isSubmitted = false

    private let projectTypes = ["World Tour", "Music Video", "Brand Campaign", "Broadway/Theater", "Live Event", "TV/Film", "Other"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isSubmitted {
                        submittedConfirmation
                    } else {
                        briefForm
                    }
                }
                .padding(20)
            }
            .navigationTitle("Submit Project Brief")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                if !isSubmitted {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Submit") { isSubmitted = true }
                            .fontWeight(.bold)
                            .disabled(projectName.isEmpty || description.isEmpty)
                    }
                }
            }
        }
    }

    private var briefForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Submitting to \(listing.sellerDisplayName)")
                .font(.subheadline).foregroundStyle(.secondary)

            formField("Project Type") {
                Menu {
                    ForEach(projectTypes, id: \.self) { type in
                        Button(type) { projectType = type }
                    }
                } label: {
                    HStack {
                        Text(projectType.isEmpty ? "Select type" : projectType)
                            .foregroundStyle(projectType.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            formField("Project / Artist Name") {
                TextField("e.g. Summer Tour 2025", text: $projectName)
                    .textFieldStyle(.plain).padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            formField("Budget Range") {
                TextField("e.g. $25,000 – $50,000", text: $budgetRange)
                    .textFieldStyle(.plain).padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            formField("Target Start Date") {
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            formField("Project Description") {
                TextEditor(text: $description)
                    .frame(height: 120)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Text("The artist will review your brief and respond with a formal proposal within 48 hours.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private func formField<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline.bold())
            content()
        }
    }

    private var submittedConfirmation: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)
            Image(systemName: "paperplane.fill")
                .font(.system(size: 60)).foregroundStyle(.indigo)
            Text("Brief Submitted").font(.title2.bold())
            Text("\(listing.sellerDisplayName) will review your project and respond with a proposal within 48 hours.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Done") { dismiss() }
                .font(.headline.bold())
                .frame(maxWidth: .infinity).padding()
                .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .frame(maxWidth: .infinity)
    }
}

// AuditionsView.swift
// Formal talent call board — tours, Broadway, music videos, festivals.

import SwiftUI

struct AuditionsView: View {
    @State private var selectedType: ArtistType? = nil
    private let auditions = MockData.auditions

    var filtered: [Audition] {
        guard let t = selectedType else { return auditions }
        return auditions.filter { $0.lookingFor.contains(t) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header banner
                HStack(spacing: 12) {
                    Image(systemName: "theatermasks.fill")
                        .font(.title).foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Open Auditions")
                            .font(.headline)
                        Text("Real paid opportunities from working artists")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Post Audition") {}
                        .font(.caption.bold())
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
                .padding(14)
                .background(Color.orange.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                // Filter by role
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        filterChip(label: "All Roles", isSelected: selectedType == nil) { selectedType = nil }
                        ForEach([ArtistType.dancer, .singer, .rapper, .dj, .producer]) { type in
                            filterChip(label: type.rawValue, isSelected: selectedType == type) { selectedType = type }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                LazyVStack(spacing: 14) {
                    ForEach(filtered) { audition in
                        NavigationLink(destination: AuditionDetailView(audition: audition)) {
                            AuditionCardView(audition: audition)
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
                .background(isSelected ? AnyShapeStyle(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color(.systemGray5)))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Audition Card
struct AuditionCardView: View {
    let audition: Audition

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                RemoteImage(url: audition.posterImageURL)
                    .frame(width: 42, height: 42).clipShape(Circle())
                    .overlay(Circle().stroke(audition.posterArtistType.color.opacity(0.6), lineWidth: 2))

                VStack(alignment: .leading, spacing: 2) {
                    Text(audition.posterDisplayName).font(.subheadline.bold())
                    artistTypeLabel
                }

                Spacer()

                // Project type badge
                HStack(spacing: 4) {
                    Image(systemName: audition.projectType.icon).font(.caption)
                    Text(audition.projectType.rawValue).font(.caption.bold())
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
            }

            // Title
            Text(audition.title).font(.headline).lineLimit(2)
            Text(audition.projectName).font(.caption).foregroundStyle(.secondary)

            // Roles needed
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Text("Needs:").font(.caption2).foregroundStyle(.secondary)
                    ForEach(audition.lookingFor) { role in
                        rolePill(role)
                    }
                }
            }

            // Footer
            HStack {
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle").font(.caption).foregroundStyle(.secondary)
                    Text(audition.location).font(.caption).foregroundStyle(.secondary)
                    if audition.isRemoteFriendly {
                        Text("· Remote OK").font(.caption).foregroundStyle(.green)
                    }
                }

                Spacer()

                // Compensation
                VStack(alignment: .trailing, spacing: 1) {
                    Text(audition.compensation.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(audition.compensation == .volunteer ? Color.secondary : Color.green)
                    if let amount = audition.compensationAmount {
                        Text(amount).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }

            // Deadline bar
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.caption2)
                    Text(audition.isUrgent ? "Closes in \(audition.daysUntilDeadline)d — Apply Now!" : "Closes in \(audition.daysUntilDeadline) days")
                        .font(.caption2.bold())
                }
                .foregroundStyle(audition.isUrgent ? .red : .secondary)

                Spacer()

                Text("\(audition.submissionCount) submissions")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(audition.isUrgent ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }

    private var artistTypeLabel: some View {
        let label = audition.posterArtistType.emoji + " " + audition.posterArtistType.rawValue
        return Text(label).font(.caption).foregroundStyle(.secondary)
    }

    private func rolePill(_ role: ArtistType) -> some View {
        let label = role.emoji + " " + role.rawValue
        let color = role.color
        return Text(label)
            .font(.caption.bold())
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Audition Detail
struct AuditionDetailView: View {
    let audition: Audition
    @State private var hasApplied = false
    @State private var submissionText = ""
    @State private var showSubmitSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Poster info
                HStack(spacing: 12) {
                    RemoteImage(url: audition.posterImageURL)
                        .frame(width: 56, height: 56).clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(audition.posterDisplayName).font(.headline)
                        Text(audition.posterArtistType.emoji + " " + audition.posterArtistType.rawValue)
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: audition.projectType.icon)
                        Text(audition.projectType.rawValue)
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(audition.projectName).font(.caption).foregroundStyle(.secondary)
                    Text(audition.title).font(.title2.bold())
                }

                Divider()

                // Key info grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    infoCell(icon: "mappin.circle", label: "Location", value: audition.location)
                    infoCell(icon: "clock", label: "Deadline", value: "\(audition.daysUntilDeadline) days left")
                    infoCell(icon: "dollarsign.circle", label: "Compensation", value: audition.compensationAmount ?? audition.compensation.rawValue)
                    infoCell(icon: "person.wave.2", label: "Submissions", value: "\(audition.submissionCount)")
                }

                Divider()
                Text("About the Opportunity").font(.headline)
                Text(audition.description).font(.subheadline).foregroundStyle(.secondary)

                Divider()
                Text("Looking For").font(.headline)
                HStack(spacing: 8) {
                    ForEach(audition.lookingFor) { role in
                        Text(role.emoji + " " + role.rawValue)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(role.color.opacity(0.15))
                            .foregroundStyle(role.color)
                            .clipShape(Capsule())
                    }
                }

                Spacer(minLength: 80)
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button { if !hasApplied { showSubmitSheet = true } } label: {
                Text(hasApplied ? "Application Submitted ✓" : "Apply Now")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity).padding()
                    .background(hasApplied ? AnyShapeStyle(Color.green) : AnyShapeStyle(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showSubmitSheet) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tell them about yourself")
                        .font(.headline).padding(.horizontal)
                    TextEditor(text: $submissionText)
                        .frame(height: 160)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    Text("Include links to your reel, social profiles, or previous work.")
                        .font(.caption).foregroundStyle(.secondary).padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 20)
                .navigationTitle("Submit Application")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showSubmitSheet = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Submit") {
                            hasApplied = true
                            showSubmitSheet = false
                        }
                        .fontWeight(.bold)
                        .disabled(submissionText.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private func infoCell(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.title3).foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.subheadline.bold())
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

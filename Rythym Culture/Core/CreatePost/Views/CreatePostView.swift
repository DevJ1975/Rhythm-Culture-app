// CreatePostView.swift
// Full post creation — type, media, caption, genre, and publish.

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var caption = ""
    @State private var genre = ""
    @State private var selectedType: Post.PostType = .standard
    @State private var isPublishing = false
    @State private var showMediaPicker = false

    private let captionLimit = 2200

    var canPublish: Bool { !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Media area
                    mediaPlaceholder

                    // Post type selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Post Type")
                            .font(.caption.bold()).foregroundStyle(.secondary)
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Post.PostType.allCases, id: \.self) { type in
                                    postTypeChip(type)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)

                    Divider()

                    // Caption
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            RemoteImage(url: MockData.currentUser.profileImageURL ?? "")
                                .frame(width: 36, height: 36).clipShape(Circle())

                            Text("Write a caption...")
                                .font(.subheadline)
                                .foregroundStyle(caption.isEmpty ? .secondary : .primary)
                        }

                        TextEditor(text: $caption)
                            .font(.subheadline)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .onChange(of: caption) {
                                if caption.count > captionLimit {
                                    caption = String(caption.prefix(captionLimit))
                                }
                            }

                        HStack {
                            Spacer()
                            Text("\(caption.count)/\(captionLimit)")
                                .font(.caption2)
                                .foregroundStyle(caption.count > captionLimit - 100 ? .orange : .secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    Divider()

                    // Genre
                    HStack {
                        Image(systemName: "music.note").foregroundStyle(.secondary)
                        TextField("Genre or style (e.g. Hip-Hop, Contemporary)", text: $genre)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)

                    Divider()

                    // Tag people / location rows
                    metaRow(icon: "person.crop.circle.badge.plus", label: "Tag People")
                    Divider()
                    metaRow(icon: "mappin.and.ellipse", label: "Add Location")
                    Divider()

                    // Preview badge
                    if selectedType != .standard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Post Preview")
                                .font(.caption.bold()).foregroundStyle(.secondary)
                            postTypeBannerPreview
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPublishing = true
                        Task {
                            try? await Task.sleep(for: .seconds(1.2))
                            isPublishing = false
                            dismiss()
                        }
                    } label: {
                        if isPublishing {
                            ProgressView().tint(.white)
                                .frame(width: 60)
                        } else {
                            Text("Share")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 16).padding(.vertical, 6)
                                .background(canPublish
                                    ? AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                    : AnyShapeStyle(Color(.systemGray4)))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .disabled(!canPublish || isPublishing)
                }
            }
        }
    }

    // MARK: - Media Placeholder
    private var mediaPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)

            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary.opacity(0.5))

                HStack(spacing: 16) {
                    mediaButton(icon: "camera.fill", label: "Camera")
                    mediaButton(icon: "photo.fill", label: "Gallery")
                    mediaButton(icon: "video.fill", label: "Video")
                }
            }
        }
    }

    private func mediaButton(icon: String, label: String) -> some View {
        Button {} label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 52, height: 52)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                Text(label).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
    }

    // MARK: - Post Type Chip
    private func postTypeChip(_ type: Post.PostType) -> some View {
        let config = bannerConfig(for: type)
        let isSelected = selectedType == type
        return Button { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedType = type } } label: {
            HStack(spacing: 5) {
                Text(config.emoji)
                Text(config.label)
                    .font(.caption.bold())
            }
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(isSelected
                ? AnyShapeStyle(LinearGradient(colors: config.gradient, startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(Color(.systemGray5)))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }

    // MARK: - Post type banner preview
    private var postTypeBannerPreview: some View {
        let config = bannerConfig(for: selectedType)
        return HStack(spacing: 6) {
            Text(config.emoji)
            Text(config.label.uppercased())
                .font(.caption.bold()).tracking(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14).padding(.vertical, 7)
        .background(LinearGradient(colors: config.gradient, startPoint: .leading, endPoint: .trailing))
        .clipShape(Capsule())
    }

    private func metaRow(icon: String, label: String) -> some View {
        Button {} label: {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(.secondary).frame(width: 20)
                Text(label).font(.subheadline).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
    }

    private func bannerConfig(for type: Post.PostType) -> (emoji: String, label: String, gradient: [Color]) {
        switch type {
        case .standard:  return ("📝", "Standard",       [Color(.systemGray4), Color(.systemGray3)])
        case .drop:      return ("🎵", "New Drop",        [.purple, .blue])
        case .battle:    return ("⚔️", "Battle Entry",    [.red, .orange])
        case .showcase:  return ("⭐", "Showcase",         [.orange, .yellow])
        case .collab:    return ("🤝", "Collab Request",  [.blue, .teal])
        }
    }
}


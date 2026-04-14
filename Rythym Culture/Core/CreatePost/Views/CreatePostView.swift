// CreatePostView.swift
// Full post creation — camera or library media, caption, genre, and publish.

import SwiftUI
import PhotosUI
import AVKit
import UniformTypeIdentifiers

// MARK: - Camera / Media Picker (supports photo + video up to 30s)

struct PostCameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Binding var detectedMediaType: Post.MediaType
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.videoMaximumDuration = 30        // 30-second cap
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PostCameraPicker

        init(_ parent: PostCameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let mediaType = info[.mediaType] as? String ?? ""
            if mediaType == UTType.movie.identifier || mediaType == "public.movie" {
                if let url = info[.mediaURL] as? URL {
                    parent.selectedVideoURL = url
                    parent.selectedImage = nil
                    parent.detectedMediaType = .video
                }
            } else {
                let key: UIImagePickerController.InfoKey = info[.editedImage] != nil ? .editedImage : .originalImage
                if let image = info[key] as? UIImage {
                    parent.selectedImage = image
                    parent.selectedVideoURL = nil
                    parent.detectedMediaType = .image
                }
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Create Post View

struct CreatePostView: View {
    var onPost: ((Post) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var caption = ""
    @State private var genre = ""
    @State private var selectedType: Post.PostType = .standard
    @State private var isPublishing = false

    // Media state
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    @State private var detectedMediaType: Post.MediaType = .none
    @State private var isLoadingMedia = false

    // Pickers
    @State private var pickerItem: PhotosPickerItem?
    @State private var showMediaSource = false
    @State private var showCamera = false
    @State private var showLibraryPicker = false

    private let captionLimit = 2200
    var canPublish: Bool { !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    mediaArea
                    postTypeSection
                    Divider()
                    captionSection
                    Divider()
                    genreRow
                    Divider()
                    metaRow(icon: "person.crop.circle.badge.plus", label: "Tag People")
                    Divider()
                    metaRow(icon: "mappin.and.ellipse", label: "Add Location")
                    Divider()
                    if selectedType != .standard {
                        postTypeBannerPreviewSection
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
                    publishButton
                }
            }
            // Source selection
            .confirmationDialog("Add Media", isPresented: $showMediaSource, titleVisibility: .visible) {
                Button("Camera — Photo or Video") { showCamera = true }
                Button("Choose from Library") { showLibraryPicker = true }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Video is limited to 30 seconds.")
            }
            // Camera picker (full-screen)
            .fullScreenCover(isPresented: $showCamera) {
                PostCameraPicker(
                    selectedImage: $selectedImage,
                    selectedVideoURL: $selectedVideoURL,
                    detectedMediaType: $detectedMediaType
                )
                .ignoresSafeArea()
            }
            // Library picker
            .photosPicker(isPresented: $showLibraryPicker, selection: $pickerItem,
                          matching: .any(of: [.images, .videos]))
            .onChange(of: pickerItem) { loadPickerItem() }
        }
    }

    // MARK: - Media Area

    private var mediaArea: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(maxWidth: .infinity)
                .aspectRatio(detectedMediaType == .video ? 9/16 : 1, contentMode: .fit)

            // Content
            if isLoadingMedia {
                loadingOverlay
            } else if let image = selectedImage {
                Image(uiImage: image)
                    .resizable().scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            } else if let videoURL = selectedVideoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(9/16, contentMode: .fit)
            } else {
                emptyMediaPlaceholder
            }

            // Change overlay (top-right) when media is selected
            if (selectedImage != nil || selectedVideoURL != nil) && !isLoadingMedia {
                VStack {
                    HStack {
                        Spacer()
                        Button { showMediaSource = true } label: {
                            Label("Change", systemImage: "arrow.triangle.2.circlepath")
                                .font(.caption.bold())
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .padding(10)
                    }
                    Spacer()
                }
            }
        }
        // Tap empty area to open source picker
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedImage == nil && selectedVideoURL == nil && !isLoadingMedia {
                showMediaSource = true
            }
        }
    }

    private var emptyMediaPlaceholder: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72)
                Image(systemName: "camera.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(spacing: 4) {
                Text("Add Photo or Video")
                    .font(.subheadline.bold())
                Text("Camera · Library  •  Video up to 30s")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var loadingOverlay: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                ProgressView()
                    .controlSize(.regular)
                    .tint(.purple)
            }
            Text("Processing media…")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Post Type

    private var postTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Post Type")
                .font(.caption.bold()).foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Post.PostType.allCases, id: \.self) { postTypeChip($0) }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
    }

    // MARK: - Caption

    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                RemoteImage(url: MockData.currentUser.profileImageURL ?? "")
                    .frame(width: 36, height: 36).clipShape(Circle())
                Text("Write a caption…")
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
    }

    // MARK: - Genre

    private var genreRow: some View {
        HStack {
            Image(systemName: "music.note").foregroundStyle(.secondary)
            TextField("Genre or style (e.g. Hip-Hop, Contemporary)", text: $genre)
                .font(.subheadline)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: - Publish Button

    private var publishButton: some View {
        Button {
            isPublishing = true
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                let author = MockData.currentUser
                let newPost = Post(
                    id: UUID().uuidString,
                    authorId: author.id,
                    authorUsername: author.username,
                    authorDisplayName: author.displayName,
                    authorProfileImageURL: author.profileImageURL,
                    authorArtistType: author.artistType,
                    caption: caption,
                    mediaURLs: selectedImage != nil ? [MockData.gridImageURL(index: Int.random(in: 0..<20))] : [],
                    mediaType: detectedMediaType,
                    postType: selectedType,
                    genre: genre.isEmpty ? nil : genre,
                    createdAt: .now
                )
                isPublishing = false
                onPost?(newPost)
                dismiss()
            }
        } label: {
            if isPublishing {
                HStack(spacing: 6) {
                    ProgressView().tint(.white).scaleEffect(0.85)
                    Text("Sharing…").font(.caption.bold()).foregroundStyle(.white)
                }
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
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

    // MARK: - Post Type Chip

    private func postTypeChip(_ type: Post.PostType) -> some View {
        let config = bannerConfig(for: type)
        let isSelected = selectedType == type
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedType = type }
        } label: {
            HStack(spacing: 5) {
                Text(config.emoji)
                Text(config.label).font(.caption.bold())
            }
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(isSelected
                ? AnyShapeStyle(LinearGradient(colors: config.gradient, startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(Color(.systemGray5)))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }

    private var postTypeBannerPreviewSection: some View {
        let config = bannerConfig(for: selectedType)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Post Preview").font(.caption.bold()).foregroundStyle(.secondary)
            HStack(spacing: 6) {
                Text(config.emoji)
                Text(config.label.uppercased()).font(.caption.bold()).tracking(1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(LinearGradient(colors: config.gradient, startPoint: .leading, endPoint: .trailing))
            .clipShape(Capsule())
        }
        .padding(16)
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

    // MARK: - Load from Photo Library

    private func loadPickerItem() {
        guard let pickerItem else { return }
        isLoadingMedia = true

        pickerItem.loadTransferable(type: URL.self) { result in
            if case .success(let url) = result, let url {
                // Check duration for video
                let asset = AVURLAsset(url: url)
                let duration = CMTimeGetSeconds(asset.duration)
                DispatchQueue.main.async {
                    if duration > 30 {
                        // Exceeds limit — clear and show a note
                        isLoadingMedia = false
                        // Reset — user sees placeholder again
                        selectedVideoURL = nil
                        selectedImage = nil
                        detectedMediaType = .none
                    } else {
                        selectedVideoURL = url
                        selectedImage = nil
                        detectedMediaType = .video
                        isLoadingMedia = false
                    }
                }
                return
            }
            pickerItem.loadTransferable(type: Data.self) { dataResult in
                if case .success(let data) = dataResult, let data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        selectedImage = image
                        selectedVideoURL = nil
                        detectedMediaType = .image
                        isLoadingMedia = false
                    }
                } else {
                    DispatchQueue.main.async { isLoadingMedia = false }
                }
            }
        }
    }
}

// EditProfileView.swift
// Edit profile — display name, bio, location, genres, artist type, and photo (camera or library).

import SwiftUI
import PhotosUI

// MARK: - Camera Picker
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let key: UIImagePickerController.InfoKey = info[.editedImage] != nil ? .editedImage : .originalImage
            if let image = info[key] as? UIImage { parent.image = image }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    let user: AppUser
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String
    @State private var bio: String
    @State private var location: String
    @State private var genresText: String
    @State private var selectedArtistType: ArtistType?
    @State private var selectedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var showImageSource = false
    @State private var showCamera = false
    @State private var showLibraryPicker = false

    init(user: AppUser) {
        self.user = user
        _displayName   = State(initialValue: user.displayName)
        _bio           = State(initialValue: user.bio ?? "")
        _location      = State(initialValue: user.location ?? "")
        _genresText    = State(initialValue: user.genres.joined(separator: ", "))
        _selectedArtistType = State(initialValue: user.artistType)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    photoSection
                    fieldsSection
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveAndDismiss() }
                        .fontWeight(.semibold)
                        .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .confirmationDialog("Change Profile Photo", isPresented: $showImageSource, titleVisibility: .visible) {
                Button("Take Selfie") { showCamera = true }
                Button("Choose from Library") { showLibraryPicker = true }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(image: $selectedImage).ignoresSafeArea()
            }
            .photosPicker(isPresented: $showLibraryPicker, selection: $pickerItem, matching: .images)
            .onChange(of: pickerItem) { loadPickerItem() }
        }
    }

    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: 10) {
            Button { showImageSource = true } label: {
                ZStack(alignment: .bottomTrailing) {
                    avatarImage
                        .overlay(
                            Circle()
                                .fill(.black.opacity(0.35))
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                )
                        )

                    Circle()
                        .fill(selectedArtistType?.gradient.first ?? .purple)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        )
                        .offset(x: 4, y: 4)
                }
            }
            .buttonStyle(.plain)

            Text("Tap to change • Camera or Library")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let img = selectedImage {
            Image(uiImage: img)
                .resizable().scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay(Circle().stroke(selectedArtistType?.color ?? .gray, lineWidth: 2.5))
        } else if let url = user.profileImageURL {
            RemoteImage(url: url)
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay(Circle().stroke(selectedArtistType?.color ?? .gray, lineWidth: 2.5))
        } else {
            Circle()
                .fill(LinearGradient(
                    colors: selectedArtistType?.gradient ?? [.gray, .gray.opacity(0.6)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 96, height: 96)
                .overlay(
                    Text(user.username.prefix(1).uppercased())
                        .font(.title.bold()).foregroundStyle(.white)
                )
        }
    }

    // MARK: - Fields Section
    private var fieldsSection: some View {
        VStack(spacing: 0) {
            formRow(label: "Name") {
                TextField("Display name", text: $displayName)
            }
            Divider().padding(.leading, 100)
            formRow(label: "Bio") {
                TextField("Tell your story...", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
            }
            Divider().padding(.leading, 100)
            formRow(label: "Location") {
                TextField("City, State", text: $location)
            }
            Divider().padding(.leading, 100)
            formRow(label: "Genres") {
                TextField("Hip-Hop, Contemporary, R&B", text: $genresText)
            }
            Divider()

            // Artist Type
            VStack(alignment: .leading, spacing: 10) {
                Text("Artist Type")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        artistTypeChip(nil, label: "None")
                        ForEach([ArtistType.dancer, .singer, .rapper, .dj, .producer]) { type in
                            artistTypeChip(type, label: "\(type.emoji) \(type.rawValue)")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private func formRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 75, alignment: .leading)
            content()
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func artistTypeChip(_ type: ArtistType?, label: String) -> some View {
        let isSelected = selectedArtistType == type
        let grad: [Color] = type?.gradient ?? [Color(.systemGray4), Color(.systemGray4)]
        return Button { selectedArtistType = type } label: {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected
                    ? AnyShapeStyle(LinearGradient(colors: grad, startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color(.systemGray5)))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func loadPickerItem() {
        guard let pickerItem else { return }
        pickerItem.loadTransferable(type: Data.self) { result in
            if case .success(let data) = result, let data, let image = UIImage(data: data) {
                DispatchQueue.main.async { selectedImage = image }
            }
        }
    }

    private func saveAndDismiss() {
        let trimmed = { (s: String) -> String? in
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? nil : t
        }
        var updated = user
        updated.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.bio         = trimmed(bio)
        updated.location    = trimmed(location)
        updated.genres      = genresText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        updated.artistType  = selectedArtistType

        // Persist picked image to Documents and store its file:// URL
        if let image = selectedImage,
           let data = image.jpegData(compressionQuality: 0.85) {
            let filename = "profile_\(user.id).jpg"
            let fileURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(filename)
            try? data.write(to: fileURL, options: .atomic)
            updated.profileImageURL = fileURL.absoluteString
        }

        authViewModel.updateCurrentUser(updated)
        dismiss()
    }
}

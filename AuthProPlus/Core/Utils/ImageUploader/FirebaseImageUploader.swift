//
//  ImageUploader.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Firebase
import FirebaseStorage
import UIKit

/// Responsible for uploading binary image data to Firebase Storage and returning a download URL.
struct FirebaseImageUploader {

    /// Uploads image data to Firebase Storage with optional compression, size checks, and metadata.
    ///
    /// - Parameters:
    ///   - imageData: Raw image bytes to upload (e.g., PNG/JPEG). If compression is applied, the data will be converted to JPEG.
    ///   - folder: Storage folder (no leading slash). Defaults to `"profile_images"`.
    ///   - filename: Optional file name (without extension). If `nil`, a UUID is used.
    ///   - maxBytes: Target maximum size in bytes for the uploaded data. Defaults to ~2 MB.
    ///   - compressIfNeeded: Whether to attempt JPEG compression if `imageData` exceeds `maxBytes`.
    ///   - jpegQualitySequence: Qualities to try (highest to lowest) when compressing to meet `maxBytes`.
    /// - Returns: The public download URL string for the uploaded image.
    /// - Throws: `ImageUploadError` or Firebase errors if upload/URL retrieval fails.
    func uploadImage(
        imageData: Data,
        folder: String = "profile_images",
        filename: String? = nil,
        maxBytes: Int = 2_000_000,
        compressIfNeeded: Bool = true,
        jpegQualitySequence: [CGFloat] = [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3]
    ) async throws -> String {
        // Determine if compression is required
        var dataToUpload = imageData
        var contentType: String? = inferContentType(from: imageData)

        if imageData.count > maxBytes {
            if compressIfNeeded {
                guard let uiImage = UIImage(data: imageData) else { throw ImageUploadError.invalidImageData }
                guard let compressed = compressJPEG(uiImage, maxBytes: maxBytes, qualities: jpegQualitySequence) else {
                    throw ImageUploadError.imageTooLarge
                }
                dataToUpload = compressed
                contentType = "image/jpeg"
            } else {
                throw ImageUploadError.imageTooLarge
            }
        }

        // Build storage path and metadata
        let baseName = filename?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? filename! : UUID().uuidString
        let fileExtension = preferredFileExtension(forContentType: contentType)
        let finalFileName = fileExtension.isEmpty ? baseName : "\(baseName).\(fileExtension)"
        let sanitizedFolder = folder.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        let path = "\(sanitizedFolder)/\(finalFileName)"

        let ref = Storage.storage().reference(withPath: path)

        let metadata = StorageMetadata()
        if let contentType { metadata.contentType = contentType }

        // Upload with metadata
        _ = try await ref.putDataAsync(dataToUpload, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: - Compression Helpers

    /// Attempts to compress a UIImage into JPEG data within a max byte budget using a sequence of quality values.
    private func compressJPEG(_ image: UIImage, maxBytes: Int, qualities: [CGFloat]) -> Data? {
        for q in qualities {
            if let data = image.jpegData(compressionQuality: q), data.count <= maxBytes {
                return data
            }
        }
        // Fallback: return the smallest even if still too big, or nil if encoding failed entirely
        return qualities.compactMap { image.jpegData(compressionQuality: $0) }.last
    }

    // MARK: - Content Type Helpers

    /// Attempts to infer a content type (MIME) from the first few bytes of data.
    private func inferContentType(from data: Data) -> String? {
        // JPEG magic: FF D8
        if data.starts(with: [0xFF, 0xD8]) { return "image/jpeg" }
        // PNG magic: 89 50 4E 47 0D 0A 1A 0A
        let pngMagic: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        if data.count >= pngMagic.count && Array(data.prefix(pngMagic.count)) == pngMagic { return "image/png" }
        // GIF magic: 47 49 46 38
        if data.starts(with: [0x47, 0x49, 0x46, 0x38]) { return "image/gif" }
        return nil
    }

    /// Maps a content type to a preferred file extension.
    private func preferredFileExtension(forContentType contentType: String?) -> String {
        switch contentType {
        case "image/jpeg": return "jpg"
        case "image/png": return "png"
        case "image/gif": return "gif"
        default: return ""
        }
    }
}

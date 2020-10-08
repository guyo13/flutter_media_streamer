// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package net.guyor.flutter_media_streamer

// TODO - change all logical boolean values from int to boolean
data class ImageMediaData constructor (
        val contentUri: String,
        /** BaseColumns */
        val id: Long,
        val count: Long? = null,
        /** ImageColumns */
        val description: String? = null,
        val exposureTime: String? = null,
        val fNumber: String? = null,
        val iso: Int? = null,
        val isPrivate: Int? = null,
        val sceneCaptureType: Int? = null,
        /** MediaColumns */
        val album: String? = null,
        val albumArtist: String? = null,
        val artist: String? = null,
        val author: String? = null,
        val bitrate: Int? = null, // TODO - needed?
        val bucketDisplayName: String? = null,
        val bucketId: Int? = null,
        val captureFramerate: Float? = null, // TODO - needed?
        val cdTrackNumber: String? = null, // TODO - needed?
        val compilation: String? = null, // TODO - needed?
        val composer: String? = null, // TODO - needed?
        val dateAdded: Long? = null,
        val dateExpires: Long? = null,
        val dateModified: Long? = null,
        val dateTaken: Long? = null,
        val discNumber: String? = null, // TODO - needed?
        val displayName: String? = null,
        val documentId: String? = null,
        val duration: Long? = null,
        val generationAdded: Long? = null,
        val generationModified: Long? = null,
        val genre: String? = null,
        val height: Int? = null,
        val instanceId: String? = null,
        val isDownload: Int? = null,
        val isDrm: Int? = null,
        val isFavorite: Int? = null,
        val isPending: Int? = null,
        val isTrashed: Int? = null,
        val mimeType: String? = null,
        val numTracks: Int? = null, // TODO - needed?
        val orientation: Int? = null, // TODO - needed?
        val originalDocumentId: String? = null,
        val ownerPackageName: String? = null,
        val relativePath: String? = null,
        val resolution: String? = null,
        val size: Long? = null,
        val title: String? = null,
        val volumeName: String? = null,
        val width: Int? = null,
        val writer: String? = null, // TODO - needed?
        /** Should convert XMP Blob to base64 string*/
        val xmpBase64: String? = null,
        val year: Int? = null, // TODO - needed?
) {
}
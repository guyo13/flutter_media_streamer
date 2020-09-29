package net.guyor.flutter_media_streamer

import android.content.ContentUris
import android.database.Cursor
import android.os.Build
import android.provider.MediaStore
import android.util.Base64
import androidx.annotation.NonNull

class ImageCursorContainer(override val cursor: Cursor) : CursorContainer{
    private val _columnIds = mutableMapOf<String, Int>()
    val columnIds : Map<String, Int> get() = _columnIds

    companion object ColumnIndex {
        val imageColumnNames: List<String>
        init {
            val list = mutableListOf<String>()
            MediaStore.Images.ImageColumns::class.java.fields.iterator().forEach {
                field ->
                if (field.type == String::class.java)
                    list.add(field.get(MediaStore.Images.Media()) as String)
            }
            imageColumnNames = list
        }
        fun getValidProjection(@NonNull columns: List<String>) : List<String> {
            val res = mutableListOf<String>()
            for (column in columns) {
                if (column in imageColumnNames)
                    res.add(column)
            }
            return res
        }
        @JvmStatic
        fun getExternalContentUri(id: Long) = ContentUris.withAppendedId(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                id)
    }
    
    /** Call these functions only when cursor is properly initialized
     * and from a worker thread
     * */
    fun addColumns(columns: List<String>) {
        for (column in columns)
            addColumn(column)
    }

    private fun addColumn(column: String) {
        _columnIds[column] = cursor.getColumnIndexOrThrow(column)
    }
    fun getImageMediaData() : ImageMediaData {
        if (!columnIds.containsKey(MediaStore.Images.Media._ID)) {
            addColumn(MediaStore.Images.Media._ID)
        }
        val id = cursor.getLong(_columnIds[MediaStore.Images.Media._ID] ?: error("Column index for column '_id' not found!"))
        val bucketId: Int?
        val bucketDispName: String?
        val dateExpires: Long?
        val dateTaken: Long?
        val documentId: String?
        val duration: Long?
        val instanceId: String?
        val isPending: Int?
        val orientation: Int?
        val originalDocumentId: String?
        val ownerPackageName: String?
        val relativePath: String?
        val volumeName: String?
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            bucketId =  _columnIds[MediaStore.Images.Media.BUCKET_ID]?.let { cursor.getInt(it) }
            bucketDispName = _columnIds[MediaStore.Images.Media.BUCKET_DISPLAY_NAME]?.let { cursor.getString(it) }
            dateExpires = _columnIds[MediaStore.Images.Media.DATE_EXPIRES]?.let { cursor.getLong(it) }
            dateTaken = _columnIds[MediaStore.Images.Media.DATE_TAKEN]?.let { cursor.getLong(it) }
            documentId = _columnIds[MediaStore.Images.Media.DOCUMENT_ID]?.let { cursor.getString(it) }
            duration = _columnIds[MediaStore.Images.Media.DURATION]?.let { cursor.getLong(it) }
            instanceId = _columnIds[MediaStore.Images.Media.INSTANCE_ID]?.let { cursor.getString(it) }
            isPending = _columnIds[MediaStore.Images.Media.IS_PENDING]?.let { cursor.getInt(it) }
            orientation = _columnIds[MediaStore.Images.Media.ORIENTATION]?.let { cursor.getInt(it) }
            originalDocumentId = _columnIds[MediaStore.Images.Media.ORIGINAL_DOCUMENT_ID]?.let { cursor.getString(it) }
            ownerPackageName = _columnIds[MediaStore.Images.Media.OWNER_PACKAGE_NAME]?.let { cursor.getString(it) }
            relativePath = _columnIds[MediaStore.Images.Media.RELATIVE_PATH]?.let { cursor.getString(it) }
            volumeName = _columnIds[MediaStore.Images.Media.VOLUME_NAME]?.let { cursor.getString(it) }
        } else {
            bucketId = null
            bucketDispName = null
            dateExpires = null
            dateTaken = null
            documentId = null
            duration = null
            instanceId = null
            isPending = null
            orientation = null
            originalDocumentId = null
            ownerPackageName = null
            relativePath = null
            volumeName = null
        }
        return ImageMediaData(
                getExternalContentUri(id).toString(),
                id,
                count = _columnIds[MediaStore.Images.Media._COUNT]?.let { cursor.getLong(it) },
                description = _columnIds[MediaStore.Images.Media.DESCRIPTION]?.let { cursor.getString(it) },
                exposureTime = _columnIds[MediaStore.Images.Media.EXPOSURE_TIME]?.let { cursor.getString(it) },
                fNumber = _columnIds[MediaStore.Images.Media.F_NUMBER]?.let { cursor.getString(it) },
                iso = _columnIds[MediaStore.Images.Media.ISO]?.let { cursor.getInt(it) },
                isPrivate = _columnIds[MediaStore.Images.Media.IS_PRIVATE]?.let { cursor.getInt(it) },
                sceneCaptureType = _columnIds[MediaStore.Images.Media.SCENE_CAPTURE_TYPE]?.let { cursor.getInt(it) },
                album = _columnIds[MediaStore.Images.Media.ALBUM]?.let { cursor.getString(it) },
                albumArtist = _columnIds[MediaStore.Images.Media.ALBUM_ARTIST]?.let { cursor.getString(it) },
                artist = _columnIds[MediaStore.Images.Media.ARTIST]?.let { cursor.getString(it) },
                author = _columnIds[MediaStore.Images.Media.AUTHOR]?.let { cursor.getString(it) },
                bitrate = _columnIds[MediaStore.Images.Media.BITRATE]?.let { cursor.getInt(it) },
                bucketDisplayName = bucketDispName,
                bucketId = bucketId,
                captureFramerate = _columnIds[MediaStore.Images.Media.CAPTURE_FRAMERATE]?.let { cursor.getFloat(it) },
                cdTrackNumber = _columnIds[MediaStore.Images.Media.CD_TRACK_NUMBER]?.let { cursor.getString(it) },
                compilation = _columnIds[MediaStore.Images.Media.COMPILATION]?.let { cursor.getString(it) },
                composer = _columnIds[MediaStore.Images.Media.COMPOSER]?.let { cursor.getString(it) },
                dateAdded = _columnIds[MediaStore.Images.Media.DATE_ADDED]?.let { cursor.getLong(it) },
                dateExpires = dateExpires,
                dateModified = _columnIds[MediaStore.Images.Media.DATE_MODIFIED]?.let { cursor.getLong(it) },
                dateTaken = dateTaken,
                discNumber = _columnIds[MediaStore.Images.Media.DISC_NUMBER]?.let { cursor.getString(it) },
                displayName = _columnIds[MediaStore.Images.Media.DISPLAY_NAME]?.let { cursor.getString(it) },
                documentId = documentId,
                duration = duration,
                generationAdded = _columnIds[MediaStore.Images.Media.GENERATION_ADDED]?.let { cursor.getLong(it) },
                generationModified = _columnIds[MediaStore.Images.Media.GENERATION_MODIFIED]?.let { cursor.getLong(it) },
                genre = _columnIds[MediaStore.Images.Media.GENRE]?.let { cursor.getString(it) },
                height = _columnIds[MediaStore.Images.Media.HEIGHT]?.let { cursor.getInt(it) },
                instanceId = instanceId,
                isDownload = _columnIds[MediaStore.Images.Media.IS_DOWNLOAD]?.let { cursor.getInt(it) },
                isDrm = _columnIds[MediaStore.Images.Media.IS_DRM]?.let { cursor.getInt(it) },
                isFavorite = _columnIds[MediaStore.Images.Media.IS_FAVORITE]?.let { cursor.getInt(it) },
                isPending = isPending,
                isTrashed = _columnIds[MediaStore.Images.Media.IS_TRASHED]?.let { cursor.getInt(it) },
                mimeType = _columnIds[MediaStore.Images.Media.MIME_TYPE]?.let { cursor.getString(it) },
                numTracks = _columnIds[MediaStore.Images.Media.NUM_TRACKS]?.let { cursor.getInt(it) },
                orientation = orientation,
                originalDocumentId = originalDocumentId,
                ownerPackageName = ownerPackageName,
                relativePath = relativePath,
                resolution = _columnIds[MediaStore.Images.Media.RESOLUTION]?.let { cursor.getString(it) },
                size = _columnIds[MediaStore.Images.Media.SIZE]?.let { cursor.getLong(it) },
                title = _columnIds[MediaStore.Images.Media.TITLE]?.let { cursor.getString(it) },
                volumeName = volumeName,
                width = _columnIds[MediaStore.Images.Media.WIDTH]?.let { cursor.getInt(it) },
                writer = _columnIds[MediaStore.Images.Media.WRITER]?.let { cursor.getString(it) },
                xmpBase64 = _columnIds[MediaStore.Images.Media.XMP]?.let { Base64.encodeToString(cursor.getBlob(it), Base64.DEFAULT) },
                year = _columnIds[MediaStore.Images.Media.YEAR]?.let { cursor.getInt(it) }
        )
    }
}
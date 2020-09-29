package net.guyor.flutter_media_streamer

import android.database.Cursor
import android.provider.MediaStore

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
    }

    fun addColumn(column: String) {
        if (column in imageColumnNames)
            _columnIds[column] = cursor.getColumnIndexOrThrow(column)
    }
}
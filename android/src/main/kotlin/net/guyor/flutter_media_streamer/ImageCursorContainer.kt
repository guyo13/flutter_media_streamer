package net.guyor.flutter_media_streamer

import android.database.Cursor

class ImageCursorContainer(override val cursor: Cursor) : CursorContainer{
    private lateinit var _requestedColumns: MutableList<String>
    val requestedColumns : List<String> get() = _requestedColumns

    fun addColumn(column: String) {
        _requestedColumns.add(column)
    }
}
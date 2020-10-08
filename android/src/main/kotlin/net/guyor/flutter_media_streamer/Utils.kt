// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package net.guyor.flutter_media_streamer

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.FileDescriptor
import java.io.InvalidObjectException

/** Taken from https://developer.android.com/topic/performance/graphics/load-bitmap */

fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
    // Raw height and width of image
    val (height: Int, width: Int) = options.run { outHeight to outWidth }
    var inSampleSize = 1

    if (height > reqHeight || width > reqWidth) {

        val halfHeight: Int = height / 2
        val halfWidth: Int = width / 2

        // Calculate the largest inSampleSize value that is a power of 2 and keeps both
        // height and width larger than the requested height and width.
        while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
            inSampleSize *= 2
        }
    }

    return inSampleSize
}

fun decodeSampledBitmapFromDescriptor(
        fd: FileDescriptor,
        reqWidth: Int,
        reqHeight: Int
): Bitmap {
    // First decode with inJustDecodeBounds=true to check dimensions
    return BitmapFactory.Options().run {
        inJustDecodeBounds = true
        BitmapFactory.decodeFileDescriptor(fd, null, this)
        val w: Int = if (reqWidth > 0) reqWidth else outWidth
        val h: Int = if (reqHeight > 0) reqHeight else outHeight

        // Calculate inSampleSize
        inSampleSize = calculateInSampleSize(this, w, h)
        // Decode bitmap with inSampleSize set
        inJustDecodeBounds = false

        BitmapFactory.decodeFileDescriptor(fd, null, this)
    }
}

fun createScaledBitmap(
        fd: FileDescriptor,
        reqWidth: Int,
        reqHeight: Int
): Bitmap {
    val w: Int
    val h: Int
    BitmapFactory.Options().run {
        inJustDecodeBounds = true
        BitmapFactory.decodeFileDescriptor(fd, null, this)
        w = if (reqWidth > 0) reqWidth else outWidth
        h = if (reqHeight > 0) reqHeight else outHeight
    }
    //TODO - add argument to control this
    val src = BitmapFactory.decodeFileDescriptor(fd) ?: throw InvalidObjectException("Failed decoding Bitmap from file descriptor")
    return Bitmap.createScaledBitmap(src, w, h, true)
}
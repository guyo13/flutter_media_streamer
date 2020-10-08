// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package net.guyor.flutter_media_streamer

import android.database.Cursor

interface CursorContainer {
    val cursor: Cursor
}
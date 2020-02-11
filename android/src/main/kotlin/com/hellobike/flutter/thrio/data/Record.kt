package com.hellobike.flutter.thrio.data

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class Record(val url: String, val index: Int) : Parcelable
package com.instock.fieldforce.db

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "bg_gps_points",
    indices = [
        Index(value = ["processed", "timestamp"]),
        Index(value = ["timestamp"])
    ]
)
data class BgGpsPoint(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val latitude: Double,
    val longitude: Double,
    val accuracy: Float,
    val timestamp: Long,
    val processed: Boolean = false,
    val speed: Float? = null,
    val bearing: Float? = null,
    val altitude: Double? = null
)

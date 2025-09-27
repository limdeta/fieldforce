package com.instock.fieldforce.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction

@Dao
interface BgGpsPointDao {
    @Insert
    fun insert(point: BgGpsPoint): Long
    
    @Insert
    fun insertBatch(points: List<BgGpsPoint>): List<Long>

    @Query("SELECT * FROM bg_gps_points WHERE processed = 0 ORDER BY timestamp ASC LIMIT :limit")
    fun getUnprocessed(limit: Int): List<BgGpsPoint>

    @Query("UPDATE bg_gps_points SET processed = 1 WHERE id IN (:ids)")
    fun markProcessedByIds(ids: LongArray)

    @Query("DELETE FROM bg_gps_points WHERE processed = 1")
    fun deleteProcessed()
    
    @Query("SELECT COUNT(*) FROM bg_gps_points WHERE processed = 0")
    fun getUnprocessedCount(): Int
    
    @Query("DELETE FROM bg_gps_points WHERE processed = 1 AND timestamp < :oldestTimestamp")
    fun deleteOldProcessed(oldestTimestamp: Long)
}

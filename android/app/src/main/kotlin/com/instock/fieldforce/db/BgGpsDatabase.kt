package com.instock.fieldforce.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase

@Database(entities = [BgGpsPoint::class], version = 2, exportSchema = false)
abstract class BgGpsDatabase : RoomDatabase() {
    abstract fun bgGpsPointDao(): BgGpsPointDao

    companion object {
        @Volatile
        private var INSTANCE: BgGpsDatabase? = null

        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add new columns
                database.execSQL("ALTER TABLE bg_gps_points ADD COLUMN speed REAL")
                database.execSQL("ALTER TABLE bg_gps_points ADD COLUMN bearing REAL")
                database.execSQL("ALTER TABLE bg_gps_points ADD COLUMN altitude REAL")
                
                // Add indices for better performance
                database.execSQL("CREATE INDEX IF NOT EXISTS index_bg_gps_points_processed_timestamp ON bg_gps_points (processed, timestamp)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_bg_gps_points_timestamp ON bg_gps_points (timestamp)")
            }
        }

        fun getInstance(context: Context): BgGpsDatabase {
            return INSTANCE ?: synchronized(this) {
                val inst = Room.databaseBuilder(
                    context.applicationContext, 
                    BgGpsDatabase::class.java, 
                    "bg_gps_db"
                )
                    .addMigrations(MIGRATION_1_2)
                    .build()
                INSTANCE = inst
                inst
            }
        }
    }
}

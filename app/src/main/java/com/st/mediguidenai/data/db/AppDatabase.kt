package com.st.mediguidenai.data.db

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(
    entities = [
        FaqEntity::class,
        FaqFtsEntity::class // убедись, что класс называется именно так
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun faqDao(): FaqDao
}

package com.st.mediguidenai.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface FaqDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(items: List<FaqEntity>)

    @Query("SELECT * FROM faq ORDER BY id ASC")
    fun getAllFaqs(): Flow<List<FaqEntity>>

    // Правильный запрос к FTS-таблице
    @Query("SELECT * FROM faq WHERE rowid IN (SELECT rowid FROM faq_fts WHERE faq_fts MATCH :query)")
    fun searchFaqs(query: String): Flow<List<FaqEntity>>
}


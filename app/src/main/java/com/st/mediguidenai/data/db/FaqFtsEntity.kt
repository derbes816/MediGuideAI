package com.st.mediguidenai.data.db

import androidx.room.Entity
import androidx.room.Fts4

@Entity(tableName = "faq_fts")
@Fts4(contentEntity = FaqEntity::class)
data class FaqFtsEntity(
    // Эти поля должны совпадать с полями в FaqEntity для индексации
    val question: String,
    val answer: String
)


package com.st.mediguidenai.data.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "faq")
data class FaqEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val question: String,
    val answer: String
)


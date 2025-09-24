package com.st.mediguidenai.data.db

import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.BufferedReader
import java.io.InputStreamReader

object FaqSeeder {
    fun seed(context: Context, db: AppDatabase) {
        CoroutineScope(Dispatchers.IO).launch {
            val input = context.assets.open("database/faq_en.db")
            val reader = BufferedReader(InputStreamReader(input))
            val items = mutableListOf<FaqEntity>()
            reader.useLines { lines ->
                lines.forEach { line ->
                    val parts = line.split("|")
                    if (parts.size >= 2) {
                        items.add(FaqEntity(question = parts[0], answer = parts[1]))
                    }
                }
            }
            db.faqDao().insertAll(items)
        }
    }
}

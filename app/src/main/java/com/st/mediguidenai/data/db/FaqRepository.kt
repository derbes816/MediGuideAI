package com.st.mediguidenai.data.db

import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FaqRepository @Inject constructor(
    private val dao: FaqDao
) {
    fun getAllFaqs() = dao.getAllFaqs()
    fun searchFaqs(query: String) = dao.searchFaqs(query)
    suspend fun insertAll(items: List<FaqEntity>) = dao.insertAll(items)
}

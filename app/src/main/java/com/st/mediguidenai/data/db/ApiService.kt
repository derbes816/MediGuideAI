package com.st.mediguidenai.data.db

import retrofit2.http.GET
import retrofit2.http.Query

interface ApiService {
    @GET("faq/version")
    suspend fun getDbVersion(): Int

    @GET("faq/search")
    suspend fun searchFaq(@Query("q") query: String): List<FaqEntity>

    @GET("faq/updates")
    suspend fun getUpdates(@Query("since") version: Int): List<FaqEntity>
}

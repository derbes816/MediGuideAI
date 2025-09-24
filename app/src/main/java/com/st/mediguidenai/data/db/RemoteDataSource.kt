package com.st.mediguidenai.data.db

import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class RemoteDataSource @Inject constructor(
    private val api: ApiService
) {
    suspend fun getDbVersion(): Int = api.getDbVersion()
    suspend fun search(query: String): List<FaqEntity> = api.searchFaq(query)
    suspend fun getUpdates(since: Int): List<FaqEntity> = api.getUpdates(since)
}

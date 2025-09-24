package com.st.mediguidenai.data.db

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DbSyncManager @Inject constructor(
    private val local: FaqRepository,
    private val remote: RemoteDataSource
) {
    suspend fun sync(currentVersion: Int) = withContext(Dispatchers.IO) {
        val serverVersion = remote.getDbVersion()
        if (serverVersion > currentVersion) {
            val updates = remote.getUpdates(currentVersion)
            if (updates.isNotEmpty()) {
                local.insertAll(updates)
            }
        }
    }
}

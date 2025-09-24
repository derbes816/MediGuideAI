package com.st.mediguidenai

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.st.mediguidenai.data.db.FaqEntity
import com.st.mediguidenai.data.db.FaqRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val repository: FaqRepository
) : ViewModel() {

    val allFaqs: StateFlow<List<FaqEntity>> =
        repository.getAllFaqs()
            .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    fun searchFaqs(query: String): StateFlow<List<FaqEntity>> =
        repository.searchFaqs(query)
            .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())
}

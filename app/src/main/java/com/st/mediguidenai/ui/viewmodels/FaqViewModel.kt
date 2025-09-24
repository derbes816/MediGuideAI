package com.st.mediguidenai.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.st.mediguidenai.data.db.FaqEntity
import com.st.mediguidenai.data.db.FaqRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class FaqViewModel @Inject constructor(
    private val repository: FaqRepository
) : ViewModel() {

    private val _faqs = MutableStateFlow<List<FaqEntity>>(emptyList())
    val faqs: StateFlow<List<FaqEntity>> = _faqs.asStateFlow()

    fun getAllFaqs() {
        viewModelScope.launch {
            repository.getAllFaqs().collect { _faqs.value = it }
        }
    }

    fun searchFaqs(query: String) {
        viewModelScope.launch {
            repository.searchFaqs(query).collect { _faqs.value = it }
        }
    }
}

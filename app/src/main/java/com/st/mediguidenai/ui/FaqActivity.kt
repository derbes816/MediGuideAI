package com.st.mediguidenai.ui

import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.st.mediguidenai.MainViewModel
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch

@AndroidEntryPoint
class FaqActivity : AppCompatActivity() {

    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        lifecycleScope.launch {
            viewModel.allFaqs.collect { list ->
                // TODO: обнови UI списком FAQ
            }
        }

        lifecycleScope.launch {
            viewModel.searchFaqs("пример").collect { list ->
                // TODO: обнови UI результатами поиска
            }
        }
    }
}

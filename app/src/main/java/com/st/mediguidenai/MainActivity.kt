package com.st.mediguidenai

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.st.mediguidenai.data.db.FaqEntity
import com.st.mediguidenai.ui.theme.MediGuideAITheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MediGuideAITheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val faqs by viewModel.allFaqs.collectAsStateWithLifecycle()
                    FaqList(faqs)
                }
            }
        }
    }
}

@Composable
fun FaqList(faqs: List<FaqEntity>, modifier: Modifier = Modifier) {
    LazyColumn(modifier = modifier) {
        items(faqs) { faq ->
            FaqItem(question = faq.question, answer = faq.answer)
        }
    }
}

@Composable
fun FaqItem(question: String, answer: String, modifier: Modifier = Modifier) {
    Column(modifier = modifier.padding(16.dp)) {
        Text(
            text = question,
            style = MaterialTheme.typography.titleMedium
        )
        Text(
            text = answer,
            style = MaterialTheme.typography.bodyMedium
        )
    }
}


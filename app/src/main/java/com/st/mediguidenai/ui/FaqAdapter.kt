package com.st.mediguidenai.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.st.mediguidenai.data.db.FaqEntity
import com.st.mediguidenai.databinding.ItemFaqBinding

class FaqAdapter : ListAdapter<FaqEntity, FaqViewHolder>(FaqDiffCallback()) {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): FaqViewHolder {
        val binding = ItemFaqBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return FaqViewHolder(binding)
    }

    override fun onBindViewHolder(holder: FaqViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
}

class FaqViewHolder(private val binding: ItemFaqBinding) : RecyclerView.ViewHolder(binding.root) {
    fun bind(item: FaqEntity) {
        binding.question.text = item.question
        binding.answer.text = item.answer
    }
}

class FaqDiffCallback : DiffUtil.ItemCallback<FaqEntity>() {
    override fun areItemsTheSame(oldItem: FaqEntity, newItem: FaqEntity) = oldItem.id == newItem.id
    override fun areContentsTheSame(oldItem: FaqEntity, newItem: FaqEntity) = oldItem == newItem
}

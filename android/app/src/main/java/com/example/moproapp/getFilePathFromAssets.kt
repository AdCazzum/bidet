package com.example.moproapp

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import java.io.File

@Composable
fun getFilePathFromAssets(name: String): String {
    val context = LocalContext.current
    return remember {
        val assetManager = context.assets
        val inputStream = assetManager.open(name)
        val file = File(context.filesDir, name)
        copyFile(inputStream, file.outputStream())
        file.absolutePath
    }
}
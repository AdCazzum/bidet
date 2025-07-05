package com.example.moproapp

import MultiplierComponent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

import android.app.PendingIntent
import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.provider.Settings
import android.widget.TextView
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.ui.graphics.Color


class MainActivity : ComponentActivity() {

    private var nfcAdapter: NfcAdapter? = null
    private lateinit var nfcText: TextView
    private var onTagScanned: ((String) -> Unit)? = null

    private lateinit var pendingIntent: PendingIntent

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        if (nfcAdapter == null) {
            Toast.makeText(this, "NFC is not available", Toast.LENGTH_LONG).show()
            finish()
            return
        }

        if (!nfcAdapter!!.isEnabled) {
            Toast.makeText(this, "Enable NFC in settings", Toast.LENGTH_LONG).show()
            startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
        }

        setContent {
            // State for tag name and scan status
            var tagContent by remember { mutableStateOf("Scan an NFC tag...") }
            var scanState by remember { mutableStateOf(ScanState.Idle) }
            var scannedName by remember { mutableStateOf("") }
            val scannedSet = remember { mutableStateListOf<String>() }

            // Assign the lambda to handle tag scan event
            onTagScanned = { tagId ->
                tagContent = "NFC Tag Content: $tagId"

                if (scannedSet.contains(tagId)) {
                    scanState = ScanState.AlreadyScanned
                } else {
                    scannedSet.add(tagId)
                    scanState = ScanState.Success
                }

                scannedName = tagId
            }

            MainScreen(
                tagText = tagContent,
                scanState = scanState,
                scannedName = scannedName
            )
        }

    }

    override fun onResume() {
        super.onResume()
        val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)
        nfcAdapter?.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        nfcAdapter?.disableForegroundDispatch(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
        tag?.let {
            val ndef = Ndef.get(tag)
            ndef?.connect()
            val message: NdefMessage? = ndef?.ndefMessage
            val records = message?.records
            val payload = records?.get(0)?.payload
            val text = payload?.drop(3)?.toByteArray()?.toString(Charsets.UTF_8) // skip lang bytes
            //nfcText.text = "NFC Tag Content: $text"
            onTagScanned?.invoke(text.toString())
            ndef?.close()
        }
    }
}

enum class ScanState {
    Idle, Success, AlreadyScanned
}

@Composable
fun MainScreen(
    tagText: String,
    scannedName: String = "",
    scanState: ScanState = ScanState.Idle
) {
    var selectedTab by remember { mutableStateOf(0) }
    val tabs = listOf("Circom", "Halo2", "Noir")

    // Set background color based on scan state
    val backgroundColor = when (scanState) {
        ScanState.Success -> Color(0xFFD1F5D3) // soft green
        ScanState.AlreadyScanned -> Color(0xFFF9D5D5) // soft red
        ScanState.Idle -> Color(0xFFECECEC) // neutral gray
    }

    Scaffold(
        modifier = Modifier
            .fillMaxSize()
            .background(backgroundColor)
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
        ) {
            Text("NFC Reader", fontSize = 24.sp)

            Spacer(modifier = Modifier.height(20.dp))

            // Scan feedback message
            when (scanState) {
                ScanState.Idle -> {
                    Text("Waiting for a tag...", fontSize = 18.sp, color = Color.DarkGray)
                }
                ScanState.Success -> {
                    Text("You just scanned $scannedName! 🎉", fontSize = 18.sp, color = Color(0xFF2E7D32))
                }
                ScanState.AlreadyScanned -> {
                    Text("You already scanned $scannedName. 🥺", fontSize = 18.sp, color = Color(0xFFC62828))
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Tabs and content
            TabRow(selectedTabIndex = selectedTab) {
                tabs.forEachIndexed { index, title ->
                    Tab(
                        text = { Text(title) },
                        selected = selectedTab == index,
                        onClick = { selectedTab = index }
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            when (selectedTab) {
                0 -> MultiplierComponent()
                1 -> FibonacciComponent()
                2 -> NoirComponent()
            }
        }
    }
}
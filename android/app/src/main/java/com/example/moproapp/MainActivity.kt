package com.example.moproapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

import android.app.PendingIntent
import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.provider.Settings
import android.widget.Toast
import androidx.compose.foundation.shape.RoundedCornerShape


class MainActivity : ComponentActivity() {

    private var nfcAdapter: NfcAdapter? = null
    private var onTagScanned: ((String) -> Unit)? = null

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
            var scanState by remember { mutableStateOf(ScanState.Idle) }
            var scannedName by remember { mutableStateOf("") }
            val scannedSet = remember { mutableStateListOf<String>() }

            LaunchedEffect(scanState) {
                if (scanState != ScanState.Idle) {
                    kotlinx.coroutines.delay(1000L) // 1 second delay
                    scanState = ScanState.Idle
                    scannedName = ""
                }
            }


            onTagScanned = { tagId ->
                if (scannedSet.contains(tagId)) {
                    scanState = ScanState.AlreadyScanned
                } else {
                    scannedSet.add(tagId)
                    scanState = ScanState.Success
                }

                scannedName = tagId
            }

            MainScreen(
                scanState = scanState,
                scannedName = scannedName
            )
        }
    }

    override fun onResume() {
        super.onResume()
        val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pendingIntent =
            PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)
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
    scannedName: String = "",
    scanState: ScanState = ScanState.Idle
) {

    // Gradient background based on scan state
    val backgroundGradient = Brush.verticalGradient(
        colors = when (scanState) {
            ScanState.Success -> listOf(Color(0xFFD1F5D3), Color(0xFFA8E6A3))
            ScanState.AlreadyScanned -> listOf(Color(0xFFF9D5D5), Color(0xFFF4B6B6))
            ScanState.Idle -> listOf(Color(0xFFECECEC), Color(0xFFDCDCDC))
        }
    )

    Scaffold(
        modifier = Modifier
            .fillMaxSize()
            .background(brush = backgroundGradient)
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
        ) {
            Text("Bidet \uD83D\uDEBD", fontSize = 24.sp)

            Spacer(modifier = Modifier.height(20.dp))

            // Cute scan feedback UI
            CuteScanFeedback(scanState, scannedName)
        }
    }
}
@Composable
fun CuteScanFeedback(scanState: ScanState, scannedName: String) {
    val emoji = when (scanState) {
        ScanState.Success -> "🎉"
        ScanState.AlreadyScanned -> "🥺"
        ScanState.Idle -> "\uD83D\uDEBD"
    }

    val message = when (scanState) {
        ScanState.Success -> "You just scanned $scannedName!"
        ScanState.AlreadyScanned -> "You already scanned $scannedName."
        ScanState.Idle -> "Waiting for a tag..."
    }

    Card(
        shape = RoundedCornerShape(16.dp),
        elevation = CardDefaults.cardElevation(8.dp),
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight(0.75f)  // fill 75% of vertical space
            .padding(horizontal = 16.dp),
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = emoji,
                    fontSize = 80.sp,
                    modifier = Modifier.padding(bottom = 24.dp)
                )
                Text(
                    text = message,
                    fontSize = 26.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.DarkGray,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = 16.dp)
                )
            }
        }
    }
}

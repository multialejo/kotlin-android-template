package com.example.hellokotlin

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.hellokotlin.ui.theme.HelloKotlinTheme

/**
 * An Activity is one screen of an Android app. This is the one that opens
 * when you tap the "Hello Kotlin" icon (see AndroidManifest.xml).
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        // setContent { ... } describes the UI with Jetpack Compose functions.
        setContent {
            HelloKotlinTheme {
                HelloScreen()
            }
        }
    }
}

/**
 * A @Composable function draws a piece of UI. When the state it reads changes,
 * Compose calls it again and the screen updates automatically.
 */
@Composable
fun HelloScreen() {
    // "var ... by rememberSaveable" = a value the screen remembers, even when you rotate the phone.
    var name by rememberSaveable { mutableStateOf("") }
    var count by rememberSaveable { mutableIntStateOf(0) }

    Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(24.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                text = greetingFor(name),
                style = MaterialTheme.typography.headlineLarge,
                color = MaterialTheme.colorScheme.primary,
            )
            Spacer(Modifier.height(24.dp))

            OutlinedTextField(
                value = name,
                onValueChange = { name = it }, // "it" is the new text the user typed
                label = { Text("What's your name?") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
            )
            Spacer(Modifier.height(24.dp))

            Text(tapMessage(count), style = MaterialTheme.typography.bodyLarge)
            Spacer(Modifier.height(12.dp))

            Button(onClick = { count++ }) {
                Text("Tap me")
            }
            if (count > 0) {
                OutlinedButton(onClick = { count = 0 }) {
                    Text("Reset")
                }
            }
        }
    }
}

/** Lets Android Studio show this screen without a phone. Safe to ignore otherwise. */
@Preview(showBackground = true)
@Composable
fun HelloScreenPreview() {
    HelloKotlinTheme {
        HelloScreen()
    }
}

package com.example.hellokotlin

/**
 * Plain Kotlin logic, kept separate from the UI so it can be unit-tested
 * without a phone (see app/src/test/.../GreetingTest.kt).
 */
fun greetingFor(name: String): String {
    // trim() removes spaces at the start/end; ifBlank picks a default when nothing was typed.
    val who = name.trim().ifBlank { "Android" }
    return "Hello, $who!" // "$who" inserts the variable into the text (string template)
}

fun tapMessage(count: Int): String = when (count) {
    0 -> "You haven't tapped the button yet."
    1 -> "You tapped the button 1 time."
    else -> "You tapped the button $count times."
}

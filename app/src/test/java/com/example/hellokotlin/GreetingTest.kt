package com.example.hellokotlin

import org.junit.Assert.assertEquals
import org.junit.Test

/** Unit tests run on your computer (in the container), no phone needed: ./gradlew test */
class GreetingTest {
    @Test
    fun greetsByName() {
        assertEquals("Hello, Ada!", greetingFor("  Ada "))
    }

    @Test
    fun fallsBackWhenNameIsBlank() {
        assertEquals("Hello, Android!", greetingFor("   "))
    }

    @Test
    fun tapMessageUsesSingularForOne() {
        assertEquals("You tapped the button 1 time.", tapMessage(1))
    }
}

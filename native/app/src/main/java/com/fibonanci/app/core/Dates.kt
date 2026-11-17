package com.fibonanci.app.core

import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId

// dates are stored as epoch millis; calendar math runs in the device zone.

fun nowMillis(): Long = System.currentTimeMillis()

fun Long.toLocalDateTime(): LocalDateTime =
    LocalDateTime.ofInstant(Instant.ofEpochMilli(this), ZoneId.systemDefault())

fun Long.toLocalDate(): LocalDate = toLocalDateTime().toLocalDate()

fun LocalDateTime.toEpochMillis(): Long = atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()

fun LocalDate.toEpochMillis(): Long = atStartOfDay().toEpochMillis()

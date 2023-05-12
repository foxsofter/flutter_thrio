package com.foxsofter.flutter_thrio.extension

import java.lang.reflect.Field
import java.lang.reflect.Method

fun Any.callMethod(name: String, vararg args: Any?): Any? {
    return javaClass
        .getDeclaredMethod(name)
        .apply { isAccessible = true }
        .invoke(this, *args)
}

fun Any.callSuperMethod(name: String, vararg args: Any?): Any? {
    return getSuperMethod(name)
        .apply { isAccessible = true }
        .invoke(this, *args)
}

inline fun <reified T> Any.getFieldValue(name: String): T {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        val r = it.get(this)
        return@let if (r is T) r else throw NoSuchFieldError(name)
    }
}

inline fun <reified T> Any.getFieldNullableValue(name: String): T? {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        val r = it.get(this)
        return@let if (r is T) r else null
    }
}

inline fun <reified T> Any.setFieldValue(name: String, value: T?) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.set(this, value)
    }
}

inline fun <reified T> Any.getSuperFieldValue(name: String): T {
    return getSuperField(name).let {
        it.isAccessible = true
        val r = it.get(this)
        return@let if (r is T) r else throw NoSuchFieldError(name)
    }
}

inline fun <reified T> Any.getSuperFieldNullableValue(name: String): T? {
    return getSuperField(name).let {
        it.isAccessible = true
        val r = it.get(this)
        return@let if (r is T) r else null
    }
}

fun Any.getSuperMethodOrNull(name: String): Method? {
    var sc = javaClass.superclass
    var method = sc.declaredMethods.firstOrNull {
        it.name == name
    }
    while (method == null && sc != null) {
        sc = sc.superclass
        method = sc.declaredMethods.firstOrNull { it.name == name }
    }
    return method
}

fun Any.getSuperMethod(name: String): Method =
    getSuperMethodOrNull(name) ?: throw NoSuchMethodError("$name not found")

fun Any.getSuperFieldOrNull(name: String): Field? {
    var sc = javaClass.superclass
    var field = sc.declaredFields.firstOrNull { it.name == name }
    while (field == null && sc != null) {
        sc = sc.superclass
        field = sc.declaredFields.firstOrNull { it.name == name }
    }
    return field
}

fun Any.getSuperField(name: String): Field =
    getSuperFieldOrNull(name) ?: throw NoSuchFieldError("$name not found")

inline fun <reified T> Any.setSuperFieldValue(name: String, value: T?) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.set(this, value)
    }
}


fun Any.getFieldBoolean(name: String): Boolean {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getBoolean(this)
    }
}

fun Any.getSuperFieldBoolean(name: String): Boolean {
    return getSuperField(name).let {
        it.isAccessible = true
        return@let it.getBoolean(this)
    }
}

fun Any.setFieldBoolean(name: String, value: Boolean) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.setBoolean(this, value)
    }
}

fun Any.setSuperFieldBoolean(name: String, value: Boolean) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setBoolean(this, value)
    }
}

fun Any.getFieldByte(name: String): Byte {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getByte(this)
    }
}

fun Any.getSuperFieldByte(name: String): Byte {
    return getSuperField(name).let {
        it.isAccessible = true
        return@let it.getByte(this)
    }
}

fun Any.setSuperFieldByte(name: String, value: Byte) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setByte(this, value)
    }
}

fun Any.getFieldChar(name: String): Char {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getChar(this)
    }
}

fun Any.getSuperFieldChar(name: String): Char {
    return getSuperField(name).let {
        it.isAccessible = true
        return@let it.getChar(this)
    }
}

fun Any.setFieldChar(name: String, value: Char) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.setChar(this, value)
    }
}

fun Any.setSuperFieldChar(name: String, value: Char) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setChar(this, value)
    }
}

fun Any.getFieldShort(name: String): Short {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getShort(this)
    }
}

fun Any.setFieldShort(name: String, value: Short) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.setShort(this, value)
    }
}

fun Any.setSuperFieldShort(name: String, value: Short) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setShort(this, value)
    }
}

fun Any.getFieldInt(name: String): Int {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getInt(this)
    }
}

fun Any.getSuperFieldInt(name: String): Int {
    return getSuperField(name).let {
        it.isAccessible = true
        return@let it.getInt(this)
    }
}

fun Any.setFieldInt(name: String, value: Int) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.setInt(this, value)
    }
}

fun Any.setSuperFieldInt(name: String, value: Int) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setInt(this, value)
    }
}

fun Any.getFieldLong(name: String): Long {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getLong(this)
    }
}

fun Any.getSuperFieldLong(name: String): Long {
    return getSuperField(name).let {
        it.isAccessible = true
        return@let it.getLong(this)
    }
}

fun Any.setFieldLong(name: String, value: Long) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.setLong(this, value)
    }
}

fun Any.setSuperFieldLong(name: String, value: Long) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setLong(this, value)
    }
}

fun Any.getFieldDouble(name: String): Double {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getDouble(this)
    }
}

fun Any.getSuperFieldDouble(name: String): Double {
    return getSuperField(name).let {
        it.isAccessible = true
        return@let it.getDouble(this)
    }
}

fun Any.setFieldDouble(name: String, value: Double) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.setDouble(this, value)
    }
}

fun Any.setSuperFieldDouble(name: String, value: Double) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setDouble(this, value)
    }
}

fun Any.getFieldFloat(name: String): Float {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        return@let it.getFloat(this)
    }
}

fun Any.getSuperFieldFloat(name: String): Float {
    return getSuperField(name).let {
        it.isAccessible = true
        return@let it.getFloat(this)
    }
}

fun Any.setFieldFloat(name: String, value: Float) {
    return javaClass.getDeclaredField(name).let {
        it.isAccessible = true
        it.setFloat(this, value)
    }
}

fun Any.setSuperFieldFloat(name: String, value: Float) {
    return getSuperField(name).let {
        it.isAccessible = true
        it.setFloat(this, value)
    }
}

package com.foxsofter.flutter_thrio_example

data class People(val props: Map<String, Any?>) {
    val name: String by props
    val age: Long by props
    val sex: String by props

    fun toJson(): Map<String, Any?> {
        return props
    }
}

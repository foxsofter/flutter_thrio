package com.foxsofter.flutter_thrio_example

import io.flutter.embedding.android.ThrioRootFragmentActivity

class MainActivity: ThrioRootFragmentActivity() {
    override fun shouldMoveToBack(): Boolean {
        return true
    }
}
package com.foxsofter.flutter_thrio_example

import io.flutter.embedding.android.ThrioFlutterFragmentActivity

class MainActivity: ThrioFlutterFragmentActivity() {
    override fun shouldMoveToBack(): Boolean {
        return true
    }
}
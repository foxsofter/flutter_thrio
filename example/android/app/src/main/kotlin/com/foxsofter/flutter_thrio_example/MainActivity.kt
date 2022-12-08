package com.foxsofter.flutter_thrio_example

import io.flutter.embedding.android.ThrioFlutterActivity

class MainActivity: ThrioFlutterActivity() {
    override fun shouldMoveToBack(): Boolean {
        return true
    }
}
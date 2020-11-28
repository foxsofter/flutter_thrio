package com.hellobike.thrio_example

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.hellobike.flutter.thrio.navigator.ThrioNavigator
import kotlinx.android.synthetic.main.activity_native.*

class Native3Activity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native)
        initView()

        // 通过这种方式，间接的让 FlutterActivity 作为根部的 Activity
        ThrioNavigator.push("/biz1/flutter1") {
            finish()
        }
    }

    private fun initView() {
        tv_native.text = ""
    }
}

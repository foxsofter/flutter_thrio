package com.hellobike.thrio_example

import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import com.hellobike.flutter.thrio.ThrioNavigator
import kotlinx.android.synthetic.main.activity_native.*

class Native2Activity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native)
        initView()
    }

    private fun initView() {
        tv_native.text = "Native 2"
        btn_native_new.setOnClickListener {
            startActivity(Intent(this, Native2Activity::class.java))
        }
        btn_native_top.setOnClickListener {
            startActivity(Intent(this, Native2Activity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                addFlags(FLAG_ACTIVITY_CLEAR_TOP)
            })
        }
        btn_native_next.setOnClickListener {
            startActivity(Intent(this, Native3Activity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                addFlags(FLAG_ACTIVITY_CLEAR_TOP)
            })
        }
        btn_flutter.setOnClickListener {
            ThrioNavigator.push(this, "flutter2")
            //            startActivity(Intent(this, FlutterActivity::class.java))
        }
    }
}

package com.hellobike.thrio_example

import android.app.Activity
import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP
import android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import com.hellobike.flutter.thrio.NavigationBuilder
import com.hellobike.flutter.thrio.OnNotifyListener
import com.hellobike.flutter.thrio.ThrioNavigator
import kotlinx.android.synthetic.main.activity_native.*
import java.util.function.Function

class Native1Activity : AppCompatActivity(), OnNotifyListener {

    private fun initView() {
        tv_native.text = "Native 1"
        btn_1.setOnClickListener {
            ThrioNavigator.push(this, "biz1/flutter1",
                    mapOf("k1" to 1),
                    false,
                    poppedResult = {
                        Log.e("Thrio", "native1 popResult call params $it")
                    }
            )
        }
        btn_2.setOnClickListener {
            ThrioNavigator.pop(this, "native 1 popResult")
        }
        btn_flutter.setOnClickListener {

        }
    }

    private fun initFlutter() {
        ThrioNavigator.registerNavigationBuilder("native1", object : NavigationBuilder {
            override fun getActivityClz(url: String): Class<out Activity> {
                return Native1Activity::class.java
            }
        })
        ThrioNavigator.registerNavigationBuilder("native2", object : NavigationBuilder {
            override fun getActivityClz(url: String): Class<out Activity> {
                return Native2Activity::class.java
            }
        })
    }

    override fun onNotify(name: String, params: Any?) {
        // result with url
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.e("FlutterView", "onCreate activity $this")
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native)
        initView()
        initFlutter()
    }
}


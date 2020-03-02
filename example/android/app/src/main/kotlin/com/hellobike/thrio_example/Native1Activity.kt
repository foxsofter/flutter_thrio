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

class Native1Activity : AppCompatActivity(), OnNotifyListener {

    private fun initView() {
        tv_native.text = "Native 1"
        btn_native_new.setOnClickListener {
            startActivity(Intent(this, Native1Activity::class.java))
        }
        btn_native_top.setOnClickListener {
            //            startActivity(Intent(this, Native1Activity::class.java).apply {
//                addFlags(FLAG_ACTIVITY_SINGLE_TOP)
//                addFlags(FLAG_ACTIVITY_CLEAR_TOP)
//            })
            ThrioNavigator.popTo(this, "native1")
        }
        btn_native_next.setOnClickListener {
            startActivity(Intent(this, Native2Activity::class.java).apply {
                addFlags(FLAG_ACTIVITY_SINGLE_TOP)
                addFlags(FLAG_ACTIVITY_CLEAR_TOP)
            })
        }
        btn_flutter.setOnClickListener {
            ThrioNavigator.push(this, "flutter1",
                    mapOf("k1" to 1),
                    false
            )
        }
    }

    private fun initFlutter() {
        ThrioNavigator.registerNavigationBuilder("native1", object : NavigationBuilder {
            override fun getActivityClz(url: String): Class<out Activity> {
                return Native1Activity::class.java
            }
        })
    }

    override fun onNotify(url: String, index: Int, name: String, params: Map<String, Any>) {
        // result with url
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.e("FlutterView", "onCreate activity $this")
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native)
        initView()
        initFlutter()
    }

    override fun onRestart() {
        Log.e("FlutterView", "onRestart activity $this")
        super.onRestart()
//        Log.e("Thrio", "activity $activity onRestart attach")
//        flutterEngine?.apply {
//            activityControlSurface.attachToActivity(activity, lifecycle)
//        }
    }

    override fun onStart() {
        Log.e("FlutterView", "onStart activity $this")
        super.onStart()
    }

    override fun onResume() {
        Log.e("FlutterView", "onResume activity $this")
        super.onResume()
    }

    override fun onPause() {
        Log.e("FlutterView", "onPause activity $this finishing $isFinishing")
        super.onPause()
    }

    override fun onStop() {
        Log.e("FlutterView", "onStop activity $this finishing $isFinishing")
        super.onStop()
    }

    override fun onDestroy() {
        Log.e("FlutterView", "onDestroy activity $this finishing $isFinishing")
        super.onDestroy()
    }

    override fun finish() {
        Log.e("FlutterView", "finish activity $this")
        super.finish()
    }
}


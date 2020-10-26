package com.hellobike.thrio_example

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.hellobike.flutter.thrio.navigator.RouteSettings
import com.hellobike.flutter.thrio.navigator.ThrioNavigator
import io.flutter.Log
import kotlinx.android.synthetic.main.activity_native.*

class Native2Activity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native2)
        initView()
    }

    private fun initView() {
        tv_native.text = "native 2"

        btn_10.setOnClickListener {
            ThrioNavigator.push("/biz2/flutter2",
                    params = mapOf("k1" to 1),
                    result = {
                        Log.v("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.v("Thrio", "/biz1/native2 poppedResult call params $it")
                    }
            )
        }

        btn_11.setOnClickListener {
            ThrioNavigator.remove("/biz2/flutter2") {
                Log.v("Thrio", "push result data $it")
            }
        }

        btn_12.setOnClickListener {
            ThrioNavigator.push("/biz1/native1",
                    params = mapOf("k1" to 1),
                    result = {
                        Log.v("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.v("Thrio", "/biz1/native2 poppedResult call params $it")
                    }
            )
        }

        btn_13.setOnClickListener {
            ThrioNavigator.remove("/biz1/native1") {
                Log.v("Thrio", "push result data $it")
            }
        }

        btn_20.setOnClickListener {
            ThrioNavigator.popTo("/biz1/native1")
        }

        btn_21.setOnClickListener {
            val intent = Intent(this, Native1Activity::class.java)
            startActivity(intent)
        }

        btn_3.setOnClickListener {
            ThrioNavigator.pop("native 2 popResult")
        }
    }

    override fun onResume() {
        super.onResume()

        val data = intent.getSerializableExtra("NAVIGATION_ROUTE_SETTINGS")

        if (data != null) {
            @Suppress("UNCHECKED_CAST")
            RouteSettings.fromArguments(data as Map<String, Any?>)?.apply {
                tv_native.text = "/biz1/native2 index $index"
            }
        }
    }
}

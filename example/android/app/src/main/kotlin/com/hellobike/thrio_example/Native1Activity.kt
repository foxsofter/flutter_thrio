package com.hellobike.thrio_example

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.hellobike.flutter.thrio.navigator.PageNotifyListener
import com.hellobike.flutter.thrio.navigator.RouteSettings
import com.hellobike.flutter.thrio.navigator.ThrioNavigator
import io.flutter.Log
import kotlinx.android.synthetic.main.activity_native.*

class Native1Activity : AppCompatActivity(), PageNotifyListener {

    private fun initView() {
        tv_native.text = "Native 1"

        btn_10.setOnClickListener {
            ThrioNavigator.push("/biz1/flutter1",
                    params = People(mapOf(
                            "name" to "foxsofter",
                            "age" to 100,
                            "sex" to "x")),
                    result = {
                        Log.i("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.i("Thrio", "/biz1/native1 poppedResult call params $it")
                    }
            )
        }

        btn_11.setOnClickListener {
            ThrioNavigator.remove("/biz1/flutter1") {
                Log.i("Thrio", "push result data $it")
            }
        }

        btn_12.setOnClickListener {
            ThrioNavigator.push("/biz2/flutter2",
                    params = mapOf("k1" to 1),
                    result = {
                        Log.i("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.i("Thrio", "/biz1/native1 poppedResult call params $it")
                    }
            )
        }

        btn_13.setOnClickListener {
            ThrioNavigator.remove("/biz2/flutter2") {
                Log.i("Thrio", "push result data $it")
            }
        }

        btn_20.setOnClickListener {
            ThrioNavigator.push("/biz1/native1",
                    mapOf("k1" to 1),
                    true,
                    result = {
                        Log.i("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.i("Thrio", "/biz1/native1 poppedResult call params $it")
                    }
            )
        }

        btn_21.setOnClickListener {
            ThrioNavigator.remove("/biz1/native1")
        }

        btn_22.setOnClickListener {
            ThrioNavigator.push("/biz2/native2",
                    mapOf("k1" to 1),
                    true,
                    result = {
                        Log.i("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.i("Thrio", "/biz1/native1 poppedResult call params $it")
                    }
            )
        }

        btn_23.setOnClickListener {
            ThrioNavigator.remove("/biz2/native2")
        }

        btn_3.setOnClickListener {
            ThrioNavigator.pop( People(mapOf(
                    "name" to "foxsofter",
                    "age" to 100,
                    "sex" to "from pop")))
        }
    }

    override fun onResume() {
        super.onResume()

        val data = intent.getSerializableExtra("NAVIGATION_ROUTE_SETTINGS")

        if (data != null) {
            @Suppress("UNCHECKED_CAST")
            RouteSettings.fromArguments(data as Map<String, Any?>)?.apply {
                tv_native.text = "/biz1/native1 index $index"
            }
        }
    }

    override fun onNotify(name: String, params: Any?) {
        Log.i("Thrio", "/biz1/native1 onNotify name $name params $params")
        // result with url
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i("Native1Activity", "onCreate activity $this")
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native)
        initView()
    }


}


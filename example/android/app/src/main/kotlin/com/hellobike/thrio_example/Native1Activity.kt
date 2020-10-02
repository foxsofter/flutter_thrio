package com.hellobike.thrio_example

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.hellobike.flutter.thrio.navigator.PageNotifyListener
import com.hellobike.flutter.thrio.navigator.RouteSettings
import com.hellobike.flutter.thrio.navigator.ThrioNavigator
import kotlinx.android.synthetic.main.activity_native.*

class Native1Activity : AppCompatActivity(), PageNotifyListener {

    private fun initView() {
        tv_native.text = "Native 1"

        btn_10.setOnClickListener {
            ThrioNavigator.push("/biz1/flutter1",
                    params = mapOf("k1" to 1),
                    result = {
                        Log.i("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.i("Thrio", "native1 poppedResult call params $it")
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
                        Log.i("Thrio", "native1 poppedResult call params $it")
                    }
            )
        }

        btn_13.setOnClickListener {
            ThrioNavigator.remove("/biz2/flutter2") {
                Log.i("Thrio", "push result data $it")
            }
        }

        btn_20.setOnClickListener {
            ThrioNavigator.push("native1",
                    mapOf("k1" to 1),
                    true,
                    result = {
                        Log.i("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.i("Thrio", "native1 poppedResult call params $it")
                    }
            )
        }

        btn_21.setOnClickListener {
            ThrioNavigator.remove("native1")
        }

        btn_22.setOnClickListener {
            ThrioNavigator.push("native2",
                    mapOf("k1" to 1),
                    true,
                    result = {
                        Log.i("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.i("Thrio", "native1 poppedResult call params $it")
                    }
            )
        }

        btn_23.setOnClickListener {
            ThrioNavigator.remove("native2")
        }

        btn_3.setOnClickListener {
            ThrioNavigator.pop("native 1 popResult")
        }
    }

    override fun onResume() {
        super.onResume()

        val data = intent.getSerializableExtra("NAVIGATION_ROUTE_SETTINGS")

        if (data != null) {
            RouteSettings.fromArguments(data as Map<String, Any?>)?.apply {
                tv_native.text = "native1 index $index"
            }
        }
    }

    override fun onNotify(name: String, params: Any?) {
        Log.i("Thrio", "native1 onNotify name $name params $params")
        // result with url
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i("FlutterView", "onCreate activity $this")
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native)
        initView()
    }


}


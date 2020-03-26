package com.hellobike.thrio_example

import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import com.hellobike.flutter.thrio.OnNotifyListener
import com.hellobike.flutter.thrio.ThrioNavigator
import kotlinx.android.synthetic.main.activity_native.*

class Native1Activity : AppCompatActivity(), OnNotifyListener {

    private fun initView() {
        tv_native.text = "Native 1"
        btn_1.setOnClickListener {
            ThrioNavigator.push(this, "biz1/flutter1",
                    mapOf("k1" to 1),
                    true,
                    poppedResult = {
                        Log.e("Thrio", "native1 popResult call params $it")
                    }
            ) {
                Log.e("Thrio", "push result data $it")
            }
        }
        btn_2.setOnClickListener {
            ThrioNavigator.push(this, "native1",
                    mapOf("k1" to 1),
                    true,
                    poppedResult = {
                        Log.e("Thrio", "native1 popResult call params $it")
                    }
            ) {
                Log.e("Thrio", "push result data $it")
            }
        }
        btn_3.setOnClickListener {
            ThrioNavigator.pop(this, "native 1 popResult")
        }
    }

    override fun onResume() {
        super.onResume()
        val key = intent.getLongExtra("KEY_THRIO_STACK_ID", -1)
        if (key != -1L) {
            tv_native.text = "Native 1 \r\nstackId $key"
        }
    }

    override fun onNotify(name: String, params: Any?) {
        Log.e("Thrio", "native1 onNotify name $name params $params")
        // result with url
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.e("FlutterView", "onCreate activity $this")
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native)
        initView()
    }
}


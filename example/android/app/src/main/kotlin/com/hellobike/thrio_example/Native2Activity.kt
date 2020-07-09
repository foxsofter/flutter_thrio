package com.hellobike.thrio_example

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.hellobike.flutter.thrio.navigator.ThrioNavigator
import kotlinx.android.synthetic.main.activity_native.*

class Native2Activity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native2)
        initView()
    }

    private fun initView() {
        tv_native.text = "Native 2"

        btn_10.setOnClickListener {
            ThrioNavigator.push("/biz2/flutter2",
                    params = mapOf("k1" to 1),
                    result = {
                        Log.e("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.e("Thrio", "native1 poppedResult call params $it")
                    }
            )
        }

        btn_11.setOnClickListener {
            ThrioNavigator.remove("/biz2/flutter2") {
                Log.e("Thrio", "push result data $it")
            }
        }

        btn_12.setOnClickListener {
            ThrioNavigator.push("native1",
                    params = mapOf("k1" to 1),
                    result = {
                        Log.e("Thrio", "push result data $it")
                    },
                    poppedResult = {
                        Log.e("Thrio", "native1 poppedResult call params $it")
                    }
            )
        }

        btn_13.setOnClickListener {
            ThrioNavigator.remove("native1") {
                Log.e("Thrio", "push result data $it")
            }
        }

        btn_20.setOnClickListener {
            ThrioNavigator.popTo("native1")
        }

        btn_21.setOnClickListener {
            val intent = Intent(this, Native1Activity::class.java)
            startActivity(intent)
        }

        btn_3.setOnClickListener {
            ThrioNavigator.pop("native 1 popResult")
        }
    }
}

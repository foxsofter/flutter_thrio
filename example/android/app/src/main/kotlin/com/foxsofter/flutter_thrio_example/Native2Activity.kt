package com.foxsofter.flutter_thrio_example

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import androidx.appcompat.app.AppCompatActivity
import com.foxsofter.flutter_thrio.navigator.PageNotifyListener
import com.foxsofter.flutter_thrio.navigator.RouteSettings
import com.foxsofter.flutter_thrio.navigator.ThrioNavigator
import com.foxsofter.flutter_thrio_example.databinding.ActivityNative2Binding
import io.flutter.Log

class Native2Activity : AppCompatActivity(), PageNotifyListener {
    private lateinit var binding: ActivityNative2Binding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityNative2Binding.inflate(LayoutInflater.from(this))
        setContentView(binding.root)
        initView()
    }

    private fun initView() {
        binding.tvNative.text = "native 2"

        binding.btn10.setOnClickListener {
            ThrioNavigator.push("/biz2/flutter2",
                params = mapOf("k1" to 1),
                result = {
                    Log.i("Thrio", "push result data $it")
                },
                poppedResult = {
                    Log.i("Thrio", "/biz2/native2 poppedResult call params $it")
                }
            )
        }

        binding.btn11.setOnClickListener {
            ThrioNavigator.remove("/biz2/flutter2") {
                Log.i("Thrio", "push result data $it")
            }
        }

        binding.btn12.setOnClickListener {
            ThrioNavigator.push("/biz1/native1",
                params = mapOf("k1" to 1),
                result = {
                    Log.i("Thrio", "push result data $it")
                },
                poppedResult = {
                    Log.i("Thrio", "/biz2/native2 poppedResult call params $it")
                }
            )
        }

        binding.btn13.setOnClickListener {
            ThrioNavigator.remove("/biz1/native1") {
                Log.i("Thrio", "push result data $it")
            }
        }

        binding.btn20.setOnClickListener {
            ThrioNavigator.popTo("/biz1/native1")
        }

        binding.btn21.setOnClickListener {
            val intent = Intent(this, Native1Activity::class.java)
            startActivity(intent)
        }

        binding.btn3.setOnClickListener {
            ThrioNavigator.pop("native 2 popResult")
        }

        binding.btnNotifyAll.setOnClickListener {
            ThrioNavigator.notify(name = "notify_all_page")
        }
    }

    override fun onResume() {
        super.onResume()

        val data = intent.getSerializableExtra("NAVIGATION_ROUTE_SETTINGS")

        if (data != null) {
            @Suppress("UNCHECKED_CAST")
            RouteSettings.fromArguments(data as Map<String, Any?>)?.apply {
                binding.tvNative.text = "/biz2/native2 index $index"
            }
        }
    }

    override fun onNotify(name: String, params: Any?) {
        Log.i("Thrio", "/biz2/native2 onNotify name $name params $params")
        // result with url
    }
}

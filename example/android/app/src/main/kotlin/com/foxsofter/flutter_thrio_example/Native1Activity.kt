package com.foxsofter.flutter_thrio_example

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import androidx.appcompat.app.AppCompatActivity
import com.foxsofter.flutter_thrio.extension.getRouteIndex
import com.foxsofter.flutter_thrio.navigator.PageNotifyListener
import com.foxsofter.flutter_thrio.navigator.ThrioNavigator
import com.foxsofter.flutter_thrio_example.databinding.ActivityNativeBinding
import io.flutter.Log

class Native1Activity : AppCompatActivity(), PageNotifyListener {
    private lateinit var binding: ActivityNativeBinding

    private fun initView() {
        binding.tvNative.text = getString(R.string.native1)

        binding.btn10.setOnClickListener {
            ThrioNavigator.push("/biz/biz1/flutter1/home",
                params = People(
                    mapOf(
                        "name" to "foxsofter",
                        "age" to 100,
                        "sex" to "x"
                    )
                ),
                result = {
                    Log.i("Thrio", "push result data $it")
                },
                poppedResult = {
                    Log.i("Thrio", "/biz1/native1 poppedResult call params $it")
                }
            )
        }

        binding.btn11.setOnClickListener {
            ThrioNavigator.remove("/biz/biz1/flutter1/home") {
                Log.i("Thrio", "push result data $it")
            }
        }
        binding.btn2.setOnClickListener {
            ThrioNavigator.popFlutter()
        }
        binding.btn12.setOnClickListener {
            ThrioNavigator.push("/biz/biz2/flutter2",
                params = mapOf("k1" to 1),
                result = {
                    Log.i("Thrio", "push result data $it")
                },
                poppedResult = {
                    Log.i("Thrio", "/biz1/native1 poppedResult call params $it")
                }
            )
        }

        binding.btn13.setOnClickListener {
            ThrioNavigator.remove("/biz/biz2/flutter2") {
                Log.i("Thrio", "push result data $it")
            }
        }

        binding.btn20.setOnClickListener {
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

        binding.btn21.setOnClickListener {
            ThrioNavigator.remove("/biz1/native1")
        }

        binding.btn22.setOnClickListener {
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

        binding.btn23.setOnClickListener {
            ThrioNavigator.remove("/biz2/native2")
        }

        binding.btn3.setOnClickListener {
            ThrioNavigator.pop(
                People(
                    mapOf(
                        "name" to "foxsofter",
                        "age" to 100,
                        "sex" to "from pop"
                    )
                )
            )
        }
    }

    @SuppressLint("SetTextI18n")
    override fun onResume() {
        super.onResume()

        val index = intent.getRouteIndex()
        if (index != null) binding.tvNative.text = "/biz1/native1 index $index"
    }

    override fun onNotify(name: String, params: Any?) {
        Log.i("Thrio", "/biz1/native1 onNotify name $name params $params")
        // result with url
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i("Native1Activity", "onCreate activity $this")
        super.onCreate(savedInstanceState)
        binding = ActivityNativeBinding.inflate(LayoutInflater.from(this))
        setContentView(binding.root)

        initView()
    }

}


package com.elaborium.kaouka

import android.content.Context
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.google.firebase.firestore.FirebaseFirestore
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.gms.tasks.OnFailureListener
import com.google.firebase.firestore.DocumentSnapshot

private val client = OkHttpClient()

suspend fun onConnection(context: Context,id:String): String = withContext(Dispatchers.IO) {
    val url = "https://elaborium.site/proxy/onConnection" // replace with your URL
    val json = JSONObject()
    json.put("id", id)

    val requestBody = json.toString().toRequestBody("application/json; charset=utf-8".toMediaType())
    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .build()

    val response = client.newCall(request).execute()
    if (response.isSuccessful) {
        response.body?.string() ?: "No response body"
    } else {
        "Request failed with code: ${response.code}"
    }
}

suspend fun onDisconnection(context: Context, id:String): String = withContext(Dispatchers.IO) {
    val url = "https://elaborium.site/proxy/onDisconnection" // replace with your URL
    val json = JSONObject()
    json.put("id", id)

    val requestBody = json.toString().toRequestBody("application/json; charset=utf-8".toMediaType())
    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .build()

    val response = client.newCall(request).execute()
    if (response.isSuccessful) {
        response.body?.string() ?: "No response body"
    } else {
        "Request failed with code: ${response.code}"
    }
}


class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "com.elaborium.kaouka/channel"
    private lateinit var methodChannel: MethodChannel
    private val id = "";

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize the method channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Set up a method call handler
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getId" -> {
                    result.success(id)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun myMethod(result: MethodChannel.Result) {
        // You can pass data or handle the response from Flutter
        result.success("Result from Kotlin")
    }

    private fun callFlutterMethod(statetype:String) {
        methodChannel.invokeMethod("getId", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                // Handle the result from Flutter
                val id = result as? String ?: ""
                Log.d(TAG,"ID received in Kotlin: $id")
                if(id != ""){
                    lifecycleScope.launch {
                        if(statetype == "disconnexion"){
                            onDisconnection(applicationContext, id)
                        }
                        else if(statetype == "connexion"){
                            onConnection(applicationContext, id)
                        }
                    }
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                // Handle errors
                Log.d(TAG,"Error: $errorMessage")
            }

            override fun notImplemented() {
                // Handle method not implemented
                Log.d(TAG,"Method not implemented")
            }
        })
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configureFlutterEngine(flutterEngine!!)
        Log.d(TAG, "onCreate: Activity Create")
    }

    override fun onStart() {
        super.onStart()
        Log.d(TAG, "onStart: Activity Start")
        lifecycleScope.launch {
            callFlutterMethod("connexion")
        }
    }

    override fun onStop() {
        super.onStop()
        Log.d(TAG, "onStop: Activity Stop")
        lifecycleScope.launch {
            callFlutterMethod("disconnexion")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        lifecycleScope.launch {
            callFlutterMethod("disconnexion")
        }
        Log.d(TAG, "onDestroy: Activity Destroyed")
    }
}
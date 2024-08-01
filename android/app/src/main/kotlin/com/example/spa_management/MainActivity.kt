package com.example.spa_management

import android.os.Bundle
import com.google.firebase.messaging.FirebaseMessaging
import sun.rmi.runtime.Log


class MainActivity : FlutterActivity() {
    protected fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get the FCM token and print it in the logs
        FirebaseMessaging.getInstance().getToken()
            .addOnCompleteListener { task ->
                if (!task.isSuccessful()) {
                    Log.w(TAG, "Fetching FCM registration token failed", task.getException())
                    return@addOnCompleteListener
                }

                // Get new FCM registration token
                val token: String = task.getResult()

                // Log the token
                Log.d(TAG, "FCM registration token: $token")
            }
    }
}

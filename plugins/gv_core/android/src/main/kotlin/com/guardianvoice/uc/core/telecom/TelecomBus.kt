package com.guardianvoice.uc.core.telecom

import android.telecom.Connection
import java.util.concurrent.ConcurrentHashMap

object TelecomBus {
    private val calls = ConcurrentHashMap<String, Connection>()
    fun put(id: String, c: Connection) { calls[id]=c }
    fun remove(id: String) { calls.remove(id) }
    fun answer(id: String) { calls[id]?.onAnswer() }
    fun hangup(id: String) { calls[id]?.onDisconnect() }
}
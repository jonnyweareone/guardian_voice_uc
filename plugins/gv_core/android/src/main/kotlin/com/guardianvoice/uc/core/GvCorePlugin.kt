package com.guardianvoice.uc.core

import android.content.Context
import android.content.ComponentName
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.guardianvoice.uc.core.lin.Engine
import com.guardianvoice.uc.core.telecom.TelecomBus

class GvCorePlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var ctx: Context
    private lateinit var m: MethodChannel
    private lateinit var callsEvt: EventChannel
    private var callsSink: EventChannel.EventSink? = null

    companion object {
        var methodChannel: MethodChannel? = null
        fun emitIncomingToDart(callId: String, from: String, uri: String) {
            methodChannel?.invokeMethod("nativeIncoming", mapOf("callId" to callId, "fromDisplay" to from, "fromUri" to uri))
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ctx = binding.applicationContext
        m = MethodChannel(binding.binaryMessenger, "gv/core/methods")
        callsEvt = EventChannel(binding.binaryMessenger, "gv/core/calls")
        m.setMethodCallHandler(this)
        methodChannel = m
        callsEvt.setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) { callsSink = sink }
            override fun onCancel(args: Any?) { callsSink = null }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) { methodChannel = null }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> { Engine.init(ctx); registerPhoneAccount(); result.success(null) }
            "registerPushToken" -> { /* POST token to backend */ result.success(null) }
            "setAccount" -> {
                val a = call.arguments as Map<*,*>
                Engine.setAccount(
                    a["username"] as String, a["domain"] as String, a["password"] as String,
                    (a["tls"] as? Boolean) ?: true, (a["port"] as? Int) ?: 6061,
                    (a["srtp"] as? Boolean) ?: true, a["stun"] as? String, a["turn"] as? String
                )
                result.success(null)
            }
            "placeCall" -> { Engine.call(call.argument<String>("uri")!!); result.success(null) }
            "answer" -> { Engine.answer(); result.success(null) }
            "hangup" -> { Engine.hangup(); result.success(null) }
            "hold" -> { Engine.hold(call.argument<Boolean>("on")==true); result.success(null) }
            "mute" -> { Engine.mute(call.argument<Boolean>("on")==true); result.success(null) }
            "nativeIncoming" -> { callsSink?.success(call.arguments); result.success(null) }
            else -> result.notImplemented()
        }
    }

    private fun registerPhoneAccount() {
        val tm = ctx.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        val handle = PhoneAccountHandle(
            ComponentName(ctx, "com.guardianvoice.uc.core.telecom.GvConnectionService"),
            "GuardianVoiceUC"
        )
        val pa = PhoneAccount.builder(handle, "Guardian Voice UC")
            .setCapabilities(PhoneAccount.CAPABILITY_CALL_PROVIDER or PhoneAccount.CAPABILITY_CONNECTION_MANAGER)
            .build()
        tm.registerPhoneAccount(pa)
    }
}
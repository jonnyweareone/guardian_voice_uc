package com.guardianvoice.uc.core.lin

import android.content.Context
import org.linphone.core.*

object Engine {
    lateinit var core: Core
    private var listener: CoreListenerStub? = null
    @Volatile private var running = false

    fun init(ctx: Context) {
        if (this::core.isInitialized) return
        val f = Factory.instance()
        core = f.createCore(null, null, ctx)
        listener = object: CoreListenerStub() {
            override fun onRegistrationStateChanged(c: Core, cfg: ProxyConfig, s: RegistrationState, msg: String) {}
            override fun onCallStateChanged(c: Core, call: Call, state: Call.State?, message: String?) {}
        }
        core.addListener(listener)
        core.enableEchoCancellation(true)
        running = true
        Thread { while(running) { core.iterate(); Thread.sleep(20) } }.start()
    }

    fun setAccount(u:String, d:String, pw:String, tls:Boolean, port:Int, srtp:Boolean, stun:String?, turn:String?) {
        val f = Factory.instance()
        val id = "sip:$u@$d"
        val addr = f.createAddress(id)
        val params = core.createAccountParams()
        params.identityAddress = addr
        params.serverAddress = f.createAddress((if (tls) "sips:" else "sip:") + "$d:$port")
        params.isRegisterEnabled = true
        params.transport = if (tls) TransportType.Tls else TransportType.Tcp
        core.mediaEncryption = if (srtp) MediaEncryption.SRtp else MediaEncryption.None
        val auth = f.createAuthInfo(u, null, pw, null, null, d)
        core.addAuthInfo(auth)
        stun?.let { core.stunServer = it }
        core.defaultAccount?.let { core.removeAccount(it) }
        val acc = core.createAccount(params)
        core.addAccount(acc)
        core.defaultAccount = acc
    }

    fun call(uri:String) { core.invite(uri) }
    fun answer() { core.currentCall?.accept() }
    fun hangup() { core.currentCall?.terminate() }
    fun hold(on:Boolean) { core.currentCall?.let { if (on) it.pause() else it.resume() } }
    fun mute(on:Boolean) { core.isMicEnabled = !on }
    fun dtmf(digits:String) { digits.forEach { core.currentCall?.sendDtmf(it) } }
}
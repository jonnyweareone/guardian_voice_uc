import Foundation
import linphonesw

class LinEngine {
    static let shared = LinEngine()
    var core: Core?
    
    func initCore() {
        if core != nil { return }
        do {
            core = try Factory.Instance.createCore(configPath: nil, factoryConfigPath: nil, systemContext: nil)
            try core?.start()
            core?.enableEchoCancellation = true
        } catch { print("Lin init error: \(error)") }
    }
    
    func setAccount(username: String, domain: String, password: String, tls: Bool, port: Int32, srtp: Bool, stun: String?) {
        guard let core = core else { return }
        do {
            let id = try Factory.Instance.createAddress(addr: "sip:\(username)@\(domain)")
            let params = try core.createAccountParams()
            try params.setIdentityAddress(newValue: id)
            let server = try Factory.Instance.createAddress(addr: "\(tls ? "sips" : "sip"):\(domain):\(port)")
            try params.setServerAddress(newValue: server)
            try params.setRegisterEnabled(newValue: true)
            try params.setTransport(transport: tls ? .Tls : .Tcp)
            core.mediaEncryption = srtp ? .SRTP : .None
            let auth = try Factory.Instance.createAuthInfo(username: username, userid: nil, passwd: password, ha1: nil, realm: nil, domain: domain)
            core.addAuthInfo(info: auth)
            if let stun = stun { core.stunServer = stun }
            if let cur = core.defaultAccount { core.removeAccount(account: cur) }
            let acc = try core.createAccount(params: params)
            try core.addAccount(account: acc)
            core.defaultAccount = acc
        } catch { print("setAccount error: \(error)") }
    }
    
    func call(uri: String) { 
        do { 
            let a = try Factory.Instance.createAddress(addr: uri)
            _ = core?.inviteAddress(addr: a) 
        } catch { print(error) } 
    }
    func answer() { core?.currentCall?.accept() }
    func hangup() { core?.currentCall?.terminate() }
    func hold(_ on: Bool) { if on { core?.currentCall?.pause() } else { core?.currentCall?.resume() } }
    func mute(_ on: Bool) { core?.micEnabled = !on }
    func dtmf(_ digits: String) { digits.forEach{ core?.currentCall?.sendDtmf(dtmf: $0) } }
}
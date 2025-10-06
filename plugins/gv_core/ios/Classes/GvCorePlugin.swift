import Flutter
import UIKit
import PushKit
import CallKit

public class GvCorePlugin: NSObject, FlutterPlugin, PKPushRegistryDelegate, CXProviderDelegate, FlutterStreamHandler {
    var method: FlutterMethodChannel!
    var calls: FlutterEventChannel!
    var callsSink: FlutterEventSink?
    
    let provider: CXProvider = {
        let cfg = CXProviderConfiguration(localizedName: "Guardian Voice UC")
        cfg.includesCallsInRecents = true
        cfg.supportsVideo = true
        return CXProvider(configuration: cfg)
    }()
    let callController = CXCallController()
    
    override init() { 
        super.init()
        provider.setDelegate(self, queue: nil) 
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let i = GvCorePlugin()
        i.method = FlutterMethodChannel(name: "gv/core/methods", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(i, channel: i.method)
        i.calls = FlutterEventChannel(name: "gv/core/calls", binaryMessenger: registrar.messenger())
        i.calls.setStreamHandler(i)
        
        let pk = PKPushRegistry(queue: DispatchQueue.main)
        pk.desiredPushTypes = [.voIP]
        pk.delegate = i
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        callsSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        callsSink = nil
        return nil
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize": 
            LinEngine.shared.initCore()
            result(nil)
        case "registerPushToken": 
            result(nil)
        case "setAccount":
            if let a = call.arguments as? [String:Any] {
                LinEngine.shared.setAccount(
                    username: a["username"] as! String,
                    domain: a["domain"] as! String,
                    password: a["password"] as! String,
                    tls: (a["tls"] as? Bool) ?? true,
                    port: Int32((a["port"] as? Int) ?? 6061),
                    srtp: (a["srtp"] as? Bool) ?? true,
                    stun: a["stun"] as? String
                )
            }
            result(nil)
        case "placeCall": 
            LinEngine.shared.call(uri: (call.arguments as! [String:Any])["uri"] as! String)
            result(nil)
        case "answer": 
            LinEngine.shared.answer()
            result(nil)
        case "hangup": 
            LinEngine.shared.hangup()
            result(nil)
        case "hold": 
            LinEngine.shared.hold(((call.arguments as! [String:Any])["on"] as? Bool) ?? false)
            result(nil)
        case "mute": 
            LinEngine.shared.mute(((call.arguments as! [String:Any])["on"] as? Bool) ?? false)
            result(nil)
        default: 
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        // TODO: send token to backend
    }
    
    public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        LinEngine.shared.initCore()
        LinEngine.shared.core?.refreshRegisters()
        let d = payload.dictionaryPayload
        let callId = (d["call_id"] as? String) ?? UUID().uuidString
        let fromDisp = (d["from_display"] as? String) ?? "Unknown"
        let fromUri = (d["from_uri"] as? String) ?? "sip:unknown@guardianvoice.com"
        presentIncoming(callId: callId, fromDisplay: fromDisp, fromUri: fromUri)
        callsSink?(["callId":callId, "fromDisplay":fromDisp, "fromUri":fromUri])
        completion()
    }
    
    private func presentIncoming(callId: String, fromDisplay: String, fromUri: String) {
        let uuid = UUID(uuidString: callId) ?? UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: fromDisplay)
        provider.reportNewIncomingCall(with: uuid, update: update) { err in 
            if let e = err { print("CallKit error: \(e)") }
        }
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        GvAudio.startCall()
        LinEngine.shared.answer()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        LinEngine.shared.hangup()
        GvAudio.endCall()
        action.fulfill()
    }
    
    public func providerDidReset(_ provider: CXProvider) {}
}
import Capacitor
import LocalAuthentication

/// Desbloqueo con biometría (Face ID / Touch ID) o, si el dispositivo no
/// tiene biometría disponible, con el código del dispositivo.
/// Requiere NSFaceIDUsageDescription en Info.plist; sin esa clave la app
/// se cierra al evaluar la política biométrica.
@objc(Biometrics)
public class Biometrics: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "Biometrics"
    public let jsName = "Biometrics"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "authenticate", returnType: CAPPluginReturnPromise)
    ]

    @objc public func authenticate(_ call: CAPPluginCall) {
        let reason = call.getString("reason") ?? "Desbloquea Calcula"
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"
        var error: NSError?
        let policy: LAPolicy
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            policy = .deviceOwnerAuthenticationWithBiometrics
        } else {
            // Sin biometría (no configurada o no disponible): código del dispositivo.
            policy = .deviceOwnerAuthentication
        }
        context.evaluatePolicy(policy, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                call.resolve(["success": success])
            }
        }
    }
}

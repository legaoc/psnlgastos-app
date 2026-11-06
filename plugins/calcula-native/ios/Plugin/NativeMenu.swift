import Capacitor

/// Menú nativo de Apple (UIMenu) presentado en el punto donde el usuario
/// mantuvo presionada una tarjeta. En iOS 26 el menú se dibuja con el
/// material Liquid Glass del sistema; en iOS 14-25 usa el estilo de menú
/// nativo de cada versión. No requiere @available: UIMenu, UIAction y
/// UIButton.menu existen desde iOS 13/14 y el deployment target es 14.0.
///
/// La presentación es programática: se crea un UIButton transparente de 1x1
/// en el punto (x, y) dentro del WKWebView, se le asigna el UIMenu y se
/// dispara su acción primaria con sendActions(for: .touchUpInside).
/// Si el usuario descarta el menú sin elegir, no hay callback del sistema;
/// el lado JS corre una carrera con timeout y lo trata como cancelado.
@objc(NativeMenu)
public class NativeMenu: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NativeMenu"
    public let jsName = "NativeMenu"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "showMenu", returnType: CAPPluginReturnPromise)
    ]

    /// Botón invisible que sostiene el menú presentado. Se guarda para
    /// poder retirarlo cuando se elige una acción o llega un nuevo menú.
    private var menuButton: UIButton?

    @objc public func showMenu(_ call: CAPPluginCall) {
        let title = call.getString("title") ?? ""
        let x = call.getDouble("x") ?? 0
        let y = call.getDouble("y") ?? 0
        guard let items = call.getArray("items", JSObject.self), !items.isEmpty else {
            call.reject("showMenu necesita al menos un item")
            return
        }
        DispatchQueue.main.async {
            self.presentMenu(call: call, title: title, x: x, y: y, items: items)
        }
    }

    private func presentMenu(call: CAPPluginCall, title: String, x: Double, y: Double, items: [JSObject]) {
        guard let webView = self.bridge?.webView else {
            call.reject("No hay webView")
            return
        }

        // Retira un botón de un menú anterior que haya quedado colgado
        // (por ejemplo, si el usuario descartó el menú sin elegir).
        menuButton?.removeFromSuperview()
        menuButton = nil

        var resolved = false
        func finish(_ selectedId: String?) {
            guard !resolved else { return }
            resolved = true
            self.menuButton?.removeFromSuperview()
            self.menuButton = nil
            if let selectedId = selectedId {
                call.resolve(["selectedId": selectedId])
            } else {
                call.resolve(["selectedId": NSNull()])
            }
        }

        let actions: [UIAction] = items.compactMap { item in
            guard let id = item["id"] as? String,
                  let itemTitle = item["title"] as? String else { return nil }
            var attributes: UIAction.Attributes = []
            if (item["destructive"] as? Bool) == true {
                attributes.insert(.destructive)
            }
            var image: UIImage?
            if let icon = item["icon"] as? String, !icon.isEmpty {
                image = UIImage(systemName: icon)
            }
            return UIAction(title: itemTitle, image: image, attributes: attributes) { _ in
                finish(id)
            }
        }

        guard !actions.isEmpty else {
            call.reject("showMenu necesita al menos un item válido")
            return
        }

        let menu = UIMenu(title: title, children: actions)
        let button = UIButton(type: .system)
        // 1x1 en el punto del toque, dentro del WKWebView. Las coordenadas
        // llegan en puntos CSS y la página no permite zoom (viewport con
        // maximum-scale=1, user-scalable=no), así que coinciden con los
        // puntos de la vista.
        button.frame = CGRect(x: x, y: y, width: 1, height: 1)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        webView.addSubview(button)
        self.menuButton = button

        // Presentar en el siguiente ciclo, cuando el botón ya está en la
        // jerarquía de vistas.
        DispatchQueue.main.async {
            button.sendActions(for: .touchUpInside)
        }
    }
}

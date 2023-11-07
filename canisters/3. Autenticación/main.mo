import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

actor CanisterAutenticacion {

    type Usuario = {
        principal: Principal;   // La identidad del usuario
        nombre: Text;            // Nombre de usuario para display
        contrasenaHash: Text;    // Hash de la contraseña (NUNCA almacenar contraseñas en texto claro)
    };

    let usuariosDb = HashMap.HashMap<Principal, Usuario>(0, Principal.equal, Principal.hash);

    // Registrar un nuevo usuario
    public func registrarUsuario(nombre: Text, contrasenaHash: Text) : async Bool {
        let usuarioActual = usuariosDb.get(msg.caller);
        switch (usuarioActual) {
            case (null) {
                let nuevoUsuario = {principal=msg.caller; nombre=nombre; contrasenaHash=contrasenaHash};
                usuariosDb.put(msg.caller, nuevoUsuario);
                Debug.print("Usuario registrado: " # nombre);
                return true;
            };
            case (_) {
                Debug.print("El usuario ya existe");
                return false;
            };
        };
    };

    // Autenticar un usuario
    public func autenticarUsuario(contrasenaHash: Text) : async ?Usuario {
        let usuario = usuariosDb.get(msg.caller);
        switch (usuario) {
            case (null) {
                Debug.print("Usuario no encontrado");
                return null;
            };
            case (?u) if (u.contrasenaHash == contrasenaHash) {
                Debug.print("Autenticación exitosa");
                return u;
            };
            case (_) {
                Debug.print("Contraseña incorrecta");
                return null;
            };
        };
    };

    // Autorizar un usuario para ciertas acciones (ejemplo sencillo)
    public func autorizarUsuario() : async Bool {
        // Supongamos que sólo los usuarios registrados están autorizados
        let usuario = usuariosDb.get(msg.caller);
        switch (usuario) {
            case (null) {
                Debug.print("Usuario no autorizado");
                return false;
            };
            case (_) {
                Debug.print("Usuario autorizado");
                return true;
            };
        };
    };
}

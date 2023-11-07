import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

actor CanisterRecompensas {

    type Recompensa = {
        projectId: Text; // ID del proyecto asociado a esta recompensa
        cantidad: Nat;   // Cantidad de criptomoneda a distribuir
    };

    let recompensasDb = HashMap.HashMap<Principal, Recompensa>(0, Principal.equal, Principal.hash);

    // Crear una recompensa para un proyecto
    public func asignarRecompensa(projectId: Text, cantidad: Nat) : async Bool {
        // Suponemos que solo administradores pueden asignar recompensas (esto es solo un ejemplo)
        if (msg.caller != someAdminPrincipal) { // Aquí, `someAdminPrincipal` es la identidad del administrador.
            Debug.print("No autorizado para asignar recompensas");
            return false;
        }
        
        let recompensa = {projectId=projectId; cantidad=cantidad};
        recompensasDb.put(msg.caller, recompensa); // Aquí asumimos que un principal puede tener solo una recompensa a la vez.
        Debug.print("Recompensa asignada al proyecto: " # projectId);
        return true;
    };

    // Recoger la recompensa (por el propietario del proyecto)
    public func recogerRecompensa(projectId: Text) : async ?Recompensa {
        // Aquí debes integrar con el canister de proyectos para verificar si el llamador (msg.caller) es realmente el propietario del proyecto.
        // Si lo es, puedes continuar con la recogida de recompensa.
        
        let recompensa = recompensasDb.get(msg.caller);
        switch (recompensa) {
            case (null) {
                Debug.print("No hay recompensa para recoger");
                return null;
            };
            case (?r) if (r.projectId == projectId) {
                ignore recompensasDb.remove(msg.caller); // Eliminar la recompensa una vez recogida
                Debug.print("Recompensa recogida para el proyecto: " # projectId);
                return r;
            };
            case (_) {
                Debug.print("Recompensa no coincide con el proyecto");
                return null;
            };
        };
    };

    // Consultar recompensas pendientes para un usuario (principal)
    public query func verRecompensa() : async ?Recompensa {
        let recompensa = recompensasDb.get(msg.caller);
        return recompensa;
    };

    // Aquí puedes agregar más funciones como transferir recompensas, ver todas las recompensas, etc.

}

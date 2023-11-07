import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

actor ProyectoCanister {
    type ProyectoId = Nat32;
    
    type EstadoProyecto = {
        #Borrador;
        #Publicado;
    };

    type Proyecto = {
        estudiante: Principal;
        descripcion: Text;
        proyectodb: Text;
        estado: EstadoProyecto;
    };

    // Base de datos de proyectos
    var proyectoDb : HashMap.HashMap<ProyectoId, Proyecto> = 
        HashMap.HashMap<ProyectoId, Proyecto>(Nat32.equal, Nat32.hash);

    // ID de proyecto inicial
    stable var nextProyectoId : ProyectoId = 0;

    // Función auxiliar para generar un nuevo ID de proyecto
    private func generateProyectoId() : ProyectoId {
        let id = nextProyectoId;
        nextProyectoId := Nat32.add(nextProyectoId, 1);
        return id;
    };

    // Función auxiliar para generar el valor de proyectodb
    private func generateProyectodb(id: ProyectoId) : Text {
        return "https://alegrastudio.com/proyecto/" # Nat32.toText(id);
    };

     // Inscribir (crear) un proyecto
    public func inscribirProyecto(descripcion: Text) : async ProyectoId {
        let id = generateProyectoId();
        let proyectodb = generateProyectodb(id);
        let proyecto = {
            estudiante = Principal.fromActor(msg.caller);  // Usa : para asignar valores en un registro
            descripcion = descripcion;
            proyectodb = proyectodb;
            estado = #Borrador;
        };
        proyectoDb.put(id, proyecto);
        Debug.print("Nuevo proyecto inscrito con ID: " # Nat32.toText(id));
        return id;
    };

    // Actualizar la descripción de un proyecto existente
    public func actualizarProyecto(id: ProyectoId, nuevaDescripcion: Text) : async Bool {
        switch (proyectoDb.get(id)) {
            case (null) {
                Debug.print("Proyecto no encontrado.");
                return false;
            };
            case (?proyecto) {
                if (proyecto.estudiante != Principal.fromActor(msg.caller)) {
                    Debug.print("Solo el creador del proyecto puede actualizarlo.");
                    return false;
                };
                let nuevoProyecto = {
                    estudiante = proyecto.estudiante;
                    descripcion = nuevaDescripcion;
                    proyectodb = proyecto.proyectodb;
                    estado = proyecto.estado;
                };
                proyectoDb.put(id, nuevoProyecto);
                Debug.print("Proyecto actualizado.");
                return true;
            };
        };
    };

    // Publicar un proyecto (cambiar su estado a público)
    public func publicarProyecto(id: ProyectoId) : async Bool {
        switch (proyectoDb.get(id)) {
            case (null) {
                Debug.print("Proyecto no encontrado.");
                return false;
            };
            case (?proyecto) {
                if (proyecto.estudiante != Principal.fromActor(msg.caller)) {
                    Debug.print("Solo el creador del proyecto puede publicarlo.");
                    return false;
                };
                let nuevoProyecto = {
                    estudiante = proyecto.estudiante;
                    descripcion = proyecto.descripcion;
                    proyectodb = proyecto.proyectodb;
                    estado = #Publicado;
                };
                proyectoDb.put(id, nuevoProyecto);
                Debug.print("Proyecto publicado.");
                return true;
            };
        };
    };

    // Obtener la lista de todos los proyectos
    public query func obtenerProyectos() : async [(ProyectoId, Proyecto)] {
        return HashMap.toArray(proyectoDb);
    };

    // Obtener proyectos específicos del estudiante que llama la función
    public query func obtenerMisProyectos() : async [(ProyectoId, Proyecto)] {
        let caller = Principal.fromActor(msg.caller);
        let misProyectos = HashMap.toArray(proyectoDb).filter(func ((_, proyecto)) -> Bool {
            return proyecto.estudiante == caller;
        });
        return misProyectos;
    };
}
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

actor ProyectoVotacionComentario {

    // Define el tipo de proyecto.
    type ProyectoId = Nat32;
    type Proyecto = {
        estudiante: Principal;
        descripcion: Text;
        votos: Nat32;
        comentarios: [Comentario];
    };
    
    type Comentario = {
        autor: Principal;
        mensaje: Text;
    };

    // ID de proyecto inicial y base de datos de proyectos.
    stable var proyectoId: ProyectoId = 0;
    let proyectoDb = HashMap.HashMap<Text, Proyecto>(0, Text.equal, Text.hash);

    // Generar un nuevo ID de proyecto.
    private func generateProyectoId() : Nat32 {
        proyectoId += 1;
        return proyectoId;
    };

    // Inscribir (crear) un nuevo proyecto.
    public shared (msg) func inscribirProyecto(descripcion: Text) : async () {
        let estudiante: Principal = msg.caller;
        let proyecto = {creator=estudiante; descripcion=descripcion; votos=0; comentarios=[]};
        proyectoDb.put(Nat32.toText(generateProyectoId()), proyecto);
        Debug.print("Nuevo proyecto inscrito! ID: " # Nat32.toText(proyectoId));
        return ();
    };

    // Votar por un proyecto.
    public func votarProyecto(id: Text) : async Bool {
        let proyecto: ?Proyecto = proyectoDb.get(id);

        switch (proyecto) {
            case (null) {
                return false;
            };
            case (?proyectoActual) {
                proyectoActual.votos += 1;
                proyectoDb.put(id, proyectoActual);
                Debug.print("Voto agregado al proyecto con ID: " # id);
                return true;
            };
        };
    };
//hashmap o varias sitemas de almacenamento ....   para evitar que los estudiantes puedan volver a votar. declarar esos elementos y asociar, lista nominal.  se marca, 
// si existe niegale el voto, y depende de como se maneje. lista nominal, se sepan los votos. si a lo mejor hay un si o no abstinencia.  enfocarnos en la parte 
// d eno realizar el tipo de fraude... asociar por discord... profundizar en documentación compartida por el profe sobre arbol rojo negro. 

    // Agregar un comentario a un proyecto.
    public shared (msg) func comentarProyecto(id: Text, mensaje: Text) : async Bool {
        let autor: Principal = msg.caller;
        let comentario = {autor=autor; mensaje=mensaje};
        let proyecto: ?Proyecto = proyectoDb.get(id);

        switch (proyecto) {
            case (null) {
                return false;
            };
            case (?proyectoActual) {
                proyectoActual.comentarios := comentario :: proyectoActual.comentarios;
                proyectoDb.put(id, proyectoActual);
                Debug.print("Comentario agregado al proyecto con ID: " # id);
                return true;
            };
        };
    };

    // Obtener todos los proyectos.
    public query func obtenerProyectos() : async [(Text, Proyecto)] {
        let proyectoIter = proyectoDb.entries();
        let proyectoArray = Iter.toArray(proyectoIter);
        return proyectoArray;
    };

    // Obtener un proyecto específico.
    public query func obtenerProyecto(id: Text) : async ?Proyecto {
        let proyecto: ?Proyecto = proyectoDb.get(id);
        return proyecto;
    };
}

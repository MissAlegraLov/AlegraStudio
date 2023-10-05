import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";

actor AlegraStudio {

    type StudentMetadata = {
        name: Text;
        university: Text;
        projectTitle: Text;
        skillsAcquired: [Text];
        cryptoReward: Nat;
        badge: Text;
    };

    // DAO de Alegra Studio para votación de validación de proyectos
    type Vote = {
        studentId: Text;
        votes: Nat;
    };

    // Map to store student data
    let studentDB = Map.HashMap<Text, StudentMetadata>(0, Text.equal, Text.hash);

    // Map to store project validation votes
    let votesDB = Map.HashMap<Text, Vote>(0, Text.equal, Text.hash);

    public func registerStudent(id: Text, data: StudentMetadata) : async() {
        studentDB.put(id, data);
        Debug.print("Student registered!");
    };

    public func validateProject(studentId: Text) : async(Bool) {
        let studentData = studentDB.get(studentId);
        switch (studentData) {
            case (null) { Debug.trap("Student not found!"); };
            case (?data) {
                let currentVotes = switch (votesDB.get(studentId)) {
                    case (null) { 0 };
                    case (?votes) { votes.votes };
                };
                let updatedVotes = currentVotes + 1;
                
                // Assuming a threshold of 5 votes to validate a project and award a badge
                if (updatedVotes >= 5) {
                    data.badge := "AlegraStudio Validated";
                    studentDB.put(studentId, data);
                    votesDB.remove(studentId); // Reset votes after validation
                    Debug.print("Project validated and badge awarded!");
                } else {
                    votesDB.put(studentId, {studentId = studentId; votes = updatedVotes});
                    Debug.print("Vote recorded!");
                };
                return true;
            };
        };
    };

    public query func viewStudentData(studentId: Text) : async ?StudentMetadata {
        return studentDB.get(studentId);
    };

    public func updateStudentData(studentId: Text, newData: StudentMetadata) : async(Bool) {
        if (studentDB.replace(studentId, newData) == null) {
            Debug.trap("Student not found!");
            return false;
        };
        Debug.print("Student data updated!");
        return true;
    };

    public func deleteStudent(studentId: Text) : async() {
        studentDB.remove(studentId);
        Debug.print("Student removed!");
    };
};



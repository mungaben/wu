import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
actor class Register(name : Text, id : Principal) = this {

    private var voterName = name;
    private var voterId = id;


    // HashMap to store registered vote
    public query func getvoterId() : async Principal {
        return voterId;
    };

    public query func getvoterName() : async Text {
        return voterName;
    };

    public shared (msg) func userIsVoting() {

    };

    //check if the user is registered to be allowed to vote
    public shared (msg) func userIsRegistered() : async Bool {
        if (msg.caller == voterId) {
            return true; // User is registered and can cast a vote
        } else {
            return false; // User is not registered, cannot cast a vote
        };
    };

};

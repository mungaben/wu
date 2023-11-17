import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";

actor class TeamsParty(name : Text, votes : Nat) = this {
    private let partyName = name;
    // private let identity = partId;
    private var totalPartyVotes = votes;

    public query func getpartyName() : async Text {
        return partyName;
    };
    var delegatesList : [Principal] = [];

    // public func registerDelegate(delegateIdentity : Principal) : async () {
    //     delegatesList := Array.append(delegatesList, [delegateIdentity]);
    // };

    // public query func getIdentity() : async Principal {
    //     return partId;
    // };

    public func incrementVote() : async Nat {
        totalPartyVotes += 1; // Increment receivedVotes by 1 when receiVote is called
        return totalPartyVotes;
    };

};

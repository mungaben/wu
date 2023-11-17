import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Text "mo:base/Text";
import RegisterClass "Voter/Register";
import DeligateFromTeamClass "Team/Delegate";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import IterType "mo:base/IterType";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Int "mo:base/Int";
import TeamParytyClass "Team/TeamParty";

actor {

  var mapOfRegisteredVoters = HashMap.HashMap<Principal, RegisterClass.Register>(1, Principal.equal, Principal.hash);
  var mapOfDelegates = HashMap.HashMap<Principal, DeligateFromTeamClass.Delecate>(1, Principal.equal, Principal.hash);
  var mapOfTeamParty = HashMap.HashMap<Text, TeamParytyClass.TeamsParty>(1, Text.equal, Text.hash);
  var mapOfVotedVoters = HashMap.HashMap<Principal, Bool>(1, Principal.equal, Principal.hash);

  let mapOfPartyListing = HashMap.HashMap<Text, List.List<Principal>>(0, Text.equal, Text.hash); //a party and its delegates

  let recivedCycles = 100_500_000_000;

  /// Register Teams to be voted to
  public shared (msg) func createTeamDelegate(teamName : Text, post : Text, deligateName : Text, imgData : [Nat8]) : async Principal {
    // let delegatId : Principal = msg.caller; // The caller is the delegatId
    let recivedCycles = 100_500_000_000;
    Cycles.add(recivedCycles);

    switch (mapOfTeamParty.get(teamName)) {
      case (?existingParty) {
        Cycles.add(recivedCycles);
        // If the party already exists, update the delegate
        let newDelegate = await DeligateFromTeamClass.Delecate(teamName, post, deligateName, imgData);
        let newDelegatePrincipal = await newDelegate.getCanisterId();
        // Map the delegate to the existing party
        mapOfDelegates.put(newDelegatePrincipal, newDelegate);
        // Debug.print(debug_show (newDelegatePrincipal));
        // Add the delegate to the existing party's list
        await addToPartyMap(teamName, newDelegatePrincipal);

        return newDelegatePrincipal;
      };
      case null {
        // If the party does not exist, create and register the party
        Cycles.add(recivedCycles);
        let newTeamParty = await TeamParytyClass.TeamsParty(teamName, 0); // Assuming initial votes are 0
        let newTeamName = await newTeamParty.getpartyName();
        mapOfTeamParty.put(teamName, newTeamParty);

        // Create and register the delegate
        Cycles.add(recivedCycles);
        let newDelegate = await DeligateFromTeamClass.Delecate(teamName, post, deligateName, imgData);
        let newDelegatePrincipal = await newDelegate.getCanisterId();

        // Map the delegate to the new party
        mapOfDelegates.put(newDelegatePrincipal, newDelegate);

        // Add the delegate to the new party's list
        await addToPartyMap(teamName, newDelegatePrincipal);

        return newDelegatePrincipal;

      };
    };
  };

  private func addToPartyMap(teamName : Text, delegateId : Principal) : async () {
    // delegateId is a newly registered Delegate to be added

    // Get the current list of delegate IDs for the given teamName
    var delegateIds : List.List<Principal> = switch (mapOfPartyListing.get(teamName)) {
      case null { List.nil<Principal>() };
      case (?result) { result };
    };
    // Add the new delegate ID to the list
    delegateIds := List.push(delegateId, delegateIds);
    // Update the map with the new list of delegate IDs
    mapOfPartyListing.put(teamName, delegateIds);
  };

  // private func addToDelegatePartyMap(delegatId : Principal, teamParty : Text) {
  //     switch (mapOfTeamParty.get(delegatId)) {
  //         case null {
  //             mapOfTeamParty.put(delegatId, teamParty);
  //         };
  //         case (?result) {
  //             let resultType = result;
  //             mapOfTeamParty.put(delegatId, teamParty);
  //         };
  //     };
  // };

  public shared (msg) func register(name : Text) : async Principal {
    let voterId : Principal = msg.caller;
    Debug.print(debug_show (Cycles.balance()));
    Cycles.add(recivedCycles);
    let newVoter = await RegisterClass.Register(name, voterId);

    let newRegVoterPrincipal = await newVoter.getvoterId();

    mapOfRegisteredVoters.put(newRegVoterPrincipal, newVoter);
    return newRegVoterPrincipal;
  };

  public query func getTeamPartyByName(teamName : Text) : async ?TeamParytyClass.TeamsParty {
    return mapOfTeamParty.get(teamName);
  };

  public shared func voteForTeamParty(partyIdentity : Text) : async Nat {
    switch (mapOfTeamParty.get(partyIdentity)) {
      case (?teamParty) {
        let newVote = await teamParty.incrementVote();
        return newVote;
      };
      case null {
        return 0; // Team not found, unable to increment vote.
      };
    };
  };

  // Function to check if a voter can vote
  public func canVote(voterId : Principal) : async Bool {
    switch (mapOfRegisteredVoters.get(voterId)) {
      case (?registered) {
        switch (mapOfVotedVoters.get(voterId)) {
          case (?voted) {
            return false; // Voter has already voted
          };
          case null {
            // Voter is registered but hasn't voted yet
            return true;
          };
        };
      };
      case null {
        return false; // Voter is not registered
      };
    };
  };

  // Function to mark a voter as voted
  public func markAsVoted(voterId : Principal) : async () {
    // Mark the voter as voted in the mapOfVotedVoters
    mapOfVotedVoters.put(voterId, true);
  };

  public query func getListedDelegates() : async [Principal] {
    let ids = Iter.toArray(mapOfDelegates.keys());
  };

  // public query func getIdentity() : async Principal {
  //   return Principal.fromActor(ElecureV);
  // };

  //get party delegates
  public query func getPartyDelegates(partyName : Text) : async [Principal] {
    var partyDelegates : List.List<Principal> = switch (mapOfPartyListing.get(partyName)) {
      case null List.nil<Principal>();
      case (?result) result;
    };

    return List.toArray(partyDelegates);
  };

  public query func getAllParties() : async [Text] {
    let parties = Iter.toArray(mapOfPartyListing.keys());
    return parties;
    // debug_show("Parties: ", parties);
  };

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };


};

// actor {
//   public query func greet(name : Text) : async Text {
//     return "Hello, " # name # "!";
//   };
// };
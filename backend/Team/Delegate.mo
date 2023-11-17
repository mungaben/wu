import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";

actor class Delecate(teamName : Text, delegateName : Text, post : Text, holderImage : [Nat8]) = this {
    private let teamNaming = teamName;
    private let deliGName = delegateName;
    private let roleHolder = post;
    private let roleAsset = holderImage;

    public query func getTeamNaming() : async Text {
        return teamNaming;
    };
    public query func getPostHolder() : async Text {
        return roleHolder;
    };
    public query func getImageAsset() : async [Nat8] {
        return roleAsset;
    };

    public query func getDelegateName() : async Text {
        return deliGName;
    };
    public query func getCanisterId() : async Principal {
        return Principal.fromActor(this);
    };
};

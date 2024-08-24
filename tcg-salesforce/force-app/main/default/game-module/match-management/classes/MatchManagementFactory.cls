public with sharing class MatchManagementFactory {
    public Match__c generateMatchRecord(Contact player) {
        Match__c match = new Match__c();
        match.PlayerOne__c = player.Id;
        
        return match;
    }
}
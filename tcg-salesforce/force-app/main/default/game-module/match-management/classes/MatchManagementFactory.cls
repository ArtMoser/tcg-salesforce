public with sharing class MatchManagementFactory {
    public Match__c generateMatchRecord(Contact player) {
        Match__c match = new Match__c();
        match.PlayerOne__c = player.Id;
        
        return match;
    }

    public Match__c updateMatchEvent(Contact player, String matchId, String event) {
        return new Match__c(
            Id = matchId,
            LastPlayerAction__c = player.Id,            
            Event__c = event
        );
    }

    public class MatchData {
        @AuraEnabled
        public Contact player { get;set; }
        @AuraEnabled
        public Match__c match { get;set; }
        @AuraEnabled
        public List<DeckCard__c> deckCards { get;set; }
        @AuraEnabled
        public List<PlayerHand__c> playersHands { get;set; }
        @AuraEnabled
        public List<RowCard__c> rowCards { get;set; }
        @AuraEnabled
        public List<MatchCemetery__c> matchCemitery { get;set; }
    }
}
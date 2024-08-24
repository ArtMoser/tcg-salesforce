public with sharing class MatchManagement {
    MatchManagementFactory factory = new MatchManagementFactory();


    public Match__c createMatch(Contact player) {
        Match__c match = this.factory.generateMatchRecord(player);
        insert match;

        return match;
    }

    public Match__c updateFoundMatch(Match__c match, Contact player) {
        match.PlayerTwo__c = player.Id;
        update match;

        return match;
    }

    public void updateMatch(Match__c match) {
        match.UpdateMatch__c += 1;
        update match;
    }
}
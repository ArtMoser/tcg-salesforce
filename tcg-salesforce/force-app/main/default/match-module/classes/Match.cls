public with sharing class Match {
    MatchFactory factory = new MatchFactory();

    public List<MatchFactory.PlayerMatch> getPlayersPerMatch(List<Match__c> matches, Map<Id, Match__c> oldMatches) {
        return this.factory.generatePlayersPerMatch(matches, oldMatches);
    }

    public List<BattlefieldRow__c> generateBattlefieldRows(List<MatchFactory.PlayerMatch> playersPerMatch) {
        List<BattlefieldRow__c> battleFieldRowsGenerated = new List<BattlefieldRow__c>();

        for(MatchFactory.PlayerMatch playerPerMatch : playersPerMatch) {
            battleFieldRowsGenerated.addAll(this.factory.generateBattlefieldRows(playerPerMatch));
        }

        return battleFieldRowsGenerated;
    }

    public List<RowCard__c> generateRowCards(List<BattlefieldRow__c> battlefieldRows) {
        List<RowCard__c> rowsCardGenerated = new List<RowCard__c>();

        for(BattlefieldRow__c battlefieldRow : battlefieldRows) {
            rowsCardGenerated.addAll(this.factory.generateCardRows(battlefieldRow));
        }

        return rowsCardGenerated;
    }
}
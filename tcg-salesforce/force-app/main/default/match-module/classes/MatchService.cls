public with sharing class MatchService {
    Match match = new Match();
    Util util = new Util();

    public void generateMatchRows(List<Match__c> newMatches, Map<Id, Match__c> oldMatches) {

        List<MatchFactory.PlayerMatch> playersPerMatch = this.match.getPlayersPerMatch(newMatches, oldMatches);
        List<BattlefieldRow__c> battlefieldRows = this.match.generateBattlefieldRows(playersPerMatch);
        insert battlefieldRows;

        List<RowCard__c> rowCards = this.match.generateRowCards(battlefieldRows);
        insert rowCards;
    }

    public void blockPlayerChange(List<Match__c> newMatches, Map<Id, Match__c> oldMatches) {
        for(Match__c match : newMatches) {
            Match__c oldMatch = oldMatches.get(match.Id);

            if(this.util.isChangedToOtherValue(match, oldMatch, 'PlayerOne__c') || this.util.isChangedToOtherValue(match, oldMatch, 'PlayerTwo__c')) {
                match.addError('Player One nor Player Two can be changed on the match');
            }
        }
    }
}
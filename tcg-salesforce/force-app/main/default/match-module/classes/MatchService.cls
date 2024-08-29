public with sharing class MatchService {
    MatchRepository repository = new MatchRepository();
    Match match = new Match();
    Util util = new Util();

    public void generateMatchRows(List<Match__c> newMatches, Map<Id, Match__c> oldMatches) {
        Set<Id> matchesIds = new Set<Id>();

        for(Match__c match : newMatches) {
            matchesIds.add(match.Id);
        }

        Set<String> idsPlayerAndMatch = this.repository.getBattleFieldRowsPerPlayerAndMatch(matchesIds);

        List<MatchFactory.PlayerMatch> playersPerMatch = this.match.getPlayersPerMatch(newMatches, oldMatches);
        List<BattlefieldRow__c> battlefieldRows = this.match.generateBattlefieldRows(playersPerMatch, matchesIds);
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

    public void updateStatusToOngoing(List<Match__c> newMatches, Map<Id, Match__c> oldMatches) {
        for(Match__c match : newMatches) {
            Match__c oldMatch = oldMatches.get(match.Id);

            if(match.Status__c == 'Waiting' && match.PlayerTwo__c != null && oldMatch.PlayerTwo__c == null) {
                match.Status__c = 'Ongoing';
            }

            if(match.PlayerTwo__c != null && match.PlayerOne__c != null && match.Status__c == 'Ongoing') {
                Integer startingPlayer = this.util.getRandomPlayerByNumber();
    
                if(startingPlayer == 1) {
                    match.StartingMatchPlayer__c = 'Player One';
                    match.PlayerTurn__c = 'Player One';
                    continue;
                }
                
                match.StartingMatchPlayer__c = 'Player Two';
                match.PlayerTurn__c = 'Player Two';
            }
        }
    }

    public void preparePlayersCards(List<Match__c> newMatches, Map<Id, Match__c> oldMatches) {
        Set<Id> matchesIdToPrepareCards = new Set<Id>();

        for(Match__c match : newMatches) {
            Match__c oldMatch = oldMatches.get(match.Id);

            if(match.Status__c == 'Ongoing' && oldMatch.Status__c == 'Waiting') {
                matchesIdToPrepareCards.add(match.Id);
            }
        }

        if(matchesIdToPrepareCards.isEmpty()) { return; }

        List<Match__c> matches = this.repository.getMatches(matchesIdToPrepareCards);

        for(Match__c matchRecord : matches) {
            Set<Id> playersDecksIds = new Set<Id>();
            playersDecksIds.add(matchRecord.PlayerOne__r.SelectedDeck__c);
            playersDecksIds.add(matchRecord.PlayerTwo__r.SelectedDeck__c);

            this.match.shufflePlayersDeck(playersDecksIds);
        }
    }

    public void setDeckCardsAsNotUsed(List<Match__c> newMatches) {
        Set<Id> playersIds = new Set<Id>();

        for(Match__c matchRecord : newMatches) {
            if(matchRecord.Status__c != 'Finished') { continue; }
            playersIds.add(matchRecord.PlayerOne__c);
            playersIds.add(matchRecord.PlayerTwo__c);
        }

        this.match.setDeckCardsAsNotUsed(playersIds);

    }
}
public with sharing class MatchFactory {
    Util util = new Util();

    public List<PlayerMatch> generatePlayersPerMatch(List<Match__c> matches, Map<Id, Match__c> oldMatches) {
        List<PlayerMatch> playersPerMatch = new List<PlayerMatch>();

        if(oldMatches == null) {
            return this.transformMatchesIntoPlayerMatch(matches);
        }

        for(Match__c match : matches) {
            Match__c oldMatch = oldMatches.get(match.Id);

            if(this.util.isChangedAndIsNotNull(match, oldMatch, 'PlayerOne__c')) {
                playersPerMatch.add( new PlayerMatch(match.Id, match.PlayerOne__c));
            }

            if(this.util.isChangedAndIsNotNull(match, oldMatch, 'PlayerTwo__c')) {
                playersPerMatch.add(new PlayerMatch(match.Id, match.PlayerOne__c));
            }
        }

        return playersPerMatch;
    }

    public List<PlayerMatch> transformMatchesIntoPlayerMatch(List<Match__c> matches) {
        List<PlayerMatch> playersPerMatch = new List<PlayerMatch>();

        for(Match__c match : matches) {
            if(match.PlayerOne__c != null) {
                playersPerMatch.add( new PlayerMatch(match.Id, match.PlayerOne__c));
            }

            if(match.PlayerTwo__c != null) {
                playersPerMatch.add(new PlayerMatch(match.Id, match.PlayerOne__c));
            }
        }

        return playersPerMatch;
    }

    public List<BattlefieldRow__c> generateBattlefieldRows(PlayerMatch playerPerMatch) {
        List<BattlefieldRow__c> battleFieldRowsGanerated = new List<BattlefieldRow__c>();

        Map<Decimal, RowConfiguration__mdt> rowConfigurationByRowNumber = this.generateRowConfigurationByRowNumberMap();
        Rule__mdt ruleRowsPerPlayer = Rule__mdt.getInstance('RowsPerPlayer');

        for(Integer rowCounter = 1; rowCounter <= ruleRowsPerPlayer.NumberValue__c; rowCounter++) {
            RowConfiguration__mdt rowConfiguration = rowConfigurationByRowNumber.get(rowCounter); 
            battleFieldRowsGanerated.add(new BattlefieldRow__c(
                                                            Match__c = playerPerMatch.matchId,
                                                            Player__c = playerPerMatch.playerId,
                                                            Category__c = rowConfiguration.RowCategory__c));
        }

        return battleFieldRowsGanerated;
    }

    public List<RowCard__c> generateCardRows(BattlefieldRow__c battlefieldRow) {
        List<RowCard__c> rowsCardGenerated = new List<RowCard__c>();

        Map<String, RowConfiguration__mdt> rowConfigurationByRowCategory = this.generateRowConfigurationByRowCategoryMap();
        RowConfiguration__mdt rowConfiguration = rowConfigurationByRowCategory.get(battlefieldRow.Category__c);

        for(Integer cardSlotCounter = 1; cardSlotCounter <= rowConfiguration.NumberCards__c; cardSlotCounter++) {
            rowsCardGenerated.add(new RowCard__c(
                                            BattlefieldRow__c = battlefieldRow.Id));
        }

        return rowsCardGenerated;
    }

    public Map<Decimal, RowConfiguration__mdt> generateRowConfigurationByRowNumberMap() {
        Map<Decimal, RowConfiguration__mdt> rowConfigurationByRowNumber = new Map<Decimal, RowConfiguration__mdt>();
        Map<String, RowConfiguration__mdt> rowConfigurations = RowConfiguration__mdt.getAll();

        for(RowConfiguration__mdt rowConfiguration : rowConfigurations.values()) {
            rowConfigurationByRowNumber.put(rowConfiguration.RowNumber__c, rowConfiguration);
        }

        return rowConfigurationByRowNumber;
    }

    public Map<String, RowConfiguration__mdt> generateRowConfigurationByRowCategoryMap() {
        Map<String, RowConfiguration__mdt> rowConfigurationByRowCategory = new Map<String, RowConfiguration__mdt>();
        Map<String, RowConfiguration__mdt> rowConfigurations = RowConfiguration__mdt.getAll();

        for(RowConfiguration__mdt rowConfiguration : rowConfigurations.values()) {
            rowConfigurationByRowCategory.put(rowConfiguration.RowCategory__c, rowConfiguration);
        }

        return rowConfigurationByRowCategory;
    }

    public PlayerHand__c generatePlayerhandCard(Id deckCardId, Id matchId, Id playerId) {
        PlayerHand__c playerHand = new PlayerHand__c();
        playerHand.ContactPlayerHand__c = playerId;
        playerHand.DeckCard__c = deckCardId;
        playerHand.MatchPlayerHand__c = matchId;

        return playerHand;
    }

    public class PlayerMatch {
        public PlayerMatch(Id matchId, Id playerId) {
            this.matchId = matchId;
            this.playerId = playerId;
        }

        public Id matchId { get;set; }
        public Id playerId { get;set; }
    }
}
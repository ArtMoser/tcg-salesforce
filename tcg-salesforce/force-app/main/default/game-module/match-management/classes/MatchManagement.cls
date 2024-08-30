public with sharing class MatchManagement {
    MatchManagementFactory factory = new MatchManagementFactory();
    MatchManagementRepository repository = new MatchManagementRepository();

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

    public void updatedRowCard(RowCard__c updatedRowCard) {
        update updatedRowCard;
    }

    public void deletePlayerHandRecord(Set<Id> deckCardIds) {
        List<PlayerHand__c> playerHandsToDelete = this.repository.getPlayerHandByDeckCardIds(deckCardIds);
        delete playerHandsToDelete;
    }

    public void createMatchEvent(Contact player, String matchId, String event) {
        update this.factory.updateMatchEvent(player, matchId, event);

        Match__c match = this.repository.getMatchById(matchId);

        MatchUpdate__e matchUpdateEvent = new MatchUpdate__e();
        matchUpdateEvent.MatchId__c = matchId;
        matchUpdateEvent.Match__c = JSON.serialize(match);
        matchUpdateEvent.Event__c = event;
        matchUpdateEvent.PlayerLoginCode__c = player.LoginCode__c;
        EventBus.publish(matchUpdateEvent);
    }

    public void consumeEnergy(String playerLoginCode, String matchId, Decimal energyCost) {
        List<RowCard__c> rowCardsToConsume = new List<RowCard__c>();
        List<MatchCemetery__c> matchCemetery = new List<MatchCemetery__c>();

        List<RowCard__c> energyRowCards = this.repository.getCardRowsEnnergyByMatchAndPlayerLoginCode(matchId, playerLoginCode);

        Integer counter = 1;
        for(RowCard__c rowCard : energyRowCards) {
            if(counter > energyCost) { break; }
            rowCardsToConsume.add(rowCard);
            counter++;
        }

        if(!rowCardsToConsume.isEmpty()) {
            for(RowCard__c rowCard : rowCardsToConsume) {
                matchCemetery.add(new MatchCemetery__c(
                    DeckCard__c = rowCard.DeckCard__c,
                    MatchCemetery__c = matchId,
                    PlayerCemetery__c = rowCard.Deckcard__r.PlayerCard__r.Player__c
                ));
                rowCard.DeckCard__c = null;
            }
        }

        update rowCardsToConsume;
        insert matchCemetery;
    }
}
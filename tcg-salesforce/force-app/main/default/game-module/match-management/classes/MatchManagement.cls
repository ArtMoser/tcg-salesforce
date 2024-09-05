public with sharing class MatchManagement {
    MatchManagementFactory factory = new MatchManagementFactory();
    MatchManagementRepository repository = new MatchManagementRepository();
    UtilRepository utilRepository = new UtilRepository();

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
        Match__c match = this.repository.getMatchById(matchId);
        match.LastPlayerAction__c = player.Id;
        match.Event__c = event;
        match.MatchEvents__c += event + '|';
        update match;
        //Match__c matchToUpdate = this.factory.updateMatchEvent(player, matchId, event);

        
        

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

    public void causeDirectDamage(Integer damage, String matchId, String playerLoginCode) {
        Match__c match = this.repository.getMatchById(matchId);

        if(match.PlayerOne__r.LoginCode__c == playerLoginCode) {
            match.LifePointsPlayerTwo__c -= damage;
        }

        if(match.PlayerTwo__r.LoginCode__c == playerLoginCode) {
            match.LifePointsPlayerOne__c -= damage;
        }

        update match;
    }

    public void sendDeckCardToCemetery(String matchId, String deckCardIdToDestroy) {
        List<MatchCemetery__c> matchCemetery = new List<MatchCemetery__c>();

        List<RowCard__c> energyRowCards = this.repository.getCardRowsByDeckCardId(matchId, deckCardIdToDestroy);

        for(RowCard__c rowCard : energyRowCards) {
            matchCemetery.add(new MatchCemetery__c(
                DeckCard__c = rowCard.DeckCard__c,
                MatchCemetery__c = matchId,
                PlayerCemetery__c = rowCard.Deckcard__r.PlayerCard__r.Player__c
            ));

            rowCard.DeckCard__c = null;
        }

        update energyRowCards;
        insert matchCemetery;
    }

    public void endTurn(String matchId) {
        Match__c match = this.repository.getMatchById(matchId);
        match.Turn__c += 1;
        

        Boolean isTurnEven = (match.Turn__c - Math.floor(match.Turn__c / 2) * 2) == 0;

        DeckCard__c deckCard = null;
        if (match.StartingMatchPlayer__c == 'Player One' && isTurnEven) {
            List<DeckCard__c> deckCards = this.getPlayerAvailableDeckCards(match.PlayerOne__r.LoginCode__c, matchId);
            if(!deckCards.isEmpty()) {
                deckCard = deckCards.get(0);
            }
        } else {
            List<DeckCard__c> deckCards = this.getPlayerAvailableDeckCards(match.PlayerTwo__r.LoginCode__c, matchId);
            if(!deckCards.isEmpty()) {
                deckCard = deckCards.get(0);
            }
        }

        if(deckCard != null) {
            PlayerHand__c playerHand = new PlayerHand__c();
            playerHand.ContactPlayerHand__c = deckCard.Deck__r.Player__c;
            playerHand.DeckCard__c = deckCard.Id;
            playerHand.MatchPlayerHand__c = matchId;
            insert playerHand;
        }

        update match;
    }

    public List<DeckCard__c> getPlayerAvailableDeckCards(String playerLoginCode, String matchId) {
        Set<Id> deckCardsUsed = new Set<Id>();
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);

        Set<Id> deckCardsOnCemetery = this.repository.getPlayerDeckCardsOnCemetery(player, matchId);
        Set<Id> deckCardsOnHand = this.repository.getPlayerDeckCardsOnHand(player, matchId);
        Set<Id> deckCardsOnField = this.repository.getPlayerDeckCardsOnField(player, matchId);

        for(Id deckCardId : deckCardsOnCemetery) {
            deckCardsUsed.add(deckCardId); 
        }

        for(Id deckCardId : deckCardsOnHand) {
            deckCardsUsed.add(deckCardId); 
        }

        for(Id deckCardId : deckCardsOnField) {
            deckCardsUsed.add(deckCardId); 
        }

        return this.repository.getPlayerAvailableDeckCards(player.SelectedDeck__c, deckCardsUsed);
    }
}
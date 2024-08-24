public with sharing class Match {
    MatchRepository repository = new MatchRepository();
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

    public void shufflePlayersDeck(Set<Id> playersDecksIds) {
        List<PlayerHand__c> playerHandsToAdd = new List<PlayerHand__c>();
        List<DeckCard__c> deckCardsToUpdate = new List<DeckCard__c>();
        Integer initialHandCards = 5;
        
        Map<Id, List<DeckCard__c>> deckCardsByPlayerId = this.repository.getPlayersDecks(playersDecksIds);
        Map<Id, Match__c> matchesByPlayerId = this.repository.getPlayersMatchByPlayerId(deckCardsByPlayerId.keySet());

        for(Id playerId : deckCardsByPlayerId.keySet()) {
            List<DeckCard__c> deckCards = deckCardsByPlayerId.get(playerId);
            Integer cardOrderCounter = 0;

            list<DeckCard__c> deckCardsShuffled = this.shuffleDeckCards(deckCards);
            List<PlayerHand__c> playerHandsLocal = new List<PlayerHand__c>();

            for(DeckCard__c deckCard : deckCardsShuffled) {
                deckCard.Order__c = cardOrderCounter;
                cardOrderCounter++;

                if(playerHandsLocal.size() < initialHandCards) {
                    PlayerHand__c playerHand = this.factory.generatePlayerhandCard(deckCard.Id, matchesByPlayerId.get(playerId).Id, playerId);
                    playerHandsLocal.add(playerHand);
                    playerHandsToAdd.add(playerHand);
                    deckCard.Used__c = true;
                }

                deckCardsToUpdate.add(deckCard);
            }
        }
        update deckCardsToUpdate;
        insert playerHandsToAdd;
    }

    public List<DeckCard__c> shuffleDeckCards(List<DeckCard__c> deckCards){
        DeckCard__c deckCard;
        integer randomIndex;
        integer currentIndex = deckCards.size();
         
        while (currentIndex != 0) {
            randomIndex = integer.valueOf(Math.floor(Math.random() * currentIndex));
            currentIndex -= 1;
            deckCard = deckCards[currentIndex];
            deckCards[currentIndex] = deckCards[randomIndex];
            deckCards[randomIndex] = deckCard;
        }
        return deckCards;
    }

    public void setDeckCardsAsNotUsed(Set<Id> playersId) {
        List<DeckCard__c> deckCards = this.repository.getDeckCardsByPlayerIds(playersId);

        for(DeckCard__c deckCard : deckCards) {
            deckCard.Used__c = false;
        }

        update deckCards;
    }
}
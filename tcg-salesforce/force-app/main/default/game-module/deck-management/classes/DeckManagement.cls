public with sharing class DeckManagement {
    DeckManagementRepository repository = new DeckManagementRepository();
    DeckManagementFactory factory = new  DeckManagementFactory();

    public void removeCardsFromDeck(DeckManagementFactory.PlayerCardsToDeck deckCardsToRemove) {
        List<DeckCard__c> deckCards = this.repository.getDeckCardsByPlayerCardsIdAndDeckId(deckCardsToRemove.deckId, deckCardsToRemove.playerCardIds);
        Database.delete(deckCards, false);
    }

    public void addCardsToDeck(DeckManagementFactory.PlayerCardsToDeck deckCardsToAdd) {
        List<DeckCard__c> deckCards = new List<DeckCard__c>();

        for(String playerCardId : deckCardsToAdd.playerCardIds) {
            deckCards.add(new DeckCard__c(
                Deck__c = deckCardsToAdd.deckId,
                PlayerCard__c = playerCardId
            ));
        }
        Database.insert(deckCards, false);
    }

    public Deck__c generateDeck(Contact player) {
        Integer deckQuantity = player.Decks__r.size();

        Deck__c generatedDeck = this.factory.generateDeck(('Deck - ' + deckQuantity), player.Id);
        insert generatedDeck;

        return generatedDeck;
    }
}
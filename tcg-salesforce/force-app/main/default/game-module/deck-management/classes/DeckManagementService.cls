public with sharing class DeckManagementService {
    DeckManagement deckManagement = new DeckManagement(); 
    DeckManagementRepository repository = new DeckManagementRepository();

    private static final DeckManagementService deckManagementServiceInstance = new DeckManagementService();

    public static DeckManagementService getInstance() {
        return deckManagementServiceInstance;
    }

    public List<PlayerCard__c> getPlayerCards(String playerLoginCode) {
        return repository.getPlayerCardsByPlayerLoginCode(playerLoginCode);
    }

    public List<Deck__c> getPlayerDecks(String playerLoginCode) {
        return repository.getDecksByPlayerLoginCode(playerLoginCode);
    }

    public DeckManagementFactory.DeckManagementResponse updateDeckCards(DeckManagementFactory.PlayerCardsToDeck deckCardsToRemove, DeckManagementFactory.PlayerCardsToDeck deckCardsToAdd) {
        DeckManagementFactory.DeckManagementResponse response = new DeckManagementFactory.DeckManagementResponse();

        try {
            //DeckManagementFactory.PlayerCardsToDeck deckCardsToRemove = (DeckManagementFactory.PlayerCardsToDeck) JSON.deserialize(deckCardsToRemoveJSON, DeckManagementFactory.PlayerCardsToDeck.class);
            //DeckManagementFactory.PlayerCardsToDeck deckCardsToAdd = (DeckManagementFactory.PlayerCardsToDeck) JSON.deserialize(deckCardsToAddJSON, DeckManagementFactory.PlayerCardsToDeck.class);
            this.deckManagement.removeCardsFromDeck(deckCardsToRemove);
            this.deckManagement.addCardsToDeck(deckCardsToAdd);
        } catch(Exception error) {
            response.success = false;
        }

        return response;
    }
}
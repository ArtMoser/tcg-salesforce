public with sharing class DeckManagementService {
    DeckManagement deckManagement = new DeckManagement(); 
    DeckManagementRepository repository = new DeckManagementRepository();

    private static final DeckManagementService deckManagementServiceInstance = new DeckManagementService();

    public static DeckManagementService getInstance() {
        return deckManagementServiceInstance;
    }

    public Contact getPlayer(String playerLoginCode) {
        return repository.getContactWithDecks(playerLoginCode);
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
            this.deckManagement.removeCardsFromDeck(deckCardsToRemove);
            this.deckManagement.addCardsToDeck(deckCardsToAdd);
        } catch(Exception error) {
            response.success = false;
        }

        return response;
    }

    public DeckManagementFactory.DeckManagementResponse createNewPlayerDeck(String playerLoginCode) {
        DeckManagementFactory.DeckManagementResponse response = new DeckManagementFactory.DeckManagementResponse();

        try {
            Contact player = this.repository.getContactWithDecks(playerLoginCode);
            Deck__c generatedDeck = this.deckManagement.generateDeck(player);
            
            response.recordId = generatedDeck.Id;
        } catch (Exception error) {
            response.success = false;
        }

        return response;
    }

    public void setPlayerSelectedDeck(String playerLoginCode, String deckId) {
        Contact player = this.repository.getContactWithDecks(playerLoginCode);
        this.DeckManagement.setPlayerSelectedDeck(player, deckId);
    }
}
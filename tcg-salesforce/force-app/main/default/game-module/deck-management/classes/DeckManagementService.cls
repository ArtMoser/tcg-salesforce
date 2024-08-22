public with sharing class DeckManagementService {
    DeckManagementRepository repository = new DeckManagementRepository();
    private static final DeckManagementService instance = new DeckManagementService();

    public static DeckManagementService getInstance() {
            return instance;
    }

    public List<PlayerCard__c> getPlayerCards(String playerLoginCode) {
        return repository.getPlayerCardsByPlayerLoginCode(playerLoginCode);
    }

    public List<Deck__c> getPlayerDecks(String playerLoginCode) {
        return repository.getDecksByPlayerLoginCode(playerLoginCode);
    }
}
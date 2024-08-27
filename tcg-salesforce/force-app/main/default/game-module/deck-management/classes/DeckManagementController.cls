public with sharing class DeckManagementController {
    @AuraEnabled
    public static Contact getPlayer(String playerLoginCode) {
        return DeckManagementService.getInstance().getPlayer(playerLoginCode);
    }

    @AuraEnabled
    public static List<PlayerCard__c> getPlayerCards(String playerLoginCode) {
        return DeckManagementService.getInstance().getPlayerCards(playerLoginCode);
    }

    @AuraEnabled
    public static List<Deck__c> getPlayerDecks(String playerLoginCode) {
        return DeckManagementService.getInstance().getPlayerdecks(playerLoginCode);
    }

    @AuraEnabled
    public static DeckManagementFactory.DeckManagementResponse updateDeckCards(DeckManagementFactory.PlayerCardsToDeck deckCardsToRemove, DeckManagementFactory.PlayerCardsToDeck deckCardsToAdd) {
        return DeckManagementService.getInstance().updateDeckCards(deckCardsToRemove, deckCardsToAdd);
    }

    @AuraEnabled
    public static DeckManagementFactory.DeckManagementResponse generateNewDeck(String playerLoginCode) {
        return DeckManagementService.getInstance().createNewPlayerDeck(playerLoginCode);
    }

    @AuraEnabled
    public static void setPlayerSelectedDeck(String playerLoginCode, String deckId) {
        DeckManagementService.getInstance().setPlayerSelectedDeck(playerLoginCode, deckId);
    }
}
public with sharing class DeckManagementController {
    @AuraEnabled
    public static List<PlayerCard__c> getPlayerCards(String playerLoginCode) {
        return DeckManagementService.getInstance().getPlayerCards(playerLoginCode);
    }

    @AuraEnabled
    public static List<Deck__c> getPlayerDecks(String playerLoginCode) {
        return DeckManagementService.getInstance().getPlayerdecks(playerLoginCode);
    }
}
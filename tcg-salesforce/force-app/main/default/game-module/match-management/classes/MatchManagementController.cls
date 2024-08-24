public with sharing class MatchManagementController {
    @AuraEnabled
    public static Contact getPlayer(String playerLoginCode) {
        return MatchManagementService.getInstance().getPlayer(playerLoginCode);
    }

    @AuraEnabled
    public static Deck__c getPlayerDeck(String deckId) {
        return MatchManagementService.getInstance().getPlayerDeck(deckId);
    }
}
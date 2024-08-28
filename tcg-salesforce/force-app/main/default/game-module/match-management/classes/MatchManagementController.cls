public with sharing class MatchManagementController {
    @AuraEnabled
    public static Contact getPlayer(String playerLoginCode) {
        return MatchManagementService.getInstance().getPlayer(playerLoginCode);
    }

    @AuraEnabled
    public static List<DeckCard__c> getPlayerAvailableDeckCards(String playerLoginCode, String matchId) {
        return MatchManagementService.getInstance().getPlayerAvailableDeckCards(playerLoginCode, matchId);
    }

    @AuraEnabled
    public static Match__c getCurrentMatch(String playerLoginCode) {
        return MatchManagementService.getInstance().getCurrentMatch(playerLoginCode);
    }

    @AuraEnabled
    public static List<PlayerHand__c> getPlayersHands(String playerLoginCode, String matchId) {
        return MatchManagementService.getInstance().getPlayersHands(playerLoginCode, matchId);
    }

    @AuraEnabled
    public static void savePlayerHand(List<PlayerHand__c> playerHands) {
        MatchManagementService.getInstance().savePlayerHand(playerHands);
    }

    @AuraEnabled
    public static List<RowCard__c> getAllRowCards(String matchId) {
        return MatchManagementService.getInstance().getAllRowCards(matchId);
    }

    @AuraEnabled
    public static List<MatchCemetery__c> getAllCemeteryCards(String matchId) {
        return MatchManagementService.getInstance().getAllCemeteryCards(matchId);
    }
}
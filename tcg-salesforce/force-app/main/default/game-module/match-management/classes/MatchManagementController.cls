public with sharing class MatchManagementController {

    @AuraEnabled
    public static MatchManagementFactory.MatchData getAllMatchData(String playerLoginCode, String matchId) {
        MatchManagementFactory.MatchData matchData = new MatchManagementFactory.MatchData();
        matchData.player = MatchManagementService.getInstance().getPlayer(playerLoginCode);
        matchData.match = MatchManagementService.getInstance().getCurrentMatch(playerLoginCode);
        matchId = matchData.match.Id;
        matchData.deckCards = MatchManagementService.getInstance().getPlayerAvailableDeckCards(playerLoginCode, matchId);
        matchData.playersHands = MatchManagementService.getInstance().getPlayersHands(playerLoginCode, matchId);
        matchData.rowCards = MatchManagementService.getInstance().getAllRowCards(matchId);
        matchData.matchCemitery = MatchManagementService.getInstance().getAllCemeteryCards(matchId);

        return matchData;
    }

    @AuraEnabled
    public static void savePlayerHand(List<PlayerHand__c> playerHands) {
        MatchManagementService.getInstance().savePlayerHand(playerHands);
    }

    @AuraEnabled
    public static void upadateRowCard(RowCard__c rowCardUpdated, String playerLoginCode, String matchId){
        MatchManagementService.getInstance().sendEnergyToCemetery(rowCardUpdated, playerLoginCode, matchId);
        MatchManagementService.getInstance().upadateRowCard(rowCardUpdated, playerLoginCode, matchId);
    }

    @AuraEnabled
    public static void causeDirectDamage(Integer damage, String matchId, String playerLoginCode){
        MatchManagementService.getInstance().causeDirectDamage(damage, matchId, playerLoginCode);
    }

    @AuraEnabled
    public static void destroyEnemyCardAndCauseDirectDamage(String playerLoginCode, Integer damage, String enemyDeckCardIdToDestroy, String matchId) {
        MatchManagementService.getInstance().destroyEnemyCardAndCauseDirectDamage(playerLoginCode, damage, enemyDeckCardIdToDestroy, matchId);
    }

    @AuraEnabled
    public static void destroyPlayerCard(String playerLoginCode, String playerDeckCardIdToDestroy, String matchId) {
        MatchManagementService.getInstance().destroyPlayerCard(playerLoginCode, playerDeckCardIdToDestroy, matchId);
    }

    @AuraEnabled
    public static void destroyPlayerAndEnemyCard(String playerLoginCode, String playerDeckCardIdToDestroy, String enemyDeckCardIdToDestroy, String matchId) {
        MatchManagementService.getInstance().destroyPlayerAndEnemyCard(playerLoginCode, playerDeckCardIdToDestroy, enemyDeckCardIdToDestroy, matchId);
        
    }

    @AuraEnabled
    public static void endTurn(String playerLoginCode, String matchId) {
        MatchManagementService.getInstance().endTurnAndDrawCard(playerLoginCode, matchId);
    }

    @AuraEnabled
    public static Boolean login(String playerLoginCode) {
        return MatchManagementService.getInstance().login(playerLoginCode);
    }
}
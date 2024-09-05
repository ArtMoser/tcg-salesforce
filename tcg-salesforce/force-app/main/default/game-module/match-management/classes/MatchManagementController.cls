public with sharing class MatchManagementController {

    @AuraEnabled
    public static MatchManagementFactory.MatchData getAllMatchData(String playerLoginCode, String matchId) {
        MatchManagementFactory.MatchData matchData = new MatchManagementFactory.MatchData();
        matchData.player = MatchManagementService.getInstance().getPlayer(playerLoginCode);

        if(matchId != null) {
            matchData.match = MatchManagementService.getInstance().getCurrentMatchById(matchId);
        } else {
            matchData.match = MatchManagementService.getInstance().getCurrentMatch(playerLoginCode);
        }

        if(matchData.match != null) {
            matchId = matchData.match.Id;
        }

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
    public static void finishMatch(String matchId) {
        MatchManagementService.getInstance().finishMatch(matchId);
    }

    @AuraEnabled
    public static MatchManagementFactory.LoginData login(String playerLoginCode) {
        Match__c ongoingMatch = MatchManagementService.getInstance().getCurrentMatch(playerLoginCode);

        MatchManagementFactory.LoginData loginData = new MatchManagementFactory.LoginData();
        loginData.match = ongoingMatch;
        loginData.successfulLogin = MatchManagementService.getInstance().login(playerLoginCode);

        return loginData;
    }
}
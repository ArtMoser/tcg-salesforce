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
}
public with sharing class MatchFinderController {
    @AuraEnabled
    public static MatchFinderFactory.MatchFinderData getAllWaitingMatches(String playerLoginCode) {
        MatchFinderFactory.MatchFinderData matchData = new MatchFinderFactory.MatchFinderData();
        matchData.match = MatchManagementService.getInstance().getCurrentMatch(playerLoginCode);
        matchData.matches = MatchFinderService.getInstance().getAllWaitingMatches();

        return matchData;
    }

    @AuraEnabled
    public static Match__c createMatch(String playerLoginCode) {
        return MatchFinderService.getInstance().generateMatch(playerLoginCode);
    }

    @AuraEnabled
    public static void cancelMatch(String matchId) {
        MatchFinderService.getInstance().cancelMatch(matchId);
    }

    @AuraEnabled
    public static void enterMatch(String matchId, String playerLoginCode) {
        MatchFinderService.getInstance().enterMatch(matchId, playerLoginCode);
    }
}
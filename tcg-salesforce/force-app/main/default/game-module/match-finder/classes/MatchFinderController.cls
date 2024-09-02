public with sharing class MatchFinderController {
    @AuraEnabled
    public static List<Match__c> getAllWaitingMatches() {
        return MatchFinderService.getInstance().getAllWaitingMatches();
    }

    @AuraEnabled
    public static Match__c createMatch(String playerLoginCode) {
        return MatchFinderService.getInstance().generateMatch(playerLoginCode);
    }

    @AuraEnabled
    public static void cancelMatch(String matchId) {
        MatchFinderService.getInstance().cancelMatch(matchId);
    }
}
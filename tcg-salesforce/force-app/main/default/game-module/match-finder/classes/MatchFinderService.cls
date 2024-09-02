public with sharing class MatchFinderService {
    MatchFinderRepository repository = new MatchFinderRepository();
    UtilRepository utilRepository = new UtilRepository();

    private static final MatchFinderService matchFinderServiceInstance = new MatchFinderService();
    public static MatchFinderService getInstance() {
        return matchFinderServiceInstance;
    }

    public List<Match__c> getAllWaitingMatches() {
        return this.repository.getMatchesByStatus('Waiting');
    }

    public Match__c generateMatch(String playerLoginCode) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        
        Match__c match = new Match__c();
        match.PlayerOne__c = player.Id;
        insert match;

        return match;
    }

    public void cancelMatch(String matchId) {
        Match__c match = new Match__c();
        match.Id = matchId;
        match.Status__c = 'Cancelled';

        update match;
    }
}
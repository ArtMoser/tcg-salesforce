public with sharing class MatchManagementService {
    UtilRepository utilRepository = new UtilRepository();
    MatchManagementRepository repository = new MatchManagementRepository();
    MatchManagement matchManagement = new MatchManagement();

    private static final MatchManagementService matchManagementServiceInstance = new MatchManagementService();
    public static MatchManagementService getInstance() {
        return matchManagementServiceInstance;
    }

    public Contact getPlayer(String playerLoginCode) {
        return this.utilRepository.getContactWithDecks(playerLoginCode);
    }

    public Deck__c getPlayerDeck(String deckId) {
        return this.repository.getPlayerDeck(deckId);
    }

    public Match__c findOrCreateMatch(String playerLoginCode) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        List<Match__c> waitingMatches = this.repository.getAnWaitingMatch();

        if(waitingMatches.isEmpty()) {
            return this.matchManagement.createMatch(player);
        }

        return this.matchManagement.updateFoundMatch(waitingMatches.get(0), player);
    }

    public void updateMatch(String matchId) {
        Match__c match = this.repository.getMatchById(matchId);
        this.matchManagement.updateMatch(match);
    }
}
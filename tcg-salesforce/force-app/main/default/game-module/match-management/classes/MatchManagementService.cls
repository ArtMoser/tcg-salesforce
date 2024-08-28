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

    public List<DeckCard__c> getPlayerAvailableDeckCards(String playerLoginCode, String matchId) {
        Set<Id> deckCardsUsed = new Set<Id>();
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);

        Set<Id> deckCardsOnCemetery = this.repository.getPlayerDeckCardsOnCemetery(player, matchId);
        Set<Id> deckCardsOnHand = this.repository.getPlayerDeckCardsOnHand(player, matchId);
        Set<Id> deckCardsOnField = this.repository.getPlayerDeckCardsOnField(player, matchId);

        for(Id deckCardId : deckCardsOnCemetery) { deckCardsUsed.add(deckCardId); }
        for(Id deckCardId : deckCardsOnHand) { deckCardsUsed.add(deckCardId); }
        for(Id deckCardId : deckCardsOnField) { deckCardsUsed.add(deckCardId); }

        return this.repository.getPlayerAvailableDeckCards(player.SelectedDeck__c, deckCardsUsed);
    }

    public Match__c getCurrentMatch(String playerLoginCode) {
        return this.repository.getMatchByPLayerCode(playerLoginCode);
    }

    public void savePlayerHand(List<PlayerHand__c> playerHands) {
        insert playerHands;
    }

    public List<PlayerHand__c> getPlayersHands(String playerLoginCode, String matchId) {
        return this.repository.getPlayersHands(playerLoginCode, matchId);
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

    public List<RowCard__c> getAllRowCards(String matchId) {
        return this.repository.getAllRowCards(matchId);
    }

    public List<MatchCemetery__c> getAllCemeteryCards(String matchId) {
        return this.repository.getAllCemeteryCards(matchId);
    }
}
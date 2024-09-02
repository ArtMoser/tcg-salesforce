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
        return this.matchManagement.getPlayerAvailableDeckCards(playerLoginCode, matchId);
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

    public void upadateRowCard(RowCard__c updatedRowCard, String playerLoginCode, String matchId) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        this.matchManagement.updatedRowCard(updatedRowCard);
        this.matchManagement.deletePlayerHandRecord(new Set<Id>{updatedRowCard.DeckCard__c});
        this.matchManagement.createMatchEvent(player, matchId, player.Name +': Put card on field');
    }

    public void sendEnergyToCemetery(RowCard__c updatedRowCard, String playerLoginCode, String matchId) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        DeckCard__c deckCardPutInField = this.repository.getDeckCardById(updatedRowCard.DeckCard__c);

        if(deckCardPutInField.PlayerCard__r.Card__r.Type__c == 'Monster' && deckCardPutInField.PlayerCard__r.Card__r.EnergyCost__c > 0) {
            this.matchManagement.consumeEnergy(playerLoginCode, matchId, deckCardPutInField.PlayerCard__r.Card__r.EnergyCost__c);
            //this.matchManagement.createMatchEvent(player, matchId, player.Name + ': Spent an Energy to summon ' + deckCardPutInField.PlayerCard__r.Card__r.Name);
        }
    }

    public void causeDirectDamage(Integer damage, String matchId, String playerLoginCode) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);

        this.matchManagement.causeDirectDamage(damage, matchId, playerLoginCode);
        this.matchManagement.createMatchEvent(player, matchId, player.Name + ': Directed attacked the enemy');
    }
    
    public void destroyEnemyCardAndCauseDirectDamage(String playerLoginCode, Integer damage, String enemyDeckCardIdToDestroy, String matchId) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        this.matchManagement.causeDirectDamage(damage, matchId, playerLoginCode);
        this.matchManagement.sendDeckCardToCemetery(matchId, enemyDeckCardIdToDestroy);
        this.matchManagement.createMatchEvent(player, matchId, player.Name + ': Destroyed a card and caused ' + damage + ' damage');
    }

    public void destroyPlayerCard(String playerLoginCode, String playerDeckCardIdToDestroy, String matchId) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        this.matchManagement.sendDeckCardToCemetery(matchId, playerDeckCardIdToDestroy);
        this.matchManagement.createMatchEvent(player, matchId, player.Name + ': Attacked a card but, ' + player.Name + '\'s card was destroyed');
    }

    public void destroyPlayerAndEnemyCard(String playerLoginCode, String playerDeckCardIdToDestroy, String enemyDeckCardIdToDestroy, String matchId) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        this.matchManagement.sendDeckCardToCemetery(matchId, playerDeckCardIdToDestroy);
        this.matchManagement.sendDeckCardToCemetery(matchId, enemyDeckCardIdToDestroy);
        this.matchManagement.createMatchEvent(player, matchId, player.Name + ': Attacked a card but both were destroyed');
    }

    public void endTurnAndDrawCard(String playerLoginCode, String matchId) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        this.matchManagement.endTurn(matchId);
        this.matchManagement.createMatchEvent(player, matchId, player.Name + ': Finished the turn and the other player draw a card');
    }

    public Boolean login(String playerLoginCode) {
        Contact player = this.utilRepository.getContactWithDecks(playerLoginCode);
        return player != null;
    }
}
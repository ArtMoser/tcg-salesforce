public with sharing class DeckManagementFactory {
    public class PlayerCardsToDeck {
        @AuraEnabled
        public String deckId { get;set; }
        @AuraEnabled
        public List<String> playerCardIds { get;set; }
    }

    public class DeckManagementResponse {
        @AuraEnabled
        public Boolean success { get;set; }
        @AuraEnabled
        public String message { get;set; }
        @AuraEnabled
        public String recordId { get;set; }

        public DeckManagementResponse() {
            this.success = true;
            this.message = '';
            this.recordId = '';
        }
    }

    public Deck__c generateDeck(String name, Id playerId) {
        return new Deck__c(Name = name, Player__c = playerId);
    }
}
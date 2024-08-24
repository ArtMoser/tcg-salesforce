public with sharing class MatchManagementRepository {
    public Deck__c getPlayerDeck(String deckId) {
        return [
            SELECT
                Id,
                Player__c,
                Name,
                (
                    SELECT
                        Id,
                        PlayerCard__r.Card__c,
                        PlayerCard__r.Name,
                        PlayerCard__r.Card__r.Attack__c,
                        PlayerCard__r.Card__r.Defense__c,
                        PlayerCard__r.Card__r.Description__c,
                        PlayerCard__r.Card__r.Image__c,
                        PlayerCard__r.Card__r.Rarity__c,
                        PlayerCard__r.Card__r.Type__c,
                        PlayerCard__r.Card__r.EnergyCost__c,
                        PlayerCard__r.Card__r.RarityColor__c
                    FROM
                        DeckCards__r
                    ORDER BY
                        Order__c
                    ASC
                )
            FROM
                Deck__c
            WHERE
                Id =: deckId
        ];
    }

    public List<Match__c> getAnWaitingMatch() {
        return [
            SELECT
                Id,
                PlayerOne__c,
                PlayerTwo__c
            FROM
                Match__c
            WHERE
                Status__c = 'Waiting'
            ORDER BY
                CreatedDate ASC
        ];
    }

    public Match__c getMatchById(String matchId) {
        return [
            SELECT
                Id,
                UpdateMatch__c
            FROM
                Match__c
            WHERE
                Id =: matchId
        ];
    }
}
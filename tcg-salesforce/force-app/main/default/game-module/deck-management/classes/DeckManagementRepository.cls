public with sharing class DeckManagementRepository {
    public List<PlayerCard__c> getPlayerCardsByPlayerLoginCode(String playerLoginCode) {
        return [
            SELECT
                Id,
                Card__c,
                Card__r.Name,
                Card__r.Attack__c,
                Card__r.Defense__c,
                Card__r.Description__c,
                Card__r.Image__c,
                Card__r.Rarity__c,
                Card__r.Type__c,
                Card__r.EnergyCost__c,
                Player__c
            FROM
                PlayerCard__c
            WHERE
                Player__r.LoginCode__c =: playerLoginCode
        ];
    }

    public List<Deck__c> getDecksByPlayerLoginCode(String playerLoginCode) {
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
                        PlayerCard__r.Card__r.EnergyCost__c
                    FROM
                        DeckCards__r
                )
            FROM
                Deck__c
            WHERE
                Player__r.LoginCode__c =: playerLoginCode
        ];
    }

    public List<DeckCard__c> getDeckCardsByPlayerCardsIdAndDeckId(String deckId, List<String> playerCardIds) {
        return [
            SELECT
                Id
            FROM
                DeckCard__c
            WHERE
                PlayerCard__c IN: playerCardIds AND
                Deck__c =: deckId
        ];
    }
}
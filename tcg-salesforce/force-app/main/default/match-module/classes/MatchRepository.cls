public with sharing class MatchRepository {
    public List<Match__c> getMatches(Set<Id> matchesId) {
        return [
            SELECT
                Id,
                PlayerOne__r.SelectedDeck__c,
                PlayerTwo__r.SelectedDeck__c
            FROM
                Match__c
            WHERE
                Id In: matchesId
        ];
    }

    public Map<Id, List<DeckCard__c>> getPlayersDecks(Set<Id> playersDecksIds) {
        List<DeckCard__c> deckCards = [
                                    SELECT
                                        Id,
                                        Order__c,
                                        Deck__c,
                                        PlayerCard__r.Player__c
                                    FROM
                                        DeckCard__c
                                    WHERE
                                        Deck__c IN: playersDecksIds
        ];

        Map<Id, List<DeckCard__c>> deckCardsByPlayerId = new Map<Id, List<DeckCard__c>>();

        for(DeckCard__c deckCard : deckCards) {
            List<DeckCard__c> deckCardsFromMap = deckCardsByPlayerId.get(deckCard.PlayerCard__r.Player__c);

            if(deckCardsFromMap == null) {
                deckCardsFromMap = new List<DeckCard__c>();
            }

            deckCardsFromMap.add(deckCard);

            deckCardsByPlayerId.put(deckCard.PlayerCard__r.Player__c ,deckCardsFromMap);
        }

        return deckCardsByPlayerId;
    }

    public Map<Id, Match__c> getPlayersMatchByPlayerId(Set<Id> playerIds) {
        Map<Id, Match__c> matchesByPlayerId = new Map<Id, Match__c>();

        List<Match__c> matches = [
                                SELECT
                                    Id,
                                    PlayerOne__c,
                                    PlayerTwo__c
                                FROM
                                    Match__c
                                WHERE
                                    PlayerOne__c IN: playerIds OR
                                    PlayerTwo__c IN: playerIds
        ];

        for(Match__c match : matches) {
            matchesByPlayerId.put(match.PlayerOne__c, match);
            matchesByPlayerId.put(match.PlayerTwo__c, match);
        }

        return matchesByPlayerId;
    }

    public List<DeckCard__c> getDeckCardsByPlayerIds(Set<Id> playersIds) {
        return [
            SELECT
                Id,
                Used__c
            FROM
                DeckCard__c
            WHERE
                PlayerCard__r.Player__c IN: playersIds
            AND
                Used__c = true
        ];
    }

    public Set<String> getBattleFieldRowsPerPlayerAndMatch(Set<Id> matchesId) {
        //Map<String, List<BattlefieldRow__c>> battleFieldRowsPerPlayerAndMatch = new Map<String, List<BattlefieldRow__c>>();
        Set<String> idsPlayerAndMatch = new  Set<String>();
        
        List<BattlefieldRow__c> battlefieldRows = [
                                                    SELECT
                                                        Id,
                                                        Player__c,
                                                        Match__c
                                                    FROM
                                                        BattlefieldRow__c
                                                    WHERE
                                                        Match__c IN: matchesId
        ];

        for(BattlefieldRow__c battlefieldRow : battlefieldRows){
            idsPlayerAndMatch.add(battlefieldRow.Player__c + '' + battlefieldRow.Match__c);
        }

        return idsPlayerAndMatch;
    }
}
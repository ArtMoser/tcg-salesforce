public with sharing class MatchManagementRepository {
    public DeckCard__c getDeckCardById(Id deckCardId) {
        return [
            SELECT
                Id,
                PlayerCard__r.Card__c,
                Name,
                PlayerCard__r.Card__r.Name,
                PlayerCard__r.Card__r.Attack__c,
                PlayerCard__r.Card__r.Defense__c,
                PlayerCard__r.Card__r.Description__c,
                PlayerCard__r.Card__r.Image__c,
                PlayerCard__r.Card__r.Rarity__c,
                PlayerCard__r.Card__r.Type__c,
                PlayerCard__r.Card__r.EnergyCost__c,
                PlayerCard__r.Card__r.RarityColor__c,
                Deck__r.Player__r.LoginCode__c
            FROM
                DeckCard__c
            WHERE
                Id =: deckCardId
        ];
    }

    public List<RowCard__c> getCardRowsEnnergyByMatchAndPlayerLoginCode(String matchId, String playerLoginCode) {
        return [
            SELECT
                Id,
                DeckCard__c,
                DeckCard__r.PlayerCard__r.Card__r.Name,
                Deckcard__r.PlayerCard__r.Player__c
            FROM
                RowCard__c
            WHERE
                DeckCard__r.PlayerCard__r.Card__r.Type__c = 'Energy'
                AND
                BattlefieldRow__r.Match__c =: matchId
                AND
                BattlefieldRow__r.Player__r.LoginCode__c =: playerLoginCode
        ];
    }

    public List<RowCard__c> getCardRowsByDeckCardId(String matchId, String deckCardId) {
        return [
            SELECT
                Id,
                DeckCard__c,
                DeckCard__r.PlayerCard__r.Card__r.Name,
                Deckcard__r.PlayerCard__r.Player__c
            FROM
                RowCard__c
            WHERE
                DeckCard__c =: deckCardId
                AND
                BattlefieldRow__r.Match__c =: matchId
        ];
    }

    public List<DeckCard__c> getPlayerAvailableDeckCards(Id deckId, Set<Id> deckCardsUsed) {
        return [
            SELECT
                Id,
                PlayerCard__r.Card__c,
                Name,
                PlayerCard__r.Card__r.Attack__c,
                PlayerCard__r.Card__r.Defense__c,
                PlayerCard__r.Card__r.Description__c,
                PlayerCard__r.Card__r.Image__c,
                PlayerCard__r.Card__r.Rarity__c,
                PlayerCard__r.Card__r.Type__c,
                PlayerCard__r.Card__r.EnergyCost__c,
                PlayerCard__r.Card__r.RarityColor__c,
                Deck__r.Player__r.LoginCode__c,
                Deck__r.Player__c
            FROM
                DeckCard__c
            WHERE
                Deck__c =: deckId
                AND
                Id NOT IN: deckCardsUsed
            ORDER BY
                Order__c
            ASC
        ];
    }

    public Set<Id> getPlayerDeckCardsOnCemetery(Contact player, Id matchId) {
        Set<Id> deckCardIds = new Set<Id>();

        List<MatchCemetery__c> matchCemeteries = [
            SELECT
                Id,
                DeckCard__c
            FROM
                MatchCemetery__c
            WHERE
                DeckCard__r.Deck__c =: player.SelectedDeck__c
                AND
                MatchCemetery__c =: matchId
        ];

        for(matchCemetery__c matchCemitery : matchCemeteries) {
            deckCardIds.add(matchCemitery.DeckCard__c);
        }

        return deckCardIds;
    }

    public Set<Id> getPlayerDeckCardsOnHand(Contact player, Id matchId) {
        Set<Id> deckCardIds = new Set<Id>();

        List<PlayerHand__c> playerHands = [
            SELECT
                Id,
                DeckCard__c
            FROM
                PlayerHand__c
            WHERE
                DeckCard__r.Deck__c =: player.SelectedDeck__c
                AND
                MatchPlayerHand__c =: matchId
        ];

        for(PlayerHand__c playerHand : playerHands) {
            deckCardIds.add(playerHand.DeckCard__c);
        }

        return deckCardIds;
    }

    public Set<Id> getPlayerDeckCardsOnField(Contact player, Id matchId) {
        Set<Id> deckCardIds = new Set<Id>();

        List<RowCard__c> playerHands = [
            SELECT
                Id,
                DeckCard__c
            FROM
                RowCard__c
            WHERE
                DeckCard__r.Deck__c =: player.SelectedDeck__c
                AND
                BattlefieldRow__r.Match__c =: matchId
        ];

        for(RowCard__c playerHand : playerHands) {
            deckCardIds.add(playerHand.DeckCard__c);
        }

        return deckCardIds;
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
                UpdateMatch__c,
                Event__c,
                LastPlayerAction__c,
                LifePointsPlayerOne__c,
                LifePointsPlayerTwo__c,
                PlayerOne__c,
                PlayerTwo__c,
                PlayerOne__r.LoginCode__c,
                PlayerTwo__r.LoginCode__c,
                Turn__c,
                StartingMatchPlayer__c
            FROM
                Match__c
            WHERE
                Id =: matchId
        ];
    }

    public Match__c getMatchByPLayerCode(String playerLoginCode) {
        return [
            SELECT
                Id,
                PlayerOne__c,
                PlayerTwo__c,
                PlayerOne__r.LoginCode__c,
                PlayerTwo__r.LoginCode__c,
                StartingMatchPlayer__c,
                Turn__c
            FROM
                Match__c
            WHERE
                (PlayerOne__r.LoginCode__c =: playerLoginCode
            OR
                PlayerTwo__r.LoginCode__c =: playerLoginCode)
            AND
                Status__c = 'Ongoing'
        ];
    }

    public List<PlayerHand__c> getPlayersHands(String playerLoginCode, String matchId) {
        return [
            SELECT
                Id,
                DeckCard__c,
                DeckCard__r.PlayerCard__r.Card__r.Name,
                DeckCard__r.PlayerCard__r.Card__r.Attack__c,
                DeckCard__r.PlayerCard__r.Card__r.Defense__c,
                DeckCard__r.PlayerCard__r.Card__r.Description__c,
                DeckCard__r.PlayerCard__r.Card__r.Image__c,
                DeckCard__r.PlayerCard__r.Card__r.Rarity__c,
                DeckCard__r.PlayerCard__r.Card__r.Type__c,
                DeckCard__r.PlayerCard__r.Card__r.EnergyCost__c,
                DeckCard__r.PlayerCard__r.Card__r.RarityColor__c,
                MatchPlayerHand__c,
                ContactPlayerHand__c,
                ContactPlayerHand__r.LoginCode__c
            FROM
                PlayerHand__c
            WHERE
                MatchPlayerHand__c =: matchId
        ];
    }

    public List<RowCard__c> getAllRowCards(String matchId) {
        return [
            SELECT
                Id,
                BattlefieldRow__r.Match__c, 
                BattlefieldRow__r.Category__c,
                BattlefieldRow__r.Player__r.LoginCode__c,
                Deckcard__c,
                Deckcard__r.PlayerCard__r.Player__r.LoginCode__c,
                Deckcard__r.PlayerCard__r.Card__r.Name,
                Deckcard__r.PlayerCard__r.Card__r.Attack__c,
                Deckcard__r.PlayerCard__r.Card__r.Defense__c,
                Deckcard__r.PlayerCard__r.Card__r.Description__c,
                Deckcard__r.PlayerCard__r.Card__r.Image__c,
                Deckcard__r.PlayerCard__r.Card__r.Rarity__c,
                Deckcard__r.PlayerCard__r.Card__r.Type__c,
                Deckcard__r.PlayerCard__r.Card__r.EnergyCost__c,
                Deckcard__r.PlayerCard__r.Card__r.RarityColor__c
            FROM
                RowCard__c
            WHERE 
                BattlefieldRow__r.Match__c =: matchId
        ];
    }

    public List<MatchCemetery__c> getAllCemeteryCards(String matchId) {
        return [
            SELECT
                Id,
                PlayerCemetery__r.LoginCode__c,
                MatchCemetery__c, 
                Deckcard__c,
                Deckcard__r.PlayerCard__r.Player__r.LoginCode__c, 
                Deckcard__r.PlayerCard__r.Card__r.Attack__c,
                Deckcard__r.PlayerCard__r.Card__r.Defense__c,
                Deckcard__r.PlayerCard__r.Card__r.Description__c,
                Deckcard__r.PlayerCard__r.Card__r.Image__c,
                Deckcard__r.PlayerCard__r.Card__r.Rarity__c,
                Deckcard__r.PlayerCard__r.Card__r.Type__c,
                Deckcard__r.PlayerCard__r.Card__r.EnergyCost__c,
                Deckcard__r.PlayerCard__r.Card__r.RarityColor__c
            FROM
                MatchCemetery__c
            WHERE 
                MatchCemetery__c =: matchId
        ];
    }

    public List<PlayerHand__c> getPlayerHandByDeckCardIds(Set<Id> deckCardIds) {
        return [
            SELECT
                Id,
                DeckCard__c
            FROM
                PlayerHand__c
            WHERE
                DeckCard__c IN: deckCardIds
        ];
    }
}
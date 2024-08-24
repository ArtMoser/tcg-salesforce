public with sharing class UtilRepository {
    public Contact getContactWithDecks(String playerLoginCode) {
        List<Contact> players = [
                                SELECT
                                    Id,
                                    Name,
                                    SelectedDeck__c,
                                    LoginCode__c,
                                    (
                                        SELECT
                                            Id,
                                            Player__c
                                        FROM
                                            Decks__r
                                    )
                                FROM
                                    Contact
                                WHERE
                                    LoginCode__c =: playerLoginCode
                            ];
        if(players.isEmpty()) { return null; }

        return players.get(0);
    }
}
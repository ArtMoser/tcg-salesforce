Deck__c deck = new Deck__c();
deck.Player__c = '003bm000003D1uEAAS';
deck.Name = 'Deck Teste ' + deck.Player__c;
insert deck;

List<Card__c> cards = [SELECT Id FROM Card__c];
List<PlayerCard__c> playerCards = new List<PlayerCard__c>();

for(Card__c card : cards) {
    playerCards.add(new PlayerCard__c(Player__c = deck.Player__c, Card__c = card.Id));
}
insert playerCards;

List<DeckCard__c> deckCards = new List<DeckCard__c>();
for(PlayerCard__c playerCard : playerCards) {
    deckCards.add(new DeckCard__c(PlayerCard__c = playerCard.Id, Deck__c = deck.ID));
}
insert deckCards;

Contact player = new Contact(Id=deck.Player__c);
player.SelectedDeck__c = deck.Id;
update player;
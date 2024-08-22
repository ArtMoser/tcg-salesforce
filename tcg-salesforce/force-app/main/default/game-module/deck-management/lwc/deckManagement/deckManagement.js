import { LightningElement, track, api } from 'lwc';

import getPlayerCards from '@salesforce/apex/DeckManagementController.getPlayerCards';
import getPlayerDecks from '@salesforce/apex/DeckManagementController.getPlayerDecks';

export default class DeckManagement extends LightningElement {
    @api playerLoginCode;
    @track playerCards = [];
    @track playerDecks = [];
    @track removedDeckCards = [];
    @track currentDeck = {};
    

    async connectedCallback() {
        try {
            this.playerCards = await getPlayerCards({playerLoginCode: this.playerLoginCode});
            this.playerDecks = await getPlayerDecks({playerLoginCode: this.playerLoginCode});
            this.setCurrentDeck();
        } catch (error) {
            console.error('Error fetching greeting:', error);
        }
    }

    setCurrentDeck() {
        if(this.playerDecks.length == 0) { return; }

        let deckId = '';
        let localPlayerDecks = [...this.playerDecks];

        for(let deck of localPlayerDecks) {
            deck.isSelected = true;
            deckId = deck.Id;
            break;
        }

        this.playerDecks = localPlayerDecks;
        this.markSelectedCards(deckId);
    }

    markSelectedCards(deckId) {
        this.removedDeckCards = [];
        let localPlayerCards = [...this.playerCards];
        localPlayerCards = this.unselectAllCards(localPlayerCards);
        let deckCardsById = this.getCurrentDeckCards(deckId);
        
        for(let playerCard of localPlayerCards) {
            let deckCard = deckCardsById[playerCard.Id];
            if(deckCard) {
                playerCard.isSelected = true;
            }
        }

        this.playerCards = localPlayerCards;
    }

    unselectAllCards(playerCards) {
        for(let playerCard of playerCards) {
            playerCard.isDeleted = false;
            playerCard.isSelected = false;
        }

        return playerCards;
    }

    getCurrentDeckCards(deckId) {
        let deckCardsMapById = {};

        for(let playerDeck of this.playerDecks) {
            if(playerDeck.Id != deckId) { continue; }

            for(let deckCard of playerDeck.DeckCards__r) {
                deckCardsMapById[deckCard.PlayerCard__c] = deckCard.PlayerCard__c;
            }
            break;
        }

        return deckCardsMapById;
    }

    toggleCardSelection(event) {
        const selectedPlayerCardId = event.target.getAttribute('data-id');

        let localPlayerCards = [...this.playerCards];

        for(let playerCard of localPlayerCards) {
            if(playerCard.Id == selectedPlayerCardId) {
                playerCard.isSelected = !playerCard.isSelected;

                if(!playerCard.isSelected) {
                    playerCard.isDeleted = true;
                }

                if(playerCard.isSelected) {
                    playerCard.isDeleted = false;
                }

                break;
            }

            this.playerCards = localPlayerCards;
        }
    }
}
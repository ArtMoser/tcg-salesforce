import { LightningElement, track, api } from 'lwc';

import getPlayerCards from '@salesforce/apex/DeckManagementController.getPlayerCards';
import getPlayerDecks from '@salesforce/apex/DeckManagementController.getPlayerDecks';
import updateDeckCards from '@salesforce/apex/DeckManagementController.updateDeckCards';

export default class DeckManagement extends LightningElement {
    @api playerLoginCode;
    @track playerCards = [];
    @track playerDecks = [];
    @track removedDeckCards = [];
    @track currentDeck = {};

    connectedCallback() {
        this.initDeckManagement();
    }

    async initDeckManagement() {
        try {
            this.playerCards = await getPlayerCards({playerLoginCode: this.playerLoginCode});
            this.playerDecks = await getPlayerDecks({playerLoginCode: this.playerLoginCode});
            this.setCurrentDeck(null);
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    }

    setCurrentDeck(deckSelectedId) {
        if(this.playerDecks.length == 0) { return; }

        let deckId = '';
        let localPlayerDecks = [...this.playerDecks];

        localPlayerDecks = this.unselectAllDecks(localPlayerDecks);

        for(let deck of localPlayerDecks) {
            if(!deckSelectedId) {
                deck.isSelected = true;
                deckId = deck.Id;
                this.currentDeck = deck;
                break;
            }

            if(deck.Id == deckSelectedId) {
                this.currentDeck = deck;
                deck.isSelected = true;
                deckId = deckSelectedId;
                break;
            }
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
                playerCard.initialState = 'selected';
                playerCard.isSelected = true;
            } else {
                playerCard.initialState = 'unselected';
            }
        }

        this.playerCards = localPlayerCards;
    }

    unselectAllDecks(playerDecks) {
        for(let playerDeck of playerDecks) {
            playerDeck.isDeleted = false;
            playerDeck.isSelected = false;
        }

        return playerDecks;
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

    handleSaveDeckModifications() {
        let deckCardsToRemove = this.generateDeckUpdateObject(this.currentDeck.Id, this.getRemovedDeckCards());
        let deckCardsToAdd = this.generateDeckUpdateObject(this.currentDeck.Id, this.getAddedDeckCards());

        updateDeckCards({ 
                        deckCardsToRemove : deckCardsToRemove, 
                        deckCardsToAdd : deckCardsToAdd 
                    })
        .then(response => {
            this.initDeckManagement();
        })
        .catch(error => {
            console.log(error)
        });
    }

    getRemovedDeckCards() {
        let removedPlayerCardsFromDeck = [];

        for(let playerCard of this.playerCards) {
            if(playerCard.Id && playerCard.isDeleted) {
                removedPlayerCardsFromDeck.push(playerCard);
            }
        }

        return removedPlayerCardsFromDeck;
    }

    getAddedDeckCards() {
        let addedPlayerCardsToDeck = [];

        for(let playerCard of this.playerCards) {
            if(playerCard.initialState == 'unselected' && playerCard.isSelected) {
                addedPlayerCardsToDeck.push(playerCard);
            }
        }

        return addedPlayerCardsToDeck;
    }

    generateDeckUpdateObject(deckId, playerCardsToUpdate) {
        let deckUpdateObject = {
            deckId: deckId,
            playerCardIds: []
        }

        for(let playerCard of playerCardsToUpdate) {
            deckUpdateObject.playerCardIds.push(playerCard.Id);
        }

        return deckUpdateObject;
    }

    handleCancelDeckModifications() {
        this.initDeckManagement();
    }
}
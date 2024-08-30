import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAllMatchData from '@salesforce/apex/MatchManagementController.getAllMatchData';
import upadateRowCard from '@salesforce/apex/MatchManagementController.upadateRowCard';

export default class MatchManagement extends LightningElement {
    @api playerLoginCode = '123';
    @track player = {};
    @track match = {};
    @track playerDeckCards = [];
    @track rowCards = [];
    @track matchCemetery = [];
    @track subscription = {};
    @track playersHands = [];
    @track canPlay = false;
    @track hideEnemyCards = true;

    @track actualPlayerHand = [];
    @track enemyPlayerHand = [];
    @track actualPlayerRowCards = [];
    @track enemyPlayerRowCards = [];
    @track effectCardsSet = 0;
    @track turn = 0;
    @track availableEnergy = 0;

    @track selectedDeckCardId = '';

    channelName = '/event/MatchUpdate__e';

    connectedCallback() {
        this.initMatchManagement();
        this.registerSubscribe();        
    }

    registerSubscribe() {
        const messageCallback = (response) => {
            this.initMatchManagement();
            console.log('New message received: ', JSON.stringify(response));
        }

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log(JSON.stringify(response.channel));
        })
    }

    async initMatchManagement() {
        let matchData = await getAllMatchData({playerLoginCode : this.playerLoginCode, matchId : this.match.Id});
        this.match = matchData.match;
        this.player = matchData.player;
        this.playerDeckCards = matchData.deckCards;
        this.playersHands = matchData.playersHands;
        this.rowCards = matchData.rowCards;
        this.matchCemetery = matchData.matchCemetery;

        if(this.turn != this.match.Turn__c) {
            this.effectCardsSet = 0;
            this.turn = this.match.Turn__c;
        }

        this.actualPlayerHand = [];
        this.enemyPlayerHand = [];
        this.actualPlayerRowCards = [];
        this.enemyPlayerRowCards = [];
        this.availableEnergy = 0;

        this.setPlayerCards();
        this.setPlayersRowCards();
        this.setCanPlay();
        this.setAvailableEnergy();

        //TODO: When a card is clicked, highlighted it and the spaces on field that it's possible to set
        //TODO: Implement the card Attack to other card
        //TODO: Implement the card direct attck
        //TODO: Implement a logic to identify turn change
    }

    setPlayerCards() {
        for(let handItem of this.playersHands) {
            if(handItem.ContactPlayerHand__r.LoginCode__c == this.player.LoginCode__c) {
                this.actualPlayerHand.push(handItem);
                continue;
            }
            this.enemyPlayerHand.push(handItem);
        }
    }

    setAvailableEnergy() {
        for(let card of this.actualPlayerRowCards) {
            if(card.isEnergy && card.Deckcard__c) {
                this.availableEnergy += 1;
            }
        }
    }

    setPlayersRowCards() {
        for(let rowCard of this.rowCards) {
            rowCard.isEnergy = rowCard.BattlefieldRow__r.Category__c == 'Effect' ? true : false;
            rowCard.hasCard = rowCard.Deckcard__c != null && rowCard.Deckcard__c != undefined;

            if(rowCard.BattlefieldRow__r.Player__r.LoginCode__c == this.player.LoginCode__c) {
                this.actualPlayerRowCards.push(rowCard);
                continue;
            }
            this.enemyPlayerRowCards.push(rowCard);
        }
    }

    setCanPlay() {
        let firstPlayerToPlay = this.identifyPlayer();
        if(firstPlayerToPlay && this.match.Turn__c == 0 || 
            (firstPlayerToPlay && this.match.Turn__c > 0 && !this.identfyTurnIsOdd()) || 
            !firstPlayerToPlay && this.identfyTurnIsOdd()) {
            this.canPlay = true;
        }
    }

    identfyTurnIsOdd() {
        return this.match.Turn__c % 2 !== 0;
    }

    identifyPlayer() {
        if(this.player.playerLoginCode == this.match.PlayerOne__r.LoginCode__c) {
            return true;
        }
        return false;
    }

    drawPlayerCards() {
        if(this.playerDeckCards.length > 0) {
            this.generatePlayerHand(this.playerDeckCards[0]);
            this.PlayerHand(playerHand);
            this.playerDeckCards = this.playerDeckCards.shift();
        }
    }

    generatePlayerHand(deckCard) {
        let playerHand = {
            MatchPlayerHand__c: this.match.Id,
            ContactPlayerHand__c: this.player.Id,
            DeckCard__c: deckCard.Id
        };

        let playerHands = [];
        playerHands.push(playerHand);
        this.playersHands.push(playerHand);

        savePlayerHand({playerHand})
        .then(response => {
            console.log(response);
        })
        .catch(error => {
            console.log(error);
        });
    }

    generateEvent() {

    }

    setSelectedCard(event) {
        let energyCost = event.currentTarget.dataset.energy;
        let type = event.currentTarget.dataset.type;

        if(type == 'Monster' && parseInt(energyCost) > this.availableEnergy) {
            this.showToast('You do not have enough energy to use this card');
            return;
        }

        this.selectedDeckCardId = event.currentTarget.dataset.id;
    }

    setCardOnEffectSpot(event) {
        let selectedSpot = event.currentTarget.dataset.id;

        if(!this.selectedDeckCardId) {
            return;
        }

        if(this.effectCardsSet > 0) {
            this.showToast('You can only set 1 effect card per turn');
            return;
        }

        if(this.checkCardOnHandType('Energy')) {
            this.sendSpotUpdatedToSalesforce(selectedSpot);
            this.effectCardsSet += 1;
            return;
        }

        this.showToast('You cannot put an creature card on a effect card spot');
    }

    setCardOnCreatureSpot(event) {
        let selectedSpot = event.currentTarget.dataset.id;

        if(!this.selectedDeckCardId) {
            return;
        }

        if(this.checkCardOnHandType('Monster')) {
            this.sendSpotUpdatedToSalesforce(selectedSpot);
            return;
        }

        this.showToast('You cannot put an effect card on a creature card spot');
    }

    async sendSpotUpdatedToSalesforce(rowCardId) {
        let rowCardUpdated = {
            Id: rowCardId,
            Deckcard__c: this.selectedDeckCardId
        };

        upadateRowCard({
            rowCardUpdated: rowCardUpdated,
            playerLoginCode: this.playerLoginCode,
            matchId: this.match.Id
        }).then(response => {
            console.log(response);
        })
        .catch(error => {
            console.log(error);
        });
    }

    checkCardOnHandType(typeToCompare) {
        for(let playerHand of this.actualPlayerHand) {
            if(playerHand.DeckCard__c == this.selectedDeckCardId) {
                if(playerHand.DeckCard__r.PlayerCard__r.Card__r.Type__c == typeToCompare) {
                    return true;
                }

                return false;
            }
        }
    }

    showToast(messageValue) {
        const event = new ShowToastEvent({
            title: 'Attention!',
            message: messageValue,
        });
        this.dispatchEvent(event);
    }
}
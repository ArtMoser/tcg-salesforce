import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

import getPlayer from '@salesforce/apex/MatchManagementController.getPlayer';
import getCurrentMatch from '@salesforce/apex/MatchManagementController.getCurrentMatch';
import getPlayerAvailableDeckCards from '@salesforce/apex/MatchManagementController.getCurrentMatch';
import savePlayerHand from '@salesforce/apex/MatchManagementController.savePlayerHand';
import getPlayersHands from '@salesforce/apex/MatchManagementController.getPlayersHands';
import getAllRowCards from '@salesforce/apex/MatchManagementController.getAllRowCards';
import getAllCemeteryCards from '@salesforce/apex/MatchManagementController.getAllCemeteryCards';

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

    channelName = '/data/Match__ChangeEvent';

    connectedCallback() {
        this.registerErrorListener();
        this.registerSubscribe();
        this.initMatchManagement();
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, () => console.log('Unsubscribed to change events.'));
    }

    async initMatchManagement() {
        this.match = await getCurrentMatch({playerLoginCode: this.playerLoginCode});
        this.player = await getPlayer({playerLoginCode: this.playerLoginCode});
        //Get current player Deck cards
        this.playerDeckCards = await getPlayerAvailableDeckCards({playerLoginCode : this.playerLoginCode, matchId : this.match.Id});
        //Get both player hands
        this.playersHands = await getPlayersHands({playerLoginCode : this.playerLoginCode, matchId : this.match.Id});
        //Get all Card Rows
        this.rowCards = await getAllRowCards({matchId : this.match.Id});
        //Get Cemetery
        this.matchCemetery = await getAllCemeteryCards({matchId : this.match.Id});

        this.setPlayerCards();
        this.setPlayersRowCards();
        this.setCanPlay();

        //TODO: Implement a logic to identify turn change
        //TODO: Implement validations to check if is the player turn
        //TODO: When a card is clicked, highlighted it and the spaces on field that it's possible to set
        //TODO: Implement the card set on the field
        //TODO: Implement the card Attack to other card
        //TODO: Implement the card direct attck
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

    registerSubscribe() {
        const messageCallback = (message) => {
            this.handleMessage(message);
        };
        subscribe(this.channelName, messageCallback);
        this.messageCallback = messageCallback;
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

    registerErrorListener() {
        onError(error => {
            console.error('Salesforce error', JSON.stringify(error));
        });
    }

    registerSubscribe() {
        const changeEventCallback = changeEvent => {
            this.processChangeEvent(changeEvent);
        };

        subscribe(this.channelName, -1, changeEventCallback).then(subscription => {
            this.subscription = subscription;
        });
    }

    processChangeEvent(changeEvent) {
        try {
            //TODO: Implement event changes
            //this.drawPlayerCards();
        } catch (err) {
            console.error(err);
        }
    }
}
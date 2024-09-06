import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAllMatchData from '@salesforce/apex/MatchManagementController.getAllMatchData';
import upadateRowCard from '@salesforce/apex/MatchManagementController.upadateRowCard';
import causeDirectDamage from '@salesforce/apex/MatchManagementController.causeDirectDamage';
import destroyEnemyCardAndCauseDirectDamage from '@salesforce/apex/MatchManagementController.destroyEnemyCardAndCauseDirectDamage';
import destroyPlayerCard from '@salesforce/apex/MatchManagementController.destroyPlayerCard';
import destroyPlayerAndEnemyCard from '@salesforce/apex/MatchManagementController.destroyPlayerAndEnemyCard';
import endTurn from '@salesforce/apex/MatchManagementController.endTurn';
import finishMatch from '@salesforce/apex/MatchManagementController.finishMatch';

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
    @track actualPlayerName = '';
    @track enemyPlayerName = '';;
    @track lifePointsActualPlayer = 20;
    @track lifePointsenemyPlayer = 20;

    @track actualPlayerHand = [];
    @track enemyPlayerHand = [];
    @track actualPlayerRowCards = [];
    @track enemyPlayerRowCards = [];
    @track effectCardsSet = 0;
    @track turn = 0;
    @track availableEnergy = 0;

    @track selectedDeckCardId = '';
    @track selectedActDeckCardId = '';
    @track selectedTargetCard = '';
    @track enableDirectAttack = false;
    @track showWinnerModal = false;
    @track isWinner = false;
    @track disableButton = false;
    @track cardsThatActed = [];
    @track matchLog = [];

    @track hightlightEnergyRow = false;
    @track hightlightCreatureRow = false;
    @track hightlightEnemyCreatureRow = false;

    channelName = '/event/MatchUpdate__e';

    connectedCallback() {
        this.initMatchManagement();
        this.registerSubscribe();
    }

    registerSubscribe() {
        const messageCallback = (response) => {
            if(response.data.payload.MatchId__c == this.match.Id) {
            this.initMatchManagement();
            }
            console.log('New message received: ', JSON.stringify(response));
        }

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log(JSON.stringify(response.channel));
        })
    }

    async closeModal() {
        await finishMatch({matchId : this.match.Id});
        this.dispatchEvent(new CustomEvent('matchnotexistevent'));
    }

    async initMatchManagement() {
        let matchData = await getAllMatchData({playerLoginCode : this.playerLoginCode, matchId : this.match.Id});

        if(!matchData.match) {
            this.dispatchEvent(new CustomEvent('matchnotexistevent'));
        }

        this.match = matchData.match;
        this.player = matchData.player;
        this.playerDeckCards = matchData.deckCards;

        for(let playerCardHand of matchData.playersHands) {
            playerCardHand.isSelected = false;
        }

        this.playersHands = matchData.playersHands;
        this.rowCards = matchData.rowCards;
        this.matchCemetery = matchData.matchCemetery;

        if(this.player.Id == this.match.PlayerOne__c) {
            this.actualPlayerName = this.match.PlayerOne__r.Name;    
            this.enemyPlayerName = this.match.PlayerTwo__r.Name;
            this.lifePointsActualPlayer = this.match.LifePointsPlayerOne__c;
            this.lifePointsenemyPlayer = this.match.LifePointsPlayerTwo__c;
        } else {
            this.actualPlayerName = this.match.PlayerTwo__r.Name;
            this.enemyPlayerName = this.match.PlayerOne__r.Name;
            this.lifePointsActualPlayer = this.match.LifePointsPlayerTwo__c;
            this.lifePointsenemyPlayer = this.match.LifePointsPlayerOne__c;
        }

        this.actualPlayerHand = [];
        this.enemyPlayerHand = [];
        this.actualPlayerRowCards = [];
        this.enemyPlayerRowCards = [];
        this.availableEnergy = 0;

        this.selectedTargetCard = '';
        this.enableDirectAttack = false;
        this.canPlay = false;
        this.disableButton = false;

        this.selectedDeckCardId= '';
        this.selectedActDeckCardId = '';
        this.removeAllHightlights();
        this.setPlayerCards();
        this.setPlayersRowCards();

        if(this.turn != this.match.Turn__c) {
            this.effectCardsSet = 0;
            this.turn = this.match.Turn__c;
            this.cardsThatActed = [];
        }

        this.setCanPlay();
        this.setAvailableEnergy();

        if(this.match.Winner__c != null) {
            this.showWinnerModal = true;
            if(this.match.Winner__c == this.player.Id) {
                this.isWinner = true;
            }
        }

        this.generateMatchLog();
    }

    generateMatchLog() {
        let logList = [];
        let matchEvents = this.match.MatchEvents__c.replace('null','');
        let messages = matchEvents.split('|');

        let counter = 0;
        for(let message of messages) {
            let eventSplitted = message.split(':');

            if(eventSplitted[0] == '') { continue; }
            if(eventSplitted.length == 2) {
                let userEvent = message.split(':')[0];
                let event = message.split(':')[1];
                let eventRecord = {
                    userEvent: userEvent,
                    event: event,
                    key: counter
                }
                logList.push(eventRecord);
            }  else {
                let eventRecord = {
                    userEvent: eventSplitted[0],
                    key: counter
                }
                logList.push(eventRecord);
            }
            counter++
        }

        this.matchLog = logList.reverse();
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
        if(this.match.Turn__c != this.turn) {
            this.selectedActDeckCardId = '';
        }

        for(let rowCard of this.rowCards) {
            rowCard.isEnergy = rowCard.BattlefieldRow__r.Category__c == 'Effect' ? true : false;
            rowCard.hasCard = rowCard.Deckcard__c != null && rowCard.Deckcard__c != undefined;

            if(rowCard.BattlefieldRow__r.Player__r.LoginCode__c == this.player.LoginCode__c) {
                if(this.match.Turn__c == this.turn && rowCard.Deckcard__c == this.selectedActDeckCardId) {
                    rowCard.alreadyAttacked = true;
                    this.cardsThatActed.push(rowCard.Deckcard__c);
                }

                this.actualPlayerRowCards.push(rowCard);
                continue;
            }
            this.enemyPlayerRowCards.push(rowCard);
        }
    }

    setCanPlay() {
        let firstPlayerToPlay = this.identifyPlayer();
        if((firstPlayerToPlay && !this.identfyTurnIsOdd()) || 
            !firstPlayerToPlay && this.identfyTurnIsOdd()) {
            this.canPlay = true;
        } else {
            this.canPlay = false;
        }
    }

    identfyTurnIsOdd() {
        return this.match.Turn__c % 2 !== 0;
    }

    identifyPlayer() {
        if(this.player.LoginCode__c == this.match.PlayerOne__r.LoginCode__c && this.match.StartingMatchPlayer__c == 'Player One') {
            return true;
        }

        if(this.player.LoginCode__c == this.match.PlayerTwo__r.LoginCode__c && this.match.StartingMatchPlayer__c == 'Player Two') {
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

    setSelectedTarget(event) {
        if(!this.canPlay) {
            return;
        }

        let deckCardId = event.currentTarget.dataset.id;
        let rowId = event.currentTarget.dataset.rowid;

        for(let rowCard of this.enemyPlayerRowCards) {
            if(rowCard.Id == rowId && deckCardId ) {
                if(this.selectedTargetCard == deckCardId) {
                    this.selectedTargetCard = '';
                    rowCard.isSelected = false;
                    break;
                }

                this.selectedTargetCard = deckCardId;
                rowCard.isSelected = true;

                if(!this.selectedActDeckCardId) {
                    break;
                }
                
                this.performAttackToMonster();
            }
        }
    }

    setSlectedCardToAct(event) {
        if(!this.canPlay) {
            return;
        }

        let deckCardId = event.currentTarget.dataset.id;
        let rowId = event.currentTarget.dataset.rowid;

        for(let rowCard of this.actualPlayerRowCards) {
            if(rowCard.Id == rowId && deckCardId) {
                if(!rowCard.alreadyAttacked && !this.cardsThatActed.includes(deckCardId)) {
                    if(this.cardsThatActed.includes(deckCardId)) {
                        this.showToast('This card already attacked this turn');
                        break;
                    }

                    if(this.selectedActDeckCardId == deckCardId) {
                        this.selectedActDeckCardId = '';
                        rowCard.isSelected = false;
                        this.hightlightEnemyCreatureRow = true;
                        break;
                    }

                    this.selectedActDeckCardId = deckCardId;
                    rowCard.isSelected = true;

                    this.hightlightEnemyCreatureRow = true;
                    /*if(this.selectedTargetCard) {
                        this.performAttackToMonster();
                        break;
                    }*/

                    this.checkEnableDirectAttack();
                    break;
                } else {
                    this.showToast('This card already attacked this turn');
                    break;
                }
            }
        }
    }

    performAttackToMonster() {
        let actualPlayerAttackCard;
        let enemyPlayerTargetCard;

        for(let rowCard of this.actualPlayerRowCards) {
            if(rowCard.Deckcard__c == this.selectedActDeckCardId) {
                actualPlayerAttackCard = rowCard.Deckcard__r.PlayerCard__r.Card__r;
                break;
            }
        }

        for(let rowCard of this.enemyPlayerRowCards) {
            if(rowCard.Deckcard__c == this.selectedTargetCard) {
                enemyPlayerTargetCard = rowCard.Deckcard__r.PlayerCard__r.Card__r;
                break;
            }
        }

        this.cardsThatActed.push(this.selectedActDeckCardId);

        if(actualPlayerAttackCard.Attack__c > enemyPlayerTargetCard.Defense__c) {
            destroyEnemyCardAndCauseDirectDamage({
                playerLoginCode: this.playerLoginCode,
                damage: (actualPlayerAttackCard.Attack__c - enemyPlayerTargetCard.Defense__c),
                enemyDeckCardIdToDestroy: this.selectedTargetCard,
                matchId: this.match.Id
            }).then(response => {
                console.log(response);
            })
            .catch(error => {
                console.log(error);
            });
        } else if(enemyPlayerTargetCard.Defense__c > actualPlayerAttackCard.Attack__c) {
            destroyPlayerCard({
                playerLoginCode: this.playerLoginCode,
                playerDeckCardIdToDestroy: this.selectedActDeckCardId,
                matchId: this.match.Id
            }).then(response => {
                console.log(response);
            })
            .catch(error => {
                console.log(error);
            });
        } else {
            destroyPlayerAndEnemyCard({
                playerLoginCode: this.playerLoginCode,
                playerDeckCardIdToDestroy: this.selectedActDeckCardId,
                enemyDeckCardIdToDestroy: this.selectedTargetCard,
                matchId: this.match.Id
            }).then(response => {
                console.log(response);
            })
            .catch(error => {
                console.log(error);
            });
        }
    }

    checkEnableDirectAttack() {
        for(let enemyRowCard of this.enemyPlayerRowCards) {
            if(enemyRowCard.BattlefieldRow__r.Category__c == 'Creature' && enemyRowCard.Deckcard__c) {
                this.enableDirectAttack = false;
                this.showToast('Select which opponent card will be attacked');
                return;
            }
        }

        this.enableDirectAttack = true;
    }

    handleDirectAttack() {
        let damage = 0;
        for(let rowCard of this.actualPlayerRowCards) {
            if(rowCard.Deckcard__c == this.selectedActDeckCardId) {
                rowCard.alreadyAttacked = true;
                this.cardsThatActed.push(rowCard.Deckcard__c);
                damage += rowCard.Deckcard__r.PlayerCard__r.Card__r.Attack__c;
                break;
            }
        }

        causeDirectDamage({
                            damage : damage,
                            matchId : this.match.Id,
                            playerLoginCode : this.playerLoginCode
        }).then(response => {
            console.log(response);
        })
        .catch(error => {
            console.log(error);
        });

    }

    setSelectedCard(event) {
        if(!this.canPlay) {
            return;
        }

        let energyCost = event.currentTarget.dataset.energy;
        let type = event.currentTarget.dataset.type;

        if(type == 'Monster') {
            this.hightlightCreatureRow = true;
            this.hightlightEnergyRow = false;
        }

        if(type == 'Energy') {
            this.hightlightEnergyRow = true;
            this.hightlightCreatureRow = false;
        }

        if(type == 'Monster' && parseInt(energyCost) > this.availableEnergy) {
            this.showToast('You do not have enough energy to use this card');
            for(let playerCard of this.actualPlayerHand) {
                playerCard.isSelected = false;
            }
            return;
        }

        for(let playerCard of this.actualPlayerHand) {
            if(event.currentTarget.dataset.id == this.selectedDeckCardId) {
                playerCard.isSelected = false;
            }
        }

        this.selectedDeckCardId = event.currentTarget.dataset.id;

        for(let playerCard of this.actualPlayerHand) {
            if(playerCard.DeckCard__c == this.selectedDeckCardId) {
                playerCard.isSelected = true;
            } else {
                playerCard.isSelected = false;
            }
        }
    }

    setCardOnEffectSpot(event) {
        if(!this.canPlay) {
            return;
        }

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
        if(!this.canPlay) {
            return;
        }

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

    handleEndTurn() {
        this.disableButton = true;
        endTurn({
            playerLoginCode: this.playerLoginCode,
            matchId: this.match.Id
        }).then(response => {
            this.disableButton = false;
            console.log(response);
        })
        .catch(error => {
            console.log(error);
            this.disableButton = false;
        });
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

    removeAllHightlights() {
        this.hightlightEnergyRow = false;
        this.hightlightCreatureRow = false;
        this.hightlightEnemyCreatureRow = false;
    }

    get getPlayerFieldEnnergyRowClass() {
        return this.hightlightEnergyRow ? 'card-battlefield-position card-battlefield-position-player-highlighted' : 'card-battlefield-position card-battlefield-position-player';
    }

    get getPlayerFieldCreatureRowClass() {
        return this.hightlightCreatureRow ? 'card-battlefield-position card-battlefield-position-player-highlighted' : 'card-battlefield-position card-battlefield-position-player';
    }
}
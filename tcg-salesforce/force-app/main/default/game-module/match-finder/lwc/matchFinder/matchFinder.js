import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

import getAllWaitingMatches from '@salesforce/apex/MatchFinderController.getAllWaitingMatches';
import createMatch from '@salesforce/apex/MatchFinderController.createMatch';
import cancelMatch from '@salesforce/apex/MatchFinderController.cancelMatch';
import enterMatch from '@salesforce/apex/MatchFinderController.enterMatch';

export default class MatchFinder extends LightningElement {
    @api playerLoginCode = '';

    @track isModalOpen = false;
    @track isLoading = false;
    @track matches = [];
    @track generatedMatch = {};
    @track matchId = '';
    @track match = {};

    channelName = '/event/MatchStart__e';

    connectedCallback() {
        this.getMatches();
        this.registerSubscribe();
    }

    registerSubscribe() {
        const messageCallback = (response) => {
            if(response.data.payload.MatchId__c == this.matchId) {
                this.dispatchMatchStartEvent();
            }
        }

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log(JSON.stringify(response.channel));
        })
    }

    dispatchMatchStartEvent() {
        this.dispatchEvent(new CustomEvent('matchstartevent'));
    }

    async getMatches() {
        let matchData = await getAllWaitingMatches({playerLoginCode: this.playerLoginCode});

        if(matchData.match) {
            this.dispatchMatchStartEvent();
        }

        this.matches = matchData.matches;
        console.log(this.matches);
    }

    handleEnter(event) {
        this.isLoading = true;
        const recordId = event.target.dataset.id;
        this.matchId = recordId;

        enterMatch({
            matchId: this.matchId,
            playerLoginCode: this.playerLoginCode
        })
        .then(response => {
            this.isLoading = false;
        })
        .catch(error => {
            this.showToast('Error!', 'An error occured, try again later', 'error');
            console.log(error);
        });
    }

    handleRefresh() {
        this.getMatches();
    }

    handleCreate() {
        createMatch({
            playerLoginCode: this.playerLoginCode
        })
        .then(response => {
            this.match = response;
            this.matchId = response.Id;
            this.isModalOpen = true;
            console.log(response);
        })
        .catch(error => {
            this.showToast('Error!', 'An error occured, try again later', 'error');
            console.log(error);
        });
    }

    handleCancel() {
        cancelMatch({
            matchId: this.match.Id
        })
        .then(response => {
            this.isModalOpen = false;
            this.match = {};
            this.matchId = '';
            console.log(response);
        })
        .catch(error => {
            this.isModalOpen = false;
            this.match = {};
            this.showToast('Error!', 'An error occured, try again later', 'error');
            console.log(error);
        });
    }

    showToast(title, messageValue, type) {
        const event = new ShowToastEvent({
            variant: type,
            title: title,
            message: messageValue,
        });
        this.dispatchEvent(event);
    }
}
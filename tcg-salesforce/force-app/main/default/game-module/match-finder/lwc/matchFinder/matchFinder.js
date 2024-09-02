import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAllWaitingMatches from '@salesforce/apex/MatchFinderController.getAllWaitingMatches';
import createMatch from '@salesforce/apex/MatchFinderController.createMatch';
import cancelMatch from '@salesforce/apex/MatchFinderController.cancelMatch';

export default class MatchFinder extends LightningElement {
    @api playerLoginCode = '';

    @track isModalOpen = false;
    @track matches = [];
    @track generatedMatch = {};

    connectedCallback() {
        this.getMatches();
    }

    async getMatches() {
        this.matches = await getAllWaitingMatches();
        console.log(this.matches);
    }

    handleEnter(event) {
        const recordId = event.target.dataset.id;
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
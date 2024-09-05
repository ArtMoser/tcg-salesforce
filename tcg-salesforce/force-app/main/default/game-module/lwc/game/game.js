import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import login from '@salesforce/apex/MatchManagementController.login';

export default class Game extends LightningElement {
    @track playerLoginCode = '';
    @track showLoginScreen = true;
    @track showMatchesScreen = false;
    @track showPlayScreen = false;

    connectedCallback() {
        this.defineNextScreen();
    }

    defineNextScreen() {
        if(this.playerLoginCode) {
            this.handleShowScreen(false, true, false);
            return;
        }

        this.handleShowScreen(true, false, false);
    }

    handleShowScreen(showLoginScree, showMatchesScreen, showPlayScreen) {
        this.showLoginScreen = showLoginScree;
        this.showMatchesScreen = showMatchesScreen;
        this.showPlayScreen = showPlayScreen;
    }

    handleCodeChange(event) {
        this.playerLoginCode = event.target.value;
    }

    handleLogin() {
        if(!this.playerLoginCode) {
            this.showToast('Login code missing', 'You must type the login code to access', 'error');
            return;
        }

        login({
            playerLoginCode: this.playerLoginCode
        }).then(response => {
            if(response.successfulLogin) {
                if(!response.match) {
                    this.handleShowScreen(false, false, true);
                    return;
                }

                this.handleShowScreen(false, true, false);
            } else {
                this.showToast('User not found!', 'Verify if your code is correct', 'error');
                this.playerLoginCode = '';
            }
        })
        .catch(error => {
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

    redirectStartMatch() {
        this.handleShowScreen(false, false, true);
    }

    redirectMatchesScreen() {
        this.handleShowScreen(false, true, false);
    }
}
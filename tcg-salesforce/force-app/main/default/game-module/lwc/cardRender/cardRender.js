import { LightningElement, api, track } from 'lwc';

export default class CardRender extends LightningElement {
    @api cardData = {};
    @api hideCard = false;

    @track attack = 0;
    @track defense = 0;
    @track name = '';
    @track description = '';
    @track imageUrl = '';
    @track rarity = '';
    @track type = '';
    @track energyCost = 0;
    @track backgroundColor = '#bbb';

    @track isEnergyCard = false;

    connectedCallback() {
        this.attack = this.cardData.Attack__c;
        this.defense = this.cardData.Defense__c;
        this.name = this.cardData.Name;
        this.description = this.cardData.Description__c;
        this.imageUrl = this.cardData.Image__c;
        this.rarity = this.cardData.Rarity__c;
        this.type = this.cardData.Type__c;
        this.energyCost = this.cardData.EnergyCost__c;
        this.isEnergyCard = this.type == 'Energy';
        this.backgroundColor = this.cardData.RarityColor__c;
    }

    get getBackgroundColor() {
        return `background-color:${this.backgroundColor}`;
    }
}
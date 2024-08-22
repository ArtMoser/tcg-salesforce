import { LightningElement, api, track } from 'lwc';

export default class CardRender extends LightningElement {
    @api attack = 0;
    @api defense = 0;
    @api name = '';
    @api description = '';
    @api imageUrl = '';
    @api rarity = '';
    @api type = '';
    @api energyCost = 0;

    @track isEnergyCard = false;

    connectedCallback() {
        this.isEnergyCard = this.type == 'Energy';
    }
}
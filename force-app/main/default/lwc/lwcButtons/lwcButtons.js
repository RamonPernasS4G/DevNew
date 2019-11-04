/**
 * @File Name          : lwcButtons.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 31/10/2019 15:09:33
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    31/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement, api, wire, track } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import getButtons from '@salesforce/apex/LWCButtonsController.getButtons'; 

export default class lwcButtons extends LightningElement {

    @api screenName;
    @track metadataList;
    @api actionSelected;
    nextAction;

    @wire(getButtons, {screenName : '$screenName'})
    getButtons ({error, data}) {
        console.log('data', JSON.stringify(data));
        console.log('error', JSON.stringify(error));
        if (error) {
            // TODO: Error handling
        } else if (data) {
            // TODO: Data handling
            this.metadataList = data;
        }
    }

    handleButtonSelected(event){
        this.actionSelected = event.detail.clickAction;
        this.dispatchEvent(new FlowNavigationNextEvent());
    }
}
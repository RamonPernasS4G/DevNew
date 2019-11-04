/**
 * @File Name          : testButton.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 29/10/2019 15:41:32
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    29/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class testButton extends LightningElement {
    @api nextAction;

    handleNextAction(event){
        this.nextAction = '1';
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleNextActionTwo(event){
        this.nextAction = '2';
        this.dispatchEvent(new FlowNavigationNextEvent());
    }
}
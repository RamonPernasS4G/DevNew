/**
 * @File Name          : lwcButton.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 31/10/2019 14:42:15
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    31/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement, api } from 'lwc';

export default class lwcButton extends LightningElement {

    @api button;

    handleClick (event){
        this.dispatchEvent( new CustomEvent('buttonselected', {
            detail: {clickAction:this.button.Click_Action__c, nextAction:this.button.Next_Action__c}
          }));
    }
}
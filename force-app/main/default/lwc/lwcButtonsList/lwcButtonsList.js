/**
 * @File Name          : lwcButtonsList.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 31/10/2019 14:44:36
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    31/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement, api } from 'lwc';

export default class lwcButtonsList extends LightningElement {
    @api metadataList;

    handleButtonSelected(event){
        this.dispatchEvent(new CustomEvent('buttonselected', {detail:event.detail}));
    }
}
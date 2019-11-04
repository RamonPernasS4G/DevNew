/**
 * @File Name          : showPhone.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 10/10/2019 14:29:09
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement, api } from 'lwc';

export default class ShowPhone extends LightningElement {
    @api phone;

    handleDeletePhone(event){
        this.dispatchEvent(
            new CustomEvent('deletephone', {detail: {modstamp:this.phone.modstamp}})
        );
    }
}
/* eslint-disable no-console */
import { LightningElement, api, wire, track } from 'lwc';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
//import { reduceErrors } from 'c/s4GUtils';
import getSA from '@salesforce/apex/ListadoController.getSA';
 
export default class ListadoLWC extends LightningElement {

    @api recordList;
    @track loaded = false;

    @wire(getSA, {})
    wiredFieldSet({error,data}){
        if(data){
            // eslint-disable-next-line no-console
            console.log(JSON.stringify(data));
            this.recordList = data;
            this.loaded = true;
        } else if(error){
            console.log(JSON.stringify(error));
           // this.toastError('Error Wired Service Appointment', reduceErrors(error)[0]);
        }
    }
}
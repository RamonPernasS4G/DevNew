import { LightningElement,api,track} from 'lwc';
import getValue from '@salesforce/apex/DisplayRecordRelatedField.getValue';


export default class DisplayRecordRelatedField extends LightningElement {
    @api recordId;
    @api fieldToDisplay;
    @api objectApiName;
    @api title;

    @track fieldValue;
    
    connectedCallback(){
        console.log('Connected');
        getValue({recordId: this.recordId,fieldToDisplay:this.fieldToDisplay,objectApiName:this.objectApiName})
        .then(result => {
            console.log('' +result);
            this.fieldValue = result;
            
        })
        .catch(error => {
            console.log('' +error);
            this.error = error;
        });
    }

}
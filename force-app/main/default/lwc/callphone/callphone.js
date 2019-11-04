/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import createTask from '@salesforce/apex/CallPhonehelper.createTask';

const FIELDS = ['ServiceAppointment.Contact.Name','ServiceAppointment.Contact.Phone',
                'ServiceAppointment.Contact.MobilePhone','ServiceAppointment.Contact.HomePhone',
                'ServiceAppointment.Contact.OtherPhone','ServiceAppointment.Contact.AssistantPhone',];
 
export default class Callphone extends LightningElement {
    @api saId;
    @track Contact;
    @track contactId;
    @track name;
    @track contactPhones = [];

    @wire(getRecord, { recordId: '$saId', fields: FIELDS })
    wiredRecord({ data, error }) {
        if(data){
            
            //Seteamos el contacto relacionado a la cita
            this.Contact = data.fields.Contact.value.fields;
            this.contactId = data.fields.Contact.value.id;

            //Buscamos el nombre del contacto
            if(data.fields.Contact.displayValue){
                this.name = data.fields.Contact.displayValue;
            }

            //Buscamos los telefonos del contacto
            if(this.Contact.Phone.value){
                this.contactPhones.push({value: this.Contact.Phone.value});
            }
            if(this.Contact.MobilePhone.value){
                this.contactPhones.push({value: this.Contact.MobilePhone.value});
            }
            if(this.Contact.HomePhone.value){
                this.contactPhones.push({value: this.Contact.HomePhone.value});
            }
            if(this.Contact.OtherPhone.value){
                this.contactPhones.push({value: this.Contact.OtherPhone.value});
            }
            if(this.Contact.AssistantPhone.value){
                this.contactPhones.push({value: this.Contact.AssistantPhone.value});
            }
            
        }else if(error){
            let message = 'Error';
            if(Array.isArray(error.body)){
                message = error.body.map(e => e.message).join(', ');
            }else if(typeof error.body.message === 'string'){
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error al cargar los telefonos',
                    message,
                    variant: 'error',
                }),
            );
        }
    }

    phoneclick(event){
        const phoneCalled = new CustomEvent('callphone',  { detail: {}});
        this.dispatchEvent(phoneCalled);

        createTask({'serviceAppointmetId' : this.saId, 'contactId' : this.contactId, 'numero' : event.target.value})
        .then(result => {
            JSON.stringify('result = ' + result);
            console.log('Task created');
        })
        .catch(error => {
            JSON.stringify('error = ' + error);
            console.log('Task no created');
        });
    }
}
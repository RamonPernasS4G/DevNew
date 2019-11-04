/* eslint-disable no-console */
import { LightningElement, api, wire } from 'lwc';
import getSA from "@salesforce/apex/CitasHoyPOC.getSA";

 
export default class NavigationItemsPoc extends LightningElement {

    @api records;
    nombre;

    

    @wire(getSA, {})
    wiredGetSA({ error, data }) {
      //console.log(JSON.stringify(data));
      if (data) {
        this.records = data;
        this.nombre = 'Citas de hoy';
      } else if (error) {
        console.log("error", JSON.stringify(error));
      }
    }

    handleClick(event){
        console.log('handle click', JSON.stringify(event.detail));

        this.template.querySelector('c-navigate-to').navigateToListView('ServiceAppointment','00B5E000002L6FtUAK');
    }
    handleClickUrgentes(event){
        console.log('handle click', JSON.stringify(event.detail));

        this.template.querySelector('c-navigate-to').navigateToListView('ServiceAppointment','00B5E000002Kx6iUAC');
    }
    handleCSV(event){
        console.log('handleCSV', JSON.stringify(event.detail));

        this.template.querySelector('c-generar-c-s-v').handleGenerateCSV();
    }
    handleLLamadasHoy(event){
      console.log('handle click', JSON.stringify(event.detail));
      this.template.querySelector('c-navigate-to').navigateToListView('ServiceAppointment','00B5E000002L1v4UAC');
    }
}
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import getMarkers from '@salesforce/apex/ProfMapController.getMarkers';
import { reduceErrors } from 'c/s4GUtils';
// eslint-disable-next-line no-unused-vars
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
 
export default class ServiceAppointmentMap extends LightningElement {
    @track mapMarkers = [];
    @track filter = '';
    @track charged = false;
    @track timestamp = '';

    @wire(getMarkers, {filt : '$filter', timestamp : '$timestamp'})
    wiredMapMarkers({ error, data }) {
        //console.log(JSON.stringify(data));
        if (data) {
            console.log('data',JSON.stringify(data));
            this.mapMarkers = (data);
            this.charged = true;
            console.log('mapMarkers',JSON.stringify(this.mapMarkers));
        } else if (error) {
            console.log('error',JSON.stringify(error));
        }
    }

    // renderedCallback(){
    //     this.charged = false;
    //     this.timestamp = Date.now();
    //     getMarkers({filt : JSON.stringify(this.filter), timestamp : this.timestamp})
    //     .then(function(data){
    //         console.log(JSON.stringify(data));
    //         // this.mapMarkers = [];
    //         this.mapMarkers = data;
    //         this.charged = true;
    //     }).catch(function(error){
    //         console.log(JSON.stringify(error));
    //     });
    // }

    handleChange(event){
        this.filter = JSON.stringify(event.detail.record);
        console.log('IN PARENT ', JSON.stringify(this.filter));
        this.timestamp = Date.now();
        this.handleSearch();
    }

    handleSearch(){
        this.charged = false;
        
        /*getMarkers({filt : JSON.stringify(this.filter), timestamp : this.timestamp})
        .then(function(data){
            console.log(JSON.stringify(data));
            // this.mapMarkers = [];
            this.mapMarkers = data;
            this.charged = true;
        }).catch(function(error){
            console.log(JSON.stringify(error));
        });*/
    }
}
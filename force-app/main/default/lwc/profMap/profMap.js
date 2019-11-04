/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, wire, api, track } from 'lwc';

 
export default class ProfMap extends LightningElement {

    @api mapMarkers = [];
    @api charged = false;
    //Variables
    /*center = {
        location : {
            city : 'Madrid'
        }
    };*/
    @track zoomLevel = 10;
    @track markersTitle = '';
    @track showFooter = true;
    @track listView = 'visible';
}
import { LightningElement, api, track, wire } from 'lwc';

export default class FullCalendar extends LightningElement {
    @api workOrderId;
    @track showModal;

    handleShowModal(event){
        event.preventDefault();
        console.log('event detail', Jevent.detail);
        this.showModal = event.detail.show;
    }
}
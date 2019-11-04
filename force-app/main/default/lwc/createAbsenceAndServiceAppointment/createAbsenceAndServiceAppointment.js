import { LightningElement, api } from 'lwc';

export default class CreateAbsenceAndServiceAppointment extends LightningElement {

    @api workOrderId;
    
    get options() {
        return [
            { label: 'Ausencia', value: 'ResourceAbsence' },
            { label: 'Cita', value: 'ServiceAppointment' }
        ];
    }
}
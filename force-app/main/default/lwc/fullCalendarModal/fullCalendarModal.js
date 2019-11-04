import { LightningElement, api, track } from 'lwc';
import createObj from "@salesforce/apex/FullCalendarLWC.createObj";

export default class FullCalendarModal extends LightningElement {
    @api showModal = false;
    @api workOrderId;
    @api recordId = '';
    @api horaInicio = null;
    @api horaFin = null;
    @track description = '';
    @track loading = false;

    @api objToCreate = ''; 

    get objType(){
        return (this.objToCreate == 'ServiceAppointment') ? 'Crear una Cita de Servicio.' : 'Crear una Ausencia.';
    }

    handlerClose(event){
        this.dispatchEvent(new CustomEvent('closemodal', {}));
    }

    handlerSave(event){
        this.loading = true;
        //String workOrderId, String description, DateTime ini, DateTime fin
        let ini = new Date(this.horaInicio).getTime();
        let fin = new Date(this.horaFin).getTime();

        createObj({workOrderId:this.workOrderId, description:this.description, ini:ini, fin:fin, objType: this.objToCreate}).then(
            (data) => {  
                console.log('data creado ',data);
                console.log('this.loading',this.loading);
                //pasar los datos en el data y devolverlo en el evento, una vez el evento esté creado se hace un .fullCalendar( 'renderEvent', newEvent ); newEvent es el evento a añadir
                this.loading = false;
                this.dispatchEvent(new CustomEvent('eventcreated', {detail : {record : data}}));
            }
        ).catch((error) => {
            alert('error ' + JSON.stringify(error));
            this.loading = false;
        });
    }
    handleKeyUp(event){
        const field = event.target.name;

        if(field === 'Fecha de inicio'){
            this.horaInicio = event.detail.value;
        }else if (field === 'Fecha de fin') {
            this.horaFin = event.detail.value;
        }else if (field === 'Descripción') {
            this.description = event.detail.value;
        }
    }
}
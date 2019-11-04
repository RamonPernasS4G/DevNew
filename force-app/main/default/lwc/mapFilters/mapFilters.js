import { LightningElement, track, wire} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SA_OBJECT from '@salesforce/schema/ServiceAppointment';
import GREMIO from '@salesforce/schema/ServiceAppointment.Gremio__c';
 
export default class MapFilters extends LightningElement {

    @track searchLabel = 'Buscar';
    @track searchIconName = 'utility:search';
    @track filter = {
        'Urgente': null,
        'Gremio' : null,
        'Desde' : null,
        'Hasta' : null
    };
    @track comboValue = '';

    @wire(getObjectInfo, { objectApiName: SA_OBJECT })
    objectInfo;


    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: GREMIO})
    GremioPicklistValues;

    handleSearch(event){
        console.log('Filter',JSON.stringify(this.filter));
        this.dispatchEvent( new CustomEvent('filterchange', {detail: {record:this.filter}}));
    }
    handleChange(event){
        const field = event.target.name;
        console.log('field', field);
        console.log('detail',JSON.stringify(event.detail));
        console.log('target',JSON.stringify(event.target));
        if(field === 'filtro.Urgente'){
            this.filter.Urgente = event.detail.checked;
        }else if (field === 'filtro.Desde') {
            this.filter.Desde = event.detail.value;
        }else if (field === 'filtro.Hasta') {
            this.filter.Hasta = event.detail.value;
        }
    }
    handleChangeCombo(event){
        this.comboValue = event.detail.value;
        this.filter.Gremio = this.comboValue;
    }
}
/**
 * @File Name          : danosPerjudicados.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 29/10/2019 10:02:15
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement, track } from 'lwc';
 
export default class DanosPerjudicados extends LightningElement {

    @track typeTel = '';
    @track numTel = '';
    @track sinceTel;
    @track untilTel;
    @track smsValue = false;

    @track showCompania = false;
    @track showPerjudicado = false;

    @track showDates = false;

    @track phonesList = [];

    @track show = false;

    phoneTypes = [{ label: 'Fijo', value: 'Fijo' }
                    ,{ label: 'Móvil', value: 'Móvil' }
                        ,{ label: 'Otro', value: 'Otro' }];

    perjudicadoCombo = [
        { label: 'Inquilino', value: 'Inquilino' }
        ,{ label: 'Vecino', value: 'Vecino' }
    ];
    terceroCombo = [
        { label: 'Causante', value: 'Causante' }
        ,{ label: 'Perjudicado', value: 'Perjudicado' }
    ];
    companiaCombo = [
        { label: 'Compañia 1', value: 'Compañia 1'}
        ,{ label: 'Compañia 2', value: 'Compañia 2'}
        ,{ label: 'Compañia 3', value: 'Compañia 3'}
    ];
    tipoCombo = [
        { label: 'DNI', value: 'DNI' } 
        ,{ label: 'NIE', value: 'NIE' }
        ,{ label: 'CIF', value: 'CIF' }
    ];
    @track telefonoCombo = this.phoneTypes;

    danosCombo = [ 
        { label: 'Techo', value: 'Techo' }
        ,{ label: 'Pared', value: 'Pared' }
        ,{ label: 'Puerta', value: 'Puerta' }
        ,{ label: 'Mobiliario', value: 'Mobiliario' }
        ,{ label: 'Otros daños', value: 'Otros daños' }
    ];

    @track danosValue = '';

    ayuda = "Ésto es un texto de ayuda.";

    handleTelefonoChange(event){

        const field = event.target.name;
        const value = event.detail.value;
        const checked = event.detail.checked;

        console.log('field', field);

        switch(field){
            case "Tipo teléfono" : this.typeTel = value; this.showDates = true; break;
            case "Num teléfono" : this.numTel = value; break;
            case "Hora desde" : this.sinceTel = value; break;
            case "Hora hasta" : this.untilTel = value; break;
            case "SMS" : this.smsValue = checked; break;
            default: break;
        }
        console.log('smsValue',this.smsValue);
    }
    handleAddPhone(event){

        let phone = this.createPhone();
        let pTypes = [];
        //si meto 2 solo se quita 1
        this.telefonoCombo.forEach(phoneType => {
            if(phoneType.value != this.typeTel){
                pTypes.push(phoneType);
            }
        });
        this.telefonoCombo = pTypes;
        this.phonesList.push(phone);
        this.cleanPhone();
        this.show = true;
    }

    createPhone(){
        let d = new Date();
        let phone = {
            typeTel : this.typeTel
            ,numTel : this.numTel
            ,sinceTel : this.sinceTel
            ,untilTel : this.untilTel
            ,modstamp : d.getTime()
            ,smsValue : this.smsValue
        };
        console.log('phone',JSON.stringify(phone));
        return phone;
    }

    cleanPhone(){
        this.typeTel = '';
        this.numTel = '';
        this.sinceTel = null;
        this.untilTel = null;
        this.smsValue = false;
    }

    handleDeletePhone(event){
        //Comproba por que no se añaden
        const mods = event.detail.modstamp;
        let phone = this.phonesList.find(element => {
            return element.modstamp == mods;
        });
    
        this.phonesList = this.phonesList.filter(item => item !== phone);
        let pTypes = [];
        //si meto 2 solo se quita 1
        this.telefonoCombo.forEach(phoneType => {
            pTypes.push(phoneType);
        });
        //quizas tenga que crear una nueva y añadir
        pTypes.push({value:phone.typeTel,label:phone.typeTel});

        this.telefonoCombo = pTypes;
        this.show = this.phonesList.length > 0;
    }

    handleTercero(event){
        //const field = event.target.name;
        const value = event.detail.value;

        if(value === 'Causante'){
            this.showCompania = true;
            this.showPerjudicado = false;           
        }else{

            this.showPerjudicado = true;
            this.showCompania = false;
        }
    }

    handleRelatedList(event){
    //@api navigateToRelatedList(recordId, objName, relationName, actionName) {

        this.template.querySelector('c-navigate-to').navigateToRelatedList('0035E00000v9dzmQAA','Contact', 'Terceros_Perjudicados__r', 'view');
    }
    handleRecord(event){
        this.template.querySelector('c-navigate-to').navigateToRecordViewPage('0035E00000v9dzmQAA','Contact', 'view');
    }
}
/* eslint-disable no-console */
import { LightningElement,api } from 'lwc';
 
export default class ConfirmacionGarantias extends LightningElement {

    @api showDanosPropios = false;
    @api showDanos = false;
    @api grupoSelected;
    @api tipoAveriaSelected;
    @api detalleAveriaSelected;
    @api causaAveriaSelected;
    @api perjudicadosSelected = false;
    @api showMotivosperito = false;
    @api peritoCheck = false;

    @api grupos = [
        {label: 'Agua', value: 'Agua'},
        {label: 'Eléctricos', value: 'Electricos'},
        {label: 'Incendio', value: 'Incendio'},
        {label: 'Otras contingencias', value: 'Otras'},
        {label: 'RC', value: 'RC'},
        {label: 'Robo', value: 'Robo'}
    ];
    @api tipos = [
        {label: 'Rotura Tubería', value: 'roturaTuberia'},
        {label: 'Averia enchufe', value: 'averiaEnchufe'},
        {label: 'Incendio electrodomestico', value: 'incendioElectrodomestico'}
    ];
    @api detalles = [
        {label: 'Tubería empotrada', value: 'tuberiaEmpotrada'},
        {label: 'Tubería vista', value: 'tuberíaVista'},
        {label: 'Atasco', value: 'atasco'}
    ];
    @api causas = [
        {label: 'Mantenimiento', value: 'mantenimiento'},
        {label: 'Fuerte presión', value: 'fuertePresion'},
        {label: 'Tercero causante', value: 'terceroCausante'}
    ];
    @api danosPropios = [
        {label: 'Mueble', value: 'mueble'},
        {label: 'Televisión', value: 'television'},
        {label: 'Pared', value: 'pared'}
    ];
    @api motivosPerito = [
        {label: 'Solicitud asegurado', value: 'solicitudAsegurado'},
        {label: 'Solicitud compañia', value: 'solicitudCompania'},
        {label: 'Solicitud profesional', value: 'solicitudProfesional'}
    ];
    @api submotivosPerito = [
        {label: 'Mala reparación', value: 'malaReparacion'},
        {label: 'Dudas cobertura', value: 'dudasCoberturas'},
        {label: 'Límite sobrepasado', value: 'limiteSobrepasado'}
    ];

    handleChangeCombos(event){
        console.log('event name: ' + event.target.name);
        console.log('event value: ' + event.target.value);
        const field = event.target.name;

        if(field === 'grupo'){
            this.grupoSelected = event.target.value;
        }else if(field === 'tipo'){
            this.tipoAveriaSelected = event.target.value;
        }else if(field === 'detalle'){
            this.detalleAveriaSelected = event.target.value;
        }else if(field === 'causa'){
            this.causaAveriaSelected = event.target.value;
        }

        if(this.grupoSelected && this.tipoAveriaSelected && this.detalleAveriaSelected && this.causaAveriaSelected){
            this.showDanos = true;
        }
    }

    handleDanosPropios(){
        this.showDanosPropios = !this.showDanosPropios;
    }

    handlePerito(){
        this.showMotivosperito = !this.showMotivosperito;
    }

}
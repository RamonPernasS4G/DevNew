import { LightningElement, track } from 'lwc';
 
export default class FiltrosListado extends LightningElement {
    @track valueGremio = '';
    @track valueGremioOrd = '';

    get optionsGremio() {
        return [
            { label: 'Fontanero', value: 'Fontanero' },
            { label: 'Electricista', value: 'Electricista' }
        ];
    }
    get optionsGremioOrd() {
        return [
            { label: 'Ascendente', value: 'ASC' },
            { label: 'Descendente', value: 'DESC' }
        ];
    }
}
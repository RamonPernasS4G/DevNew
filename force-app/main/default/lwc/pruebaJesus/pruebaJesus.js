import { LightningElement, api, track } from 'lwc';
 
export default class PruebaJesus extends LightningElement {

    baseprice = 200;

    @track netPrice;
    @track discount;

    handleNetChange(event){
        this.netPrice = event.detail.value;
    }

    @api get netPrice(){
        return this.netPrice;
    }

    set netPrice(val){
        this.setAttribute('netPrice', val);
        this.discount = this.baseprice - val;
    }
    @api get discount(){
        return this.discount;
    }

}
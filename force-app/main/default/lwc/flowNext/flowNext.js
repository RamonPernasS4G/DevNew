import { LightningElement } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { FlowNavigationBackEvent } from 'lightning/flowSupport';

 
export default class FlowNext extends LightningElement {
    handleClickNext(event){
        const nextNavigationEvent = new FlowNavigationNextEvent("dummy");
        this.dispatchEvent(nextNavigationEvent);
    }
    handleClickPrev(event){
        const nextNavigationEvent = new FlowNavigationBackEvent("dummy");
        this.dispatchEvent(nextNavigationEvent);
    }
}
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, api} from 'lwc'; 
import { oDebug } from 'c/s4GUtils';

export default class S4GTable extends LightningElement {
  @api records;
  @api columns;
  @api tableLoadingState;

  handleClick(event){
    console.log(JSON.stringify(event));
    console.log(JSON.stringify(event.detail));
    const selectedRow = event.detail.selectedRows[0];
    this.dispatchEvent( new CustomEvent('selectedrow', {
      detail: {recordId:selectedRow}
    }));
  }

  handleRowAction(event){
    this.dispatchEvent( new CustomEvent('rowaction',{
      detail : event.detail
    }));
  }
}
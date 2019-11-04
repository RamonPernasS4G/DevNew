/* eslint-disable guard-for-in */
/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';
 
export default class GenerarCSV extends LightningElement {
    
    @api records;
    @api nombre;

    @api
    handleGenerateCSV(){
        console.log('records', this.records);
        this.generateCSV();

    }
    generateCSV(){
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        var rowData = new Set();
        this.records.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                console.log(key);
                rowData.add(key);
            });
        });
         // Array.from() method returns an Array object from any object with a length property or an iterable object.
         rowData = Array.from(rowData);
        
         // splitting using ','
         csvString += rowData.join(',');
         csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.records.length; i++){
            let colValue = 0;
            // validating keys in data
            for(let key in rowData) {
                console.log(rowData.hasOwnProperty(key));
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    console.log(rowKey);
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.records[i][rowKey] === undefined ? '' : this.records[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        } 
        console.log('csvString ' + csvString);
        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = this.nombre + '.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }
}
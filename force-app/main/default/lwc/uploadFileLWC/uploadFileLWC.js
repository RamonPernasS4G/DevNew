import { LightningElement, api, track } from 'lwc';
 
export default class UploadFileLWC extends LightningElement {

    @api recordId;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jepg', '.jpeg'];
    }

    @track antesIds = [];

    // eslint-disable-next-line no-unused-vars
    handleUploadFinishedAntes(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles', uploadedFiles);
        uploadedFiles.forEach(element => {
            console.log('element', element);
            this.antesIds.push(
                {
                    Id: element.documentId
                    , url : '/sfc/servlet.shepherd/document/download/' + element.documentId
                });
        });
        console.log('antesIds', JSON.stringify(this.antesIds));
    }
}
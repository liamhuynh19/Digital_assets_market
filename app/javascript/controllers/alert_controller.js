import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        setTimeout(()=> {
            this.dismissAlert()
        }, 3000)
    }

    dismissAlert() {
        this.element.querySelectorAll('.alert').forEach(alert => {
            if (typeof bootstrap !== 'undefined') {
                const alertInstance = bootstrap.Alert.getOrCreateInstance(alert)
                alertInstance.close()
            }
            else {
                alert.remove()
            }
        })
    }
}
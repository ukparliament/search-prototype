import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {

    static targets = [
        "source",
        "copiedIndicator"
    ]

    connect() {
    }

    copy(event) {
        event.preventDefault()
        const source = this.sourceTarget;
        navigator.clipboard.writeText(source.dataset.clipboardText);
    }
}
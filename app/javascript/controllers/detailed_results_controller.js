import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="detailed-results"
export default class extends Controller {

    static targets = ["toggleHidden"]

    connect() {
    }

    toggle(event) {
        this.toggleHiddenTargets.forEach(element => {
            element.toggleAttribute("hidden");
        })
    }
}
import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="filters"
export default class extends Controller {

    static targets = [
        "filtersPanel"
    ]

    toggle(event) {
        console.log('test')
        this.filtersPanelTarget.classList.toggle("d-none")
    }
}

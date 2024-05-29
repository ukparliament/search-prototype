import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="expand-hierarchy"
export default class extends Controller {

    connect() {
    }

    toggle(event) {
        const container_id = event.params.id
        const all_toggles = Array.from(document.getElementsByClassName('toggle-' + container_id));
        const button = event.currentTarget;

        all_toggles.forEach(element => {
            element.classList.toggle("collapse");
            if (element.classList.contains("collapse")) {
                button.innerHTML = "&#43;";
            } else {
                button.innerHTML = "-";
            }
        })
    }
}

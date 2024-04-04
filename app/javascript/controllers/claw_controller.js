import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="claw"
export default class extends Controller {
    connect() {
        document.addEventListener("keydown", this.handleKeyDown.bind(this));
    }

    disconnect() {
        document.removeEventListener("keydown", this.handleKeyDown.bind(this));
    }

    handleKeyDown(event) {
        // detect code of "KeyD" rather than key of "D" as use of modifiers
        // actually produces ∂ character instead on MacOS

        if (event.ctrlKey && event.altKey && event.code === "KeyD") {
            event.preventDefault();
            this.showClaw();
        }
    }

    showClaw() {
        const element= document.querySelector("#about-this-result");
        if (element) {
            element.toggleAttribute("hidden");
        }
    }
}

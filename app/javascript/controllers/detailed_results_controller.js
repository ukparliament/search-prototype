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

        // Get updated state of show_detailed toggle
        const showDetailed = document.querySelector('#show-detailed').checked;

        // Locate all hidden fields for persisting state of show detailed toggle
        const hidden_show_detailed_fields = document.querySelectorAll('.hidden-show-detailed');

        // Update value of show detailed hidden fields
        hidden_show_detailed_fields.forEach(field => {
            field.value = showDetailed;
        })

        // Locate all modifiable links on the page
        const links = document.querySelectorAll('.modifiable-link');

        // Append show detailed value as a parameter to all links
        links.forEach(link => {
            const url = new URL(link.href);
            url.searchParams.delete('show_detailed')
            url.searchParams.append('show_detailed', showDetailed)
            link.href = url.toString();
        });

        // ensure show_detailed is recorded in the current URL
        let current_url = new URL(window.location);
        current_url.searchParams.delete('show_detailed')
        current_url.searchParams.append('show_detailed', showDetailed)
        history.pushState(null, '', current_url);
    }
}
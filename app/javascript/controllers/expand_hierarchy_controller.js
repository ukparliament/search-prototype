import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="expand-hierarchy"
export default class extends Controller {

    connect() {
    }

    toggle(event) {
        const container_id = event.params.id
        const container_id_string = container_id.toString();

        const links = document.querySelectorAll('.modifiable-link');
        let existingIds = [];
        const first_link = links.item(0).href;
        const first_url = new URL(first_link);
        const first_link_params = first_url.searchParams;

        if (typeof first_link_params !== "undefined") {
            const ids_from_params = first_link_params.getAll('expanded_ids');

            ids_from_params.forEach(param => {
                const ids_array = param.split(',')
                ids_array.forEach(id => {
                        existingIds.push(id.toString());
                    }
                )
            })
        }

        if (existingIds.includes(container_id_string)) {
            const delete_index = existingIds.indexOf(container_id_string);
            existingIds.splice(delete_index, 1);
        } else {
            existingIds.push(container_id_string);
        }

        links.forEach(link => {
            const url = new URL(link.href);
            url.searchParams.delete('expanded_ids');
            url.searchParams.append('expanded_ids', existingIds);
            link.href = url.toString();
        });

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

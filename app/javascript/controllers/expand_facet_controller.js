import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="expand-facet"
export default class extends Controller {

    connect() {
    }

    toggle(event) {
        // the toggle event is being triggered on a regular page load via the search button
        // possibly due to the CSS showing/hiding the details

        const facetName = event.params.name.toString();

        const links = document.querySelectorAll('.modifiable-link');
        const hidden_toggled_facets_fields = document.querySelectorAll('.hidden-toggled-facets');

        let toggledFacets = [];

        // Look at the first modifiable link on the page, as they are all the same, and fetch its params
        const first_link = links.item(0).href;
        const first_url = new URL(first_link);
        const first_link_params = first_url.searchParams;

        // read in current values from params
        if (typeof first_link_params !== "undefined") {
            const facetsFromParams = first_link_params.getAll('toggled_facets');

            facetsFromParams.forEach(param => {
                const names_array = param.split(',')
                names_array.forEach(name => {
                        toggledFacets.push(name.toString());
                    }
                )
            })
        }

        if (toggledFacets.includes(facetName)) {
            const delete_index = toggledFacets.indexOf(facetName);
            toggledFacets.splice(delete_index, 1);
        } else {
            toggledFacets.push(facetName);
        }

        // Update form hidden fields with existing IDs
        hidden_toggled_facets_fields.forEach(field => {
            field.value = toggledFacets;
        })

        links.forEach(link => {
            const url = new URL(link.href);
            url.searchParams.delete('toggled_facets');
            url.searchParams.append('toggled_facets', toggledFacets);
            link.href = url.toString();
        });
    }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {

  static targets = [
    "source",
    "copiedIndicator"
  ]

  connect() {
  }

  copy(event) {
    // prevent the default action of the trigger element
    event.preventDefault()

    // copy the content from the sourceTarget to the clipboard
    navigator.clipboard.writeText(this.sourceTarget.dataset.clipboardText);

    // show the copied indicator
    this.copiedIndicatorTarget.classList.remove("hidden");

    // hide the copied indicator after 2 seconds
    setTimeout(() => {
      this.copiedIndicatorTarget.classList.add("hidden");
    }, 2000)
  }
}
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="update-form"
export default class extends Controller {
  connect() {
  }

  update() {
    console.log('update action')
  }
}

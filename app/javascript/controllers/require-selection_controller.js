import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'submit']

  connect () {
    this.checkboxes = [...this.formTarget.getElementsByClassName('toggle-checkbox')]
    this.searchBox = this.formTarget.querySelector('.form_search')
    this.checkboxes.forEach(
      checkbox => { checkbox.onchange = () => this.updateSubmitState() }
    )
    this.searchBox.onkeyup = () => this.updateSubmitState()
    this.updateSubmitState()
  }

  updateSubmitState () {
    if (this.emptySelection()) {
      this.submitTarget.disabled = true
    } else {
      this.submitTarget.disabled = false
    }
  }

  emptySelection () {
    return (!this.checkboxes.some(cb => cb.checked)) && (!this.searchBox.value.trim())
  }
}

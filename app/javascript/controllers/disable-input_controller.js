import { Controller } from 'stimulus'

export default class extends Controller {
  static values = { property: String }
  static targets = ['input', 'disabledClass']

  updateInputState (event) {
    if (this.disabledStateFromEvent(event)) {
      this.inputTarget.disabled = true
      this.disabledClassTargets.forEach(node => node.classList.add('disabled'))
    } else {
      this.inputTarget.disabled = false
      this.disabledClassTargets.forEach(node => node.classList.remove('disabled'))
    }
  }

  disabledStateFromEvent (event) {
    return event.target[this.property()]
  }

  property () {
    return this.hasPropertyValue ? this.propertyValue : 'value'
  }
}

import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['source']

  copyText () {
    const text = this.sourceTarget.value
    navigator.clipboard.writeText(text)
  }
}

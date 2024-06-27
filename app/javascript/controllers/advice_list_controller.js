import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['listItem', 'viewMoreButton']
  static values = { initialCount: Number }

  connect () {
    this.hideExcessListItems()
  }

  hideExcessListItems () {
    if (this.listItemTargets.length > this.initialCountValue) {
      this.listItemTargets.slice(this.initialCountValue).forEach(listItem => listItem.classList.add('hidden'))
      this.viewMoreButtonTarget.classList.remove('hidden')
    } else {
      this.showAllListItems()
    }
  }

  showAllListItems () {
    this.listItemTargets.forEach(item => item.classList.remove('hidden'))
    this.viewMoreButtonTarget.classList.add('hidden')
  }
}

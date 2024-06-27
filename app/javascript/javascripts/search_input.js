$(document).on('turbolinks:load', () => {
  // check if there is a search box on the page, if so remove the one in banner
  if (document.querySelectorAll('.search-input').length > 1) {
    document.querySelector('.banner-search').classList.add('hidden')
  }
})

$(document).on('turbolinks:load', () => {
  // If the modal isn't present, return early as there's nothing to do.
  if (!document.querySelector('.modal_outer')) {
    return
  }

  if(document.querySelector('.modal_outer').dataset.autoShow) {
    // Return early if the user isn't on the library (still in signup flow).
    if (!String(window.location).match('libraries')) {
      return
    }

    document.querySelector('.modal_outer').classList.remove('modal_hidden')

    // Inform the application the modal was displayed.
    const token = window.document.getElementsByName('csrf-token')[0]?.content
    window.fetch('/welcome_modal', { method: 'DELETE', headers: { 'X-CSRF-Token': token } })
  }

  // add event listener to modal skip button to close the modal
  document
    .getElementById('close_btn')
    .addEventListener('click', (event) =>
      document.querySelector('.modal_outer').classList.add('modal_hidden')
    )
  // Loop through the slides and apply event listeners to continue & back buttons for each slide, first slide does not have a back button
  for (let i = 0; i <= 5; i++) {
    if (i < 5) {
      document
        .getElementById(`continue_${i}`)
        .addEventListener('click', (event) => {
          document.querySelector(`#slide_${i}`).classList.add('modal_hidden')
          document
            .querySelector(`#slide_${i + 1}`)
            .classList.remove('modal_hidden')
        })
    }
    if (i >= 1) {
      document
        .getElementById(`back_${i}`)
        .addEventListener('click', (event) => {
          document.querySelector(`#slide_${i}`).classList.add('modal_hidden')
          document
            .querySelector(`#slide_${i - 1}`)
            .classList.remove('modal_hidden')
        })
    }
  }
  // add event listeners to the final (5th) slide
  document.getElementById('continue_5').addEventListener('click', (event) => {
    document.querySelector('#slide_5').classList.add('modal_hidden')
    document.querySelector('#slide_0').classList.remove('modal_hidden')
    document.querySelector('.modal_outer').classList.add('modal_hidden')
  })
  // add event listener to trigger the tutorial modal
  if (document.getElementById('guide_btn')) {
    document.getElementById('guide_btn').addEventListener('click', (event) => {
      document.querySelector('.modal_outer').classList = 'modal_outer'
    })
  }
  // close modal when user clicks outside of it
  document.getElementById('modal_1').addEventListener('click', (event) => {
    if (!event.target.closest('.modal_inner')) {
      document.querySelector('.modal_outer').classList.add('modal_hidden')
    }
  })
  // close modal when user hits escape
  document.addEventListener('keydown', (event) => {
    if (
      event.key === 'Escape' &&
      !document.getElementById('modal_1').classList.contains('modal_hidden')
    ) {
      document.querySelector('.modal_outer').classList.add('modal_hidden')
    }
  })
  // add event listener for text copy button
  document
    .querySelector('#copy_invite_btn')
    .addEventListener('click', (event) => {
      const text = document.querySelector('#invite_text')
      text.select()
      text.setSelectionRange(0, 99999)
      navigator.clipboard.writeText(text.value)
    })
})

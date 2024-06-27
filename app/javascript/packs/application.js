// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from '@rails/ujs'
import Turbolinks from 'turbolinks'
import * as ActiveStorage from '@rails/activestorage'
import 'channels'

import 'controllers'

import '@fortawesome/fontawesome-free/css/all'

import '../javascripts/trix'
import '../javascripts/modal'
import '../javascripts/search_input'

// Ensure images are packed
require.context('../images', true)

Rails.start()
Turbolinks.start()
ActiveStorage.start()

require('trix')
require('@rails/actiontext')

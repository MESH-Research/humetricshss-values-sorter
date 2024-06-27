# frozen_string_literal: true

# TRICKY: Libraries' lifecycles are tightly tied to the user, making factories difficult to work with due to problems
# roughly analogous to "which came first: the chicken or the egg?". We opt not to define one at all. If you want one,
# obtain it from a user via `user.library` or use `Library.main`

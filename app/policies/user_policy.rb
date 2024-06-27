# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve_public_scope
      scope.where(user: user)
    end
  end
end

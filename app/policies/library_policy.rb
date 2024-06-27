# frozen_string_literal: true

class LibraryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record_in_policy_scope?
  end

  def update?
    user_owns_record?(record_owner: :owner)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve_member_scope
      # TRICKY: The call to #left_outer_joins trips something up here, and will duplicate the users library in the
      # result set. We use #distinct to remove the duplicate result
      resolve_public_scope.or(scope.where(owner: user))
                          .or(scope.where(library_guests: { guest: user }))
                          .left_outer_joins(:library_guests)
                          .distinct
    end

    def resolve_public_scope
      scope.where(id: Library::MAIN_LIBRARY_ID)
    end
  end
end

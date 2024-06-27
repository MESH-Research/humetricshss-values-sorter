# frozen_string_literal: true

class LibraryGuestPolicy < ApplicationPolicy
  def new?
    user_owns_record?(record_owner: :owner)
  end

  def join?
    user.present?
  end

  def destroy?
    user_owns_record?(record_owner: :owner)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve_member_scope
      scope.joins(:library).where(library: { owner: user })
    end

    def resolve_public_scope
      scope.none
    end
  end
end

# frozen_string_literal: true

class AdvicePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user_owns_record?(record_owner: :owner)
  end

  def update?
    user_owns_record?(record_owner: :owner)
  end

  def destroy?
    user_owns_record?(record_owner: :owner)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve_public_scope
      accessible_libraries = LibraryPolicy::Scope.new(user, Library.all).resolve
      scope.where(library: accessible_libraries)
    end
  end
end

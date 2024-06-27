# frozen_string_literal: true

class ContributorApplicationPolicy < ApplicationPolicy
  alias_attribute :contributor_application, :record

  def show?
    user_owns_record?
  end

  def create?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve_admin_scope
      scope.all
    end

    def resolve_member_scope
      scope.where(user: user)
    end

    def resolve_public_scope
      scope.none
    end
  end
end

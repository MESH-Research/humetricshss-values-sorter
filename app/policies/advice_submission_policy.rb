# frozen_string_literal: true

class AdviceSubmissionPolicy < ApplicationPolicy
  def create?
    return false unless user.can_contribute?

    user_owns_record?(record_owner: :submitter)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve_member_scope
      resolve_public_scope.or(scope.where(source_library: user.library))
    end
  end
end

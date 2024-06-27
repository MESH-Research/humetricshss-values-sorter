# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  protected

  def scope_class
    # TRICKY: This ensures we select the overridden Scope class if one exists
    self.class::Scope
  end

  def record_in_policy_scope?(base_scope = nil)
    base_scope ||= record.class.all
    policy_scope = scope_class.new(user, base_scope).resolve
    policy_scope.include?(record)
  end

  def user_owns_record?(record_owner: :user)
    # TRICKY: This avoids problems where e.g. `current_user == nil && record == Library.main`
    return false unless user.present?

    user == record.send(record_owner)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return send(:"resolve_#{user.role}_scope") if user.present?

      resolve_public_scope
    end

    def resolve_admin_scope
      resolve_contributor_scope
    end

    def resolve_contributor_scope
      resolve_member_scope
    end

    def resolve_member_scope
      resolve_public_scope
    end

    def resolve_public_scope
      scope.none
    end
  end
end

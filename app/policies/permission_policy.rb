class PermissionPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "debes iniciar sesión" unless user
    @user = user
    @record = record
  end

  def index?
    user.role.name == "administrador" || user.role.permissions.where(name: "ver permisos").any?
  end

  def show?
    user.role.name == "administrador" || user.role.permissions.where(name: "ver permisos").any?
  end

  def create?
    user.role.name == "administrador" || user.role.permissions.where(name: "crear permisos").any?
  end

  def new?
    user.role.name == "administrador" || user.role.permissions.where(name: "crear permisos").any?
  end

  def update?
    user.role.name == "administrador" || user.role.permissions.where(name: "editar permisos").any?
  end

  def edit?
    user.role.name == "administrador" || user.role.permissions.where(name: "editar permisos").any?
  end

  def destroy?
    user.role.name == "administrador" || user.role.permissions.where(name: "eliminar permisos").any?
  end
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end

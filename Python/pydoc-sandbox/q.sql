select
  users.id,
  users.username,
  users.system_role_id,
  system_roles.name,
  tenant_user_management.tenant_id,
  tenant_roles.name,
  tenants.display_name
from
  users
  `left outer join` system_roles
    on users.system_role_id = system_roles.id
  `left outer join` tenant_user_management
    on users.id = tenant_user_management.user_id
  `left outer join` tenant_roles
    on tenant_user_management.tenant_role_id = tenant_roles.id
  `left outer join` tenants
    on tenant_user_management.tenant_id = tenants.id
order by
  users.username,
  tenants.display_name
;

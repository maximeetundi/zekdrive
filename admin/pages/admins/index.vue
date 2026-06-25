<template>
  <div>
    <!-- Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? '🔐 Gestion des Administrateurs' : '🔐 Admin Management' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Rôles, permissions et comptes administrateurs du panel' : 'Panel admin roles, permissions and accounts' }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary" @click="openAddAdmin">
          <svg style="width:16px;height:16px;margin-right:6px;" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/></svg>
          {{ lang === 'fr' ? 'Ajouter un admin' : 'Add Admin' }}
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid animate-fade-in" style="grid-template-columns: repeat(4,1fr); margin-bottom:2rem;">
      <AppStatsCard :title="lang==='fr'?'Total admins':'Total Admins'" :value="admins.length.toString()" icon="👤" color="blue"/>
      <AppStatsCard :title="lang==='fr'?'Admins actifs':'Active Admins'" :value="admins.filter(a=>a.is_active).length.toString()" icon="✅" color="green"/>
      <AppStatsCard :title="lang==='fr'?'Rôles':'Roles'" :value="roles.length.toString()" icon="🏷️" color="purple"/>
      <AppStatsCard :title="lang==='fr'?'Permissions':'Permissions'" :value="permissions.length.toString()" icon="🔑" color="orange"/>
    </div>

    <!-- Tabs -->
    <div class="tabs animate-fade-in" style="margin-bottom:1.5rem;">
      <button class="tab-item" :class="{active: tab==='admins'}" @click="tab='admins'">
        👥 {{ lang==='fr'?'Comptes Admins':'Admin Accounts' }}
      </button>
      <button class="tab-item" :class="{active: tab==='roles'}" @click="tab='roles'">
        🏷️ {{ lang==='fr'?'Rôles':'Roles' }}
      </button>
      <button class="tab-item" :class="{active: tab==='permissions'}" @click="tab='permissions'">
        🔑 {{ lang==='fr'?'Permissions':'Permissions' }}
      </button>
    </div>

    <!-- ── TAB: Admin Accounts ─────────────────────────────────── -->
    <div v-if="tab==='admins'" class="card animate-slide-up">
      <div class="card-body" style="padding:0;">
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ lang==='fr'?'Administrateur':'Administrator' }}</th>
              <th>{{ lang==='fr'?'Email':'Email' }}</th>
              <th>{{ lang==='fr'?'Rôle':'Role' }}</th>
              <th>{{ lang==='fr'?'Statut':'Status' }}</th>
              <th>{{ lang==='fr'?'Dernière connexion':'Last Login' }}</th>
              <th style="text-align:right;">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="admin in admins" :key="admin.user_id" class="data-row">
              <td>
                <div class="flex items-center gap-3">
                  <div class="avatar-sm">{{ admin.name?.charAt(0).toUpperCase() }}</div>
                  <span class="font-semibold">{{ admin.name }}</span>
                </div>
              </td>
              <td class="text-muted">{{ admin.email }}</td>
              <td>
                <span class="role-badge" :style="{background: (admin.role_color||'#6366f1')+'22', color: admin.role_color||'#6366f1', border: '1px solid '+(admin.role_color||'#6366f1')+'44'}">
                  {{ admin.role_label || admin.role_name || '—' }}
                </span>
              </td>
              <td><AppStatusBadge :status="admin.is_active ? 'active' : 'inactive'" /></td>
              <td class="text-muted text-sm">{{ admin.last_login ? formatDate(admin.last_login) : '—' }}</td>
              <td style="text-align:right;">
                <div class="flex gap-2 justify-end">
                  <button class="btn btn-secondary btn-sm" @click="openEditAdmin(admin)">{{ lang==='fr'?'Modifier':'Edit' }}</button>
                  <button v-if="admin.is_active && admin.role_name !== 'super_admin'" class="btn btn-sm" style="background:rgba(239,68,68,0.1);color:#ef4444;border:1px solid rgba(239,68,68,0.2);" @click="deactivateAdmin(admin)">
                    {{ lang==='fr'?'Désactiver':'Disable' }}
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="admins.length===0">
              <td colspan="6" style="text-align:center;padding:2rem;color:var(--text-muted);">{{ lang==='fr'?'Aucun administrateur':'No administrators found' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ── TAB: Roles ──────────────────────────────────────────── -->
    <div v-if="tab==='roles'" class="animate-slide-up">
      <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap:1.5rem;">
        <div v-for="role in roles" :key="role.id" class="card">
          <div class="card-body">
            <div class="flex items-center gap-3" style="margin-bottom:1rem;">
              <div class="role-icon" :style="{background: (role.color||'#6366f1')+'22', color: role.color||'#6366f1'}">
                {{ roleEmoji(role.name) }}
              </div>
              <div>
                <div class="font-semibold text-primary">{{ role.label }}</div>
                <div class="text-xs text-muted">{{ role.name }}</div>
              </div>
              <div class="flex-1"></div>
              <span v-if="role.is_system" class="badge badge-info" style="font-size:0.65rem;">Système</span>
            </div>
            <p class="text-sm text-muted" style="margin-bottom:1rem;">{{ role.description }}</p>

            <!-- Permissions grouped -->
            <div style="margin-bottom:1rem;">
              <div class="text-xs text-muted" style="margin-bottom:0.5rem;font-weight:600;text-transform:uppercase;letter-spacing:.05em;">
                {{ lang==='fr'?'Permissions':'Permissions' }} ({{ (role.permissions||[]).length }})
              </div>
              <div style="display:flex;flex-wrap:wrap;gap:0.35rem;">
                <span v-for="p in (role.permissions||[]).slice(0,8)" :key="p.key" class="perm-chip">{{ p.key }}</span>
                <span v-if="(role.permissions||[]).length > 8" class="perm-chip" style="opacity:0.6;">+{{ (role.permissions||[]).length - 8 }} {{ lang==='fr'?'autres':'more' }}</span>
              </div>
            </div>

            <div class="flex gap-2">
              <button v-if="!role.is_system || currentUserIsSuperAdmin" class="btn btn-secondary btn-sm" @click="openEditRole(role)">
                {{ lang==='fr'?'Modifier permissions':'Edit Permissions' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ── TAB: Permissions ────────────────────────────────────── -->
    <div v-if="tab==='permissions'" class="card animate-slide-up">
      <div class="card-body" style="padding:0;">
        <div v-for="(group, groupName) in groupedPermissions" :key="groupName" style="border-bottom:1px solid var(--border-color);">
          <div style="padding:0.75rem 1.5rem;background:var(--bg-card-hover);font-size:0.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:var(--text-muted);">
            {{ groupName }}
          </div>
          <table class="data-table" style="margin:0;">
            <tbody>
              <tr v-for="perm in group" :key="perm.key" class="data-row">
                <td style="width:220px;"><code style="font-size:0.8rem;color:var(--accent-primary);">{{ perm.key }}</code></td>
                <td>{{ perm.label }}</td>
                <td style="text-align:right;">
                  <div class="flex gap-1 justify-end flex-wrap">
                    <span v-for="role in roles" :key="role.id"
                      class="perm-chip"
                      :style="roleHasPerm(role,perm.key) ? {background:(role.color||'#6366f1')+'22',color:role.color||'#6366f1',border:'1px solid '+(role.color||'#6366f1')+'44'} : {opacity:'0.3'}"
                    >{{ role.name }}</span>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- ── Modal: Add/Edit Admin ─────────────────────────────── -->
    <AppModal :show="showAdminModal" :title="editingAdmin ? (lang==='fr'?'Modifier admin':'Edit Admin') : (lang==='fr'?'Ajouter un administrateur':'Add Administrator')" @close="showAdminModal=false">
      <div style="display:flex;flex-direction:column;gap:1rem;">
        <div v-if="!editingAdmin">
          <label class="form-label">{{ lang==='fr'?'Utilisateur existant (email)':'Existing user (email)' }}</label>
          <input v-model="adminForm.email" class="form-input" type="email" :placeholder="lang==='fr'?'email@exemple.com':'email@example.com'"/>
        </div>
        <div v-else>
          <label class="form-label">{{ lang==='fr'?'Administrateur':'Administrator' }}</label>
          <div class="form-input" style="background:var(--bg-card-hover);cursor:default;">{{ editingAdmin.name }} — {{ editingAdmin.email }}</div>
        </div>
        <div>
          <label class="form-label">{{ lang==='fr'?'Rôle attribué':'Assigned Role' }}</label>
          <select v-model="adminForm.role_id" class="form-input">
            <option value="">{{ lang==='fr'?'-- Choisir un rôle --':'-- Select a role --' }}</option>
            <option v-for="role in roles" :key="role.id" :value="role.id">
              {{ roleEmoji(role.name) }} {{ role.label }} ({{ role.name }})
            </option>
          </select>
        </div>
        <div class="flex gap-2 justify-end">
          <button class="btn btn-secondary" @click="showAdminModal=false">{{ lang==='fr'?'Annuler':'Cancel' }}</button>
          <button class="btn btn-primary" :disabled="!adminForm.role_id" @click="saveAdmin">{{ lang==='fr'?'Enregistrer':'Save' }}</button>
        </div>
      </div>
    </AppModal>

    <!-- ── Modal: Edit Role Permissions ─────────────────────── -->
    <AppModal :show="showRoleModal" :title="editingRole ? (lang==='fr'?'Permissions : ':'Permissions: ')+editingRole.label : ''" @close="showRoleModal=false" style="max-width:680px;">
      <div v-if="editingRole">
        <div v-for="(group, groupName) in groupedPermissions" :key="groupName" style="margin-bottom:1rem;">
          <div class="text-xs text-muted" style="font-weight:700;text-transform:uppercase;letter-spacing:.06em;margin-bottom:0.5rem;">{{ groupName }}</div>
          <div style="display:flex;flex-wrap:wrap;gap:0.5rem;">
            <label v-for="perm in group" :key="perm.key" class="perm-toggle" :class="{'perm-active': selectedPermIds.includes(perm.id)}">
              <input type="checkbox" :value="perm.id" v-model="selectedPermIds" style="display:none;"/>
              {{ perm.key }}
            </label>
          </div>
        </div>
        <div class="flex gap-2 justify-end" style="margin-top:1rem;">
          <button class="btn btn-secondary" @click="showRoleModal=false">{{ lang==='fr'?'Annuler':'Cancel' }}</button>
          <button class="btn btn-primary" @click="saveRolePermissions">{{ lang==='fr'?'Sauvegarder':'Save' }}</button>
        </div>
      </div>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from '~/composables/useI18n'
import { useApi } from '~/composables/useApi'

definePageMeta({ middleware: 'auth' })

const { lang } = useI18n()
const { get, post, put } = useApi()

const tab = ref('admins')
const admins = ref<any[]>([])
const roles = ref<any[]>([])
const permissions = ref<any[]>([])

// Modals
const showAdminModal = ref(false)
const showRoleModal = ref(false)
const editingAdmin = ref<any>(null)
const editingRole = ref<any>(null)
const selectedPermIds = ref<string[]>([])
const adminForm = ref({ email: '', role_id: '' })

// Fake super admin detection (would come from auth store in real app)
const currentUserIsSuperAdmin = ref(true)

onMounted(async () => {
  await Promise.all([loadAdmins(), loadRoles(), loadPermissions()])
})

async function loadAdmins() {
  const res = await get<any[]>('/api/admin/admin-users')
  if (res.data) admins.value = res.data
  else admins.value = seedAdmins()
}

async function loadRoles() {
  const res = await get<any[]>('/api/admin/roles')
  if (res.data) roles.value = res.data
  else roles.value = seedRoles()
}

async function loadPermissions() {
  const res = await get<any[]>('/api/admin/permissions')
  if (res.data) permissions.value = res.data
  else permissions.value = []
}

const groupedPermissions = computed(() => {
  const map: Record<string, any[]> = {}
  for (const p of permissions.value) {
    if (!map[p.group_name]) map[p.group_name] = []
    map[p.group_name].push(p)
  }
  return map
})

function roleHasPerm(role: any, permKey: string) {
  return (role.permissions || []).some((p: any) => p.key === permKey)
}

function roleEmoji(name: string) {
  const m: Record<string,string> = { super_admin:'👑', admin:'⚙️', moderator:'🛡️', support:'💬', finance:'💰' }
  return m[name] ?? '👤'
}

function formatDate(d: string) {
  return new Date(d).toLocaleString(lang.value === 'fr' ? 'fr-FR' : 'en-GB', { dateStyle: 'short', timeStyle: 'short' })
}

function openAddAdmin() { editingAdmin.value = null; adminForm.value = { email: '', role_id: '' }; showAdminModal.value = true }
function openEditAdmin(admin: any) { editingAdmin.value = admin; adminForm.value = { email: admin.email, role_id: admin.role_id || '' }; showAdminModal.value = true }
function openEditRole(role: any) {
  editingRole.value = role
  selectedPermIds.value = (role.permissions || []).map((p: any) => p.id)
  showRoleModal.value = true
}

async function saveAdmin() {
  // POST /api/admin/admin-users  { email, role_id } or { user_id, role_id }
  await post('/api/admin/admin-users', adminForm.value)
  showAdminModal.value = false
  await loadAdmins()
}

async function deactivateAdmin(admin: any) {
  if (!confirm(lang.value === 'fr' ? 'Désactiver cet administrateur ?' : 'Disable this administrator?')) return
  await put(`/api/admin/admin-users/${admin.user_id}/deactivate`, {})
  await loadAdmins()
}

async function saveRolePermissions() {
  await put(`/api/admin/roles/${editingRole.value.id}/permissions`, { permission_ids: selectedPermIds.value })
  showRoleModal.value = false
  await loadRoles()
}

// ── Seed data for when API not yet connected ───────────────────────────────
function seedRoles() {
  return [
    { id:'a0000001-0000-0000-0000-000000000001', name:'super_admin', label:'Super Administrateur', description:'Accès complet à toutes les fonctionnalités.', color:'#ef4444', is_system:true,
      permissions:[{key:'users.view'},{key:'users.edit'},{key:'users.delete'},{key:'drivers.view'},{key:'drivers.approve'},{key:'trips.view'},{key:'stores.view'},{key:'analytics.view'},{key:'admins.manage'}] },
    { id:'a0000001-0000-0000-0000-000000000002', name:'admin', label:'Administrateur', description:'Gestion complète sauf la gestion des administrateurs.', color:'#f97316', is_system:true,
      permissions:[{key:'users.view'},{key:'users.edit'},{key:'drivers.view'},{key:'trips.view'},{key:'stores.view'},{key:'analytics.view'},{key:'pricing.edit'}] },
    { id:'a0000001-0000-0000-0000-000000000003', name:'moderator', label:'Modérateur', description:'Peut voir et modérer les utilisateurs, chauffeurs et commerces.', color:'#8b5cf6', is_system:true,
      permissions:[{key:'users.view'},{key:'users.ban'},{key:'drivers.view'},{key:'stores.approve'},{key:'orders.view'}] },
    { id:'a0000001-0000-0000-0000-000000000004', name:'support', label:'Support Client', description:'Accès en lecture pour traiter les tickets.', color:'#06b6d4', is_system:true,
      permissions:[{key:'users.view'},{key:'drivers.view'},{key:'trips.view'},{key:'deliveries.view'}] },
    { id:'a0000001-0000-0000-0000-000000000005', name:'finance', label:'Responsable Finance', description:'Accès aux transactions et facturation.', color:'#10b981', is_system:true,
      permissions:[{key:'transactions.view'},{key:'transactions.export'},{key:'promotions.edit'},{key:'pricing.edit'},{key:'analytics.view'}] },
  ]
}

function seedAdmins() {
  return [
    { user_id:'u1', name:'Super Admin ZekDrive', email:'admin@zekdrive.com', phone:'+221770000000', role_name:'super_admin', role_label:'Super Administrateur', role_color:'#ef4444', is_active:true, last_login: new Date().toISOString() },
  ]
}
</script>

<style scoped>
.data-table { width:100%; border-collapse:collapse; }
.data-table th { padding:0.875rem 1.5rem; text-align:left; font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:.05em; color:var(--text-muted); border-bottom:1px solid var(--border-color); }
.data-row td { padding:0.875rem 1.5rem; border-bottom:1px solid var(--border-color); font-size:0.875rem; }
.data-row:last-child td { border-bottom:none; }
.data-row:hover { background:var(--bg-card-hover); }

.avatar-sm { width:34px; height:34px; border-radius:50%; background:var(--accent-gradient); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:0.875rem; flex-shrink:0; }
.role-badge { padding:0.25rem 0.625rem; border-radius:999px; font-size:0.72rem; font-weight:600; white-space:nowrap; }
.role-icon { width:42px; height:42px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.4rem; flex-shrink:0; }
.perm-chip { padding:0.2rem 0.5rem; border-radius:4px; font-size:0.7rem; font-weight:600; background:rgba(99,102,241,0.1); color:var(--accent-primary); border:1px solid rgba(99,102,241,0.2); }
.perm-toggle { padding:0.3rem 0.7rem; border-radius:6px; font-size:0.75rem; font-weight:600; cursor:pointer; background:var(--bg-card); border:1px solid var(--border-color); color:var(--text-secondary); transition:all .15s; user-select:none; }
.perm-toggle:hover { background:var(--bg-card-hover); }
.perm-active { background:rgba(20,177,158,0.15) !important; color:var(--accent-primary) !important; border-color:rgba(20,177,158,0.4) !important; }
</style>

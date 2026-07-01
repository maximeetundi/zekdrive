<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Campagnes & Promotions' : 'Campaigns & Promotions' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Gérer les codes promos, les bannières publicitaires et les annonces de l\'application' : 'Manage promo codes, advertising banners, and app announcements' }}</p>
      </div>
      <div class="page-actions">
        <button v-if="activeTab === 'coupons'" class="btn btn-primary flex items-center gap-2" @click="openAddCouponModal">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          <span>{{ lang === 'fr' ? 'Créer un coupon' : 'Create Coupon' }}</span>
        </button>
        <button v-else class="btn btn-primary flex items-center gap-2" @click="openAddBannerModal">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          <span>{{ lang === 'fr' ? 'Ajouter une bannière' : 'Add Banner' }}</span>
        </button>
      </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="tabs-container animate-fade-in" style="display: flex; gap: 1rem; margin-bottom: 1.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; justify-content: flex-start;">
      <button class="tab-btn" :class="{ active: activeTab === 'coupons' }" @click="activeTab = 'coupons'">
        🎟️ {{ lang === 'fr' ? 'Codes Promotionnels' : 'Promo Coupons' }}
      </button>
      <button class="tab-btn" :class="{ active: activeTab === 'banners' }" @click="activeTab = 'banners'">
        🖼️ {{ lang === 'fr' ? 'Bannières Publicitaires' : 'Advertising Banners' }}
      </button>
    </div>

    <!-- TAB 1: Coupons Table Card -->
    <div v-if="activeTab === 'coupons'" class="card animate-slide-up">
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="couponHeaders"
          :items="coupons"
          :loading="loadingCoupons"
          :currentPage="1"
          :perPage="20"
          :totalItems="coupons.length"
          :totalPages="1"
        >
          <template #cell-code="{ item }">
            <span style="font-family: monospace; font-size: 0.9375rem; font-weight: 700; color: var(--accent-primary); letter-spacing: 0.05em; background: rgba(20, 177, 158, 0.08); padding: 0.25rem 0.5rem; border-radius: var(--radius-sm); border: 1px dashed rgba(20,177,158,0.2);">
              {{ item.code }}
            </span>
          </template>

          <template #cell-type="{ item }">
            <span class="text-xs font-semibold text-secondary" style="text-transform: capitalize;">
              {{ item.type === 'percent' ? (lang === 'fr' ? 'Pourcentage (%)' : 'Percentage (%)') : (lang === 'fr' ? 'Montant Fixe' : 'Fixed Amount') }}
            </span>
          </template>

          <template #cell-value="{ item }">
            <span class="font-bold text-primary">
              {{ item.type === 'percent' ? item.value + '%' : formatCurrency(item.value) }}
            </span>
          </template>

          <template #cell-usage="{ item }">
            <span class="text-xs text-primary">
              <strong>{{ item.usage_count }}</strong> / <span class="text-muted">{{ item.usage_limit }}</span>
            </span>
          </template>

          <template #cell-expiry_date="{ item }">
            <span class="text-xs" :class="isExpired(item.expiry_date) ? 'text-red' : 'text-primary'">
              {{ formatDate(item.expiry_date) }}
              <span v-if="isExpired(item.expiry_date)" class="text-xs block" style="font-weight: 500; color: var(--text-danger);">{{ lang === 'fr' ? '(Expiré)' : '(Expired)' }}</span>
            </span>
          </template>

          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status && !isExpired(item.expiry_date) ? 'active' : 'inactive'" />
          </template>

          <template #cell-actions="{ item }">
            <div class="flex gap-2 justify-end">
              <button class="btn btn-secondary btn-sm" @click="openEditCouponModal(item)">{{ t('edit') }}</button>
              <button class="btn btn-secondary btn-sm" @click="toggleCouponStatus(item)">
                {{ item.status ? (lang === 'fr' ? 'Désactiver' : 'Deactivate') : (lang === 'fr' ? 'Activer' : 'Activate') }}
              </button>
              <button class="btn btn-danger btn-sm" @click="deleteCoupon(item.id)">{{ t('delete') }}</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- TAB 2: Banners Table Card -->
    <div v-else class="card animate-slide-up">
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="bannerHeaders"
          :items="banners"
          :loading="loadingBanners"
          :currentPage="1"
          :perPage="20"
          :totalItems="banners.length"
          :totalPages="1"
        >
          <!-- Banner Image Cell -->
          <template #cell-image="{ item }">
            <div style="width: 80px; height: 45px; border-radius: var(--radius-sm); overflow: hidden; background: var(--bg-card); border: 1px solid var(--border);">
              <img :src="getBannerImageUrl(item.image)" alt="Banner" style="width: 100%; height: 100%; object-fit: cover;" />
            </div>
          </template>

          <template #cell-name="{ item }">
            <div class="text-left">
              <strong class="text-primary block">{{ item.name }}</strong>
              <span class="text-xs text-muted block" style="max-width: 250px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{{ item.description }}</span>
            </div>
          </template>

          <template #cell-display_position="{ item }">
            <span class="text-xs font-medium text-secondary" style="text-transform: uppercase;">
              {{ item.display_position }}
            </span>
          </template>

          <template #cell-dates="{ item }">
            <span class="text-xs text-primary">
              {{ formatDate(item.start_date) }} - {{ formatDate(item.end_date) }}
            </span>
          </template>

          <template #cell-actions="{ item }">
            <div class="flex gap-2 justify-end">
              <button class="btn btn-secondary btn-sm" @click="openEditBannerModal(item)">{{ t('edit') }}</button>
              <button class="btn btn-danger btn-sm" @click="deleteBanner(item.id)">{{ t('delete') }}</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- ── MODAL 1: Create/Edit Coupon ── -->
    <AppModal
      :show="showCouponModal"
      :title="isCouponEditMode ? (lang === 'fr' ? 'Modifier le coupon' : 'Edit Coupon') : (lang === 'fr' ? 'Créer un coupon promo' : 'Create Promo Coupon')"
      @close="showCouponModal = false"
    >
      <form @submit.prevent="saveCoupon">
        <div class="form-group text-left" style="margin-bottom: 1rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Code promotionnel' : 'Promotional Code' }}</label>
          <input v-model="couponForm.code" type="text" class="form-input" style="text-transform: uppercase;" required placeholder="WELCOME20" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Méthode de réduction' : 'Discount Method' }}</label>
            <select v-model="couponForm.type" class="form-select">
              <option value="percent">{{ lang === 'fr' ? 'Pourcentage (%)' : 'Percentage (%)' }}</option>
              <option value="flat">{{ lang === 'fr' ? 'Montant fixe (FCFA)' : 'Fixed Amount (FCFA)' }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Valeur de la réduction' : 'Discount Value' }}</label>
            <input v-model.number="couponForm.value" type="number" class="form-input" required min="1" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Limite d\'utilisations' : 'Usage Limit' }}</label>
            <input v-model.number="couponForm.usage_limit" type="number" class="form-input" required min="1" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Date d\'expiration' : 'Expiration Date' }}</label>
            <input v-model="couponForm.expiry_date" type="date" class="form-input" required />
          </div>
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="couponForm.status" type="checkbox" />
            <span class="text-sm">{{ lang === 'fr' ? 'Activé et utilisable' : 'Enabled & Redeemable' }}</span>
          </label>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showCouponModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ lang === 'fr' ? 'Enregistrer le coupon' : 'Save Coupon' }}</button>
        </div>
      </form>
    </AppModal>

    <!-- ── MODAL 2: Create/Edit Banner ── -->
    <AppModal
      :show="showBannerModal"
      :title="isBannerEditMode ? (lang === 'fr' ? 'Modifier la bannière' : 'Edit Banner') : (lang === 'fr' ? 'Créer une bannière publicitaire' : 'Create Banner Campaign')"
      @close="showBannerModal = false"
    >
      <form @submit.prevent="saveBanner">
        <div class="form-group text-left" style="margin-bottom: 1rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Titre de la campagne' : 'Campaign Title' }}</label>
          <input v-model="bannerForm.name" type="text" class="form-input" required placeholder="Lancement ZekDrive Dakar" />
        </div>

        <div class="form-group text-left" style="margin-bottom: 1rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Description de l\'annonce' : 'Announcement Description' }}</label>
          <textarea v-model="bannerForm.description" class="form-input" style="height: 60px;" placeholder="Obtenez des trajets abordables et fiables..."></textarea>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Position d\'affichage' : 'Display Position' }}</label>
            <select v-model="bannerForm.display_position" class="form-select">
              <option value="top">{{ lang === 'fr' ? 'Haut de page (Carrousel)' : 'Top Carousel' }}</option>
              <option value="bottom">{{ lang === 'fr' ? 'Bas de page' : 'Bottom section' }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Lien de redirection (Optionnel)' : 'Redirect Link (Optional)' }}</label>
            <input v-model="bannerForm.redirect_link" type="text" class="form-input" placeholder="https://zekdrive.com/promo" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Date de début' : 'Start Date' }}</label>
            <input v-model="bannerForm.start_date" type="date" class="form-input" required />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Date de fin' : 'End Date' }}</label>
            <input v-model="bannerForm.end_date" type="date" class="form-input" required />
          </div>
        </div>

        <!-- Banner Image File Upload -->
        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Image de la bannière (Recommandé 16:9)' : 'Banner Image (16:9 aspect ratio)' }}</label>
          <input type="file" class="form-input" accept="image/*" @change="handleBannerImageChange" :required="!isBannerEditMode" />
          <p v-if="isBannerEditMode" class="text-xs text-muted" style="margin-top: 0.25rem;">
            {{ lang === 'fr' ? 'Laissez vide pour conserver l\'image actuelle.' : 'Leave empty to keep current image.' }}
          </p>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showBannerModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary" :disabled="savingBanner">
            <span v-if="savingBanner" class="spinner" style="margin-right: 0.5rem;"></span>
            <span>{{ lang === 'fr' ? 'Enregistrer la campagne' : 'Save Campaign' }}</span>
          </button>
        </div>
      </form>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from '~/composables/useI18n'
import { useApi } from '~/composables/useApi'

definePageMeta({
  middleware: 'auth',
})

const { t, lang } = useI18n()
const { get, del } = useApi()
const config = useRuntimeConfig()

const activeTab = ref('coupons')
const loadingCoupons = ref(false)
const loadingBanners = ref(false)
const savingBanner = ref(false)

// ── TAB 1: Coupons logic (Mock database) ──
const coupons = ref([
  {
    id: 'coupon_1',
    code: 'WELCOME250',
    type: 'flat',
    value: 2000,
    usage_limit: 1000,
    usage_count: 247,
    expiry_date: '2026-12-31',
    status: true
  },
  {
    id: 'coupon_2',
    code: 'DKR20PERCENT',
    type: 'percent',
    value: 20,
    usage_limit: 500,
    usage_count: 182,
    expiry_date: '2026-08-31',
    status: true
  },
  {
    id: 'coupon_3',
    code: 'TABASKI2026',
    type: 'flat',
    value: 3000,
    usage_limit: 200,
    usage_count: 200,
    expiry_date: '2026-06-20', // Expired
    status: true
  }
])

const couponHeaders = computed(() => [
  { key: 'code', label: lang.value === 'fr' ? 'Code Promo' : 'Promo Code' },
  { key: 'type', label: 'Type' },
  { key: 'value', label: lang.value === 'fr' ? 'Valeur Réduction' : 'Discount Value' },
  { key: 'usage', label: lang.value === 'fr' ? 'Utilisations' : 'Redemptions' },
  { key: 'expiry_date', label: lang.value === 'fr' ? 'Expiration' : 'Expiration' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '220px', textAlign: 'right' } }
])

const showCouponModal = ref(false)
const isCouponEditMode = ref(false)
const editingCouponId = ref<string | null>(null)
const couponForm = ref({
  code: '',
  type: 'percent',
  value: 10,
  usage_limit: 100,
  expiry_date: '',
  status: true
})

function openAddCouponModal() {
  isCouponEditMode.value = false
  editingCouponId.value = null
  const expiry = new Date()
  expiry.setDate(expiry.getDate() + 30)
  couponForm.value = {
    code: '',
    type: 'percent',
    value: 15,
    usage_limit: 500,
    expiry_date: expiry.toISOString().split('T')[0],
    status: true
  }
  showCouponModal.value = true
}

function openEditCouponModal(coupon: any) {
  isCouponEditMode.value = true
  editingCouponId.value = coupon.id
  couponForm.value = {
    code: coupon.code,
    type: coupon.type,
    value: coupon.value,
    usage_limit: coupon.usage_limit,
    expiry_date: coupon.expiry_date,
    status: coupon.status
  }
  showCouponModal.value = true
}

function saveCoupon() {
  const payload = {
    code: couponForm.value.code.toUpperCase(),
    type: couponForm.value.type,
    value: couponForm.value.value,
    usage_limit: couponForm.value.usage_limit,
    expiry_date: couponForm.value.expiry_date,
    status: couponForm.value.status
  }

  if (isCouponEditMode.value && editingCouponId.value) {
    const idx = coupons.value.findIndex(c => c.id === editingCouponId.value)
    if (idx !== -1) {
      coupons.value[idx] = {
        ...coupons.value[idx],
        ...payload
      }
    }
  } else {
    coupons.value.unshift({
      id: 'coupon_' + Date.now(),
      usage_count: 0,
      ...payload
    })
  }

  showCouponModal.value = false
}

function toggleCouponStatus(coupon: any) {
  coupon.status = !coupon.status
}

function deleteCoupon(id: string) {
  coupons.value = coupons.value.filter(c => c.id !== id)
}

// ── TAB 2: Banners logic (Connected to live database!) ──
interface DBBanner {
  id: string
  name: string
  description: string
  time_period: string
  display_position: string
  redirect_link: string
  banner_group: string
  start_date: string
  end_date: string
  image: string
}

const banners = ref<DBBanner[]>([])

const bannerHeaders = computed(() => [
  { key: 'image', label: lang.value === 'fr' ? 'Visuel' : 'Image' },
  { key: 'name', label: lang.value === 'fr' ? 'Campagne (Titre/Description)' : 'Campaign (Title/Desc)' },
  { key: 'display_position', label: 'Position' },
  { key: 'dates', label: lang.value === 'fr' ? 'Période de diffusion' : 'Active Period' },
  { key: 'actions', label: t('actions'), style: { width: '180px', textAlign: 'right' } }
])

const showBannerModal = ref(false)
const isBannerEditMode = ref(false)
const editingBannerId = ref<string | null>(null)
const bannerImageFile = ref<File | null>(null)

const bannerForm = ref({
  name: '',
  description: '',
  display_position: 'top',
  redirect_link: '',
  banner_group: 'all',
  start_date: '',
  end_date: '',
})

function getBannerImageUrl(imageName: string): string {
  if (!imageName) return ''
  // If it's already a full URL, return it
  if (imageName.startsWith('http://') || imageName.startsWith('https://')) return imageName
  // Otherwise, construct backend uploads URL
  const baseUploads = config.public.apiUrl.replace('/api/', '/uploads/promotion/banner/')
  return `${baseUploads}${imageName}`
}

async function loadBanners() {
  loadingBanners.value = true
  const { data, error } = await get<DBBanner[]>('/admin/banners')
  if (data) {
    banners.value = data
  } else if (error) {
    console.error('Error loading banners:', error)
  }
  loadingBanners.value = false
}

function openAddBannerModal() {
  isBannerEditMode.value = false
  editingBannerId.value = null
  bannerImageFile.value = null
  
  const start = new Date()
  const end = new Date()
  end.setDate(end.getDate() + 30) // Default 30 days campaign

  bannerForm.value = {
    name: '',
    description: '',
    display_position: 'top',
    redirect_link: '',
    banner_group: 'all',
    start_date: start.toISOString().split('T')[0],
    end_date: end.toISOString().split('T')[0],
  }
  showBannerModal.value = true
}

function openEditBannerModal(b: DBBanner) {
  isBannerEditMode.value = true
  editingBannerId.value = b.id
  bannerImageFile.value = null

  bannerForm.value = {
    name: b.name,
    description: b.description,
    display_position: b.display_position,
    redirect_link: b.redirect_link,
    banner_group: b.banner_group,
    start_date: b.start_date,
    end_date: b.end_date,
  }
  showBannerModal.value = true
}

function handleBannerImageChange(e: Event) {
  const target = e.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    bannerImageFile.value = target.files[0]
  }
}

// Custom multipart fetch because general useApi requests force application/json header
async function saveBanner() {
  savingBanner.value = true
  const token = useCookie('zekdrive_token').value
  
  const formData = new FormData()
  formData.append('name', bannerForm.value.name)
  formData.append('description', bannerForm.value.description)
  formData.append('display_position', bannerForm.value.display_position)
  formData.append('redirect_link', bannerForm.value.redirect_link)
  formData.append('banner_group', bannerForm.value.banner_group)
  formData.append('start_date', bannerForm.value.start_date)
  formData.append('end_date', bannerForm.value.end_date)
  
  if (bannerImageFile.value) {
    formData.append('image', bannerImageFile.value)
  }

  const headers: Record<string, string> = {
    Accept: 'application/json',
  }
  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }

  const url = isBannerEditMode.value && editingBannerId.value
    ? `${config.public.apiUrl}/admin/banners/${editingBannerId.value}`
    : `${config.public.apiUrl}/admin/banners`

  const method = isBannerEditMode.value ? 'PUT' : 'POST'

  try {
    const res = await fetch(url, {
      method,
      headers,
      body: formData,
    })

    if (res.ok) {
      showBannerModal.value = false
      await loadBanners()
    } else {
      const errBody = await res.json()
      alert('Error: ' + (errBody.error || errBody.message || 'Saving failed'))
    }
  } catch (err: any) {
    alert('Network error: ' + err.message)
  } finally {
    savingBanner.value = false
  }
}

async function deleteBanner(id: string) {
  if (confirm(lang.value === 'fr' ? 'Voulez-vous vraiment supprimer cette campagne ?' : 'Are you sure you want to delete this banner campaign?')) {
    const { error } = await del(`/admin/banners/${id}`)
    if (!error) {
      await loadBanners()
    } else {
      alert('Delete failed: ' + error)
    }
  }
}

// ── Global Helper methods ──
onMounted(() => {
  loadBanners()
})

function isExpired(dateStr: string): boolean {
  return new Date(dateStr) < new Date()
}

function formatDate(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleDateString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { year: 'numeric', month: 'short', day: 'numeric' })
  } catch {
    return dateStr
  }
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}
</script>

<style scoped>
.tab-btn {
  background: transparent;
  border: none;
  padding: 0.5rem 1rem;
  font-size: 0.9375rem;
  font-weight: 600;
  color: var(--text-muted);
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.2s;
}
.tab-btn:hover {
  color: var(--text-primary);
}
.tab-btn.active {
  color: var(--accent-primary);
  border-bottom-color: var(--accent-primary);
}

.text-left {
  text-align: left;
}

.spinner {
  display: inline-block;
  width: 1rem;
  height: 1rem;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}

@media (max-width: 640px) {
  .modal-form-grid {
    grid-template-columns: 1fr !important;
    gap: 1rem !important;
  }
  .modal-footer-actions {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem !important;
  }
  .modal-footer-actions .btn {
    width: 100%;
  }
}
</style>

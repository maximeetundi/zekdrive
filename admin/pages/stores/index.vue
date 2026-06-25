<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">
          {{ currentType === 'restaurant' ? (lang === 'fr' ? 'Gestion des Restaurants' : 'Restaurants Management') : (lang === 'fr' ? 'Gestion des Boutiques' : 'Boutiques Management') }}
        </h1>
        <p class="page-desc">
          {{ currentType === 'restaurant' ? (lang === 'fr' ? 'Gérer les menus des restaurants, plats et précommandes' : 'Manage restaurant menus, dishes and preorders') : (lang === 'fr' ? 'Gérer les catalogues des boutiques, articles et commandes' : 'Manage shop catalogs, items and orders') }}
        </p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary" @click="openAddModal">
          {{ activeTab === 'stores' ? (currentType === 'restaurant' ? (lang === 'fr' ? 'Ajouter un restaurant' : 'Add Restaurant') : (lang === 'fr' ? 'Ajouter une boutique' : 'Add Boutique')) : activeTab === 'catalog' ? t('add_product') : (lang === 'fr' ? 'Créer une commande' : 'Create Order') }}
        </button>
      </div>
    </div>

    <!-- Tabs Wrapper -->
    <div class="tabs animate-fade-in" style="margin-bottom: 1.5rem;">
      <button class="tab-item" :class="{ active: activeTab === 'stores' }" @click="activeTab = 'stores'">
        {{ lang === 'fr' ? 'Établissements' : 'Establishments' }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'catalog' }" @click="activeTab = 'catalog'">
        {{ t('catalog') }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'orders' }" @click="activeTab = 'orders'">
        {{ t('preorders') }}
      </button>
    </div>

    <!-- 1. Stores Tab -->
    <div v-if="activeTab === 'stores'" class="animate-slide-up">
      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable
            :headers="storeHeaders"
            :items="filteredStores"
            :loading="loading"
            :currentPage="1"
            :perPage="20"
            :totalItems="filteredStores.length"
            :totalPages="1"
          >
            <template #cell-name="{ item }">
              <div class="flex items-center gap-3" style="text-align: left;">
                <div style="width: 32px; height: 32px; border-radius: 6px; background: var(--bg-card); display: flex; align-items: center; justify-content: center; font-size: 1.25rem;">
                  {{ item.type === 'restaurant' ? '🍳' : item.type === 'grocery' ? '🛒' : '🛍️' }}
                </div>
                <div>
                  <span class="font-bold text-primary">{{ item.name }}</span>
                  <div class="text-xs text-muted" style="margin-top: 1px;">{{ item.description }}</div>
                </div>
              </div>
            </template>

            <template #cell-type="{ item }">
              <span class="badge" :class="item.type === 'restaurant' ? 'badge-ongoing' : item.type === 'grocery' ? 'badge-truck' : 'badge-info'" style="text-transform: capitalize;">
                {{ item.type === 'restaurant' ? t('restaurant') : item.type === 'grocery' ? t('grocery') : t('boutique') }}
              </span>
            </template>

            <template #cell-rating="{ item }">
              <div class="stars" style="text-align: left;">
                <span class="star" style="color: var(--accent-gold);">★</span>
                <span class="text-xs text-primary font-semibold" style="margin-left: 4px;">{{ item.rating.toFixed(1) }}</span>
              </div>
            </template>

            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.is_active ? 'active' : 'inactive'" />
            </template>

            <template #cell-actions="{ item }">
              <div class="flex gap-2 justify-end">
                <button class="btn btn-secondary btn-sm" @click="openEditStoreModal(item)">{{ t('edit') }}</button>
                <button class="btn btn-secondary btn-sm" @click="toggleStoreStatus(item)">
                  {{ item.is_active ? (lang === 'fr' ? 'Désactiver' : 'Deactivate') : (lang === 'fr' ? 'Activer' : 'Activate') }}
                </button>
                <button class="btn btn-danger btn-sm" @click="deleteStore(item.id)">{{ t('delete') }}</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- 2. Catalog Tab -->
    <div v-else-if="activeTab === 'catalog'" class="animate-slide-up">
      <!-- Store Filter Selector -->
      <div class="card" style="margin-bottom: 1.5rem; padding: 1rem; text-align: left;">
        <div class="form-group text-left" style="width: 280px; margin-bottom: 0;">
          <label class="form-label">{{ lang === 'fr' ? 'Filtrer par établissement :' : 'Filter by Establishment:' }}</label>
          <select v-model="selectedStoreId" class="form-select">
            <option v-for="st in filteredStores" :key="st.id" :value="st.id">{{ st.name }}</option>
          </select>
        </div>
      </div>

      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable
            :headers="productHeaders"
            :items="filteredProducts"
            :loading="loading"
            :currentPage="1"
            :perPage="20"
            :totalItems="filteredProducts.length"
            :totalPages="1"
          >
            <template #cell-name="{ item }">
              <div style="text-align: left;">
                <span class="font-bold text-primary">{{ item.name }}</span>
                <span v-if="item.is_featured" class="badge badge-ongoing text-xs" style="margin-left: 8px;">{{ t('featured') }}</span>
              </div>
            </template>

            <template #cell-price="{ item }">
              <span class="font-semibold text-primary">{{ formatCurrency(item.price) }}</span>
            </template>

            <template #cell-deliverable="{ item }">
              <span class="badge" :class="item.is_deliverable ? 'badge-success' : 'badge-danger'">
                {{ item.is_deliverable ? (lang === 'fr' ? 'Oui' : 'Yes') : (lang === 'fr' ? 'Non' : 'No') }}
              </span>
            </template>

            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.is_active ? 'active' : 'inactive'" />
            </template>

            <template #cell-actions="{ item }">
              <div class="flex gap-2 justify-end">
                <button class="btn btn-secondary btn-sm" @click="openEditProductModal(item)">{{ t('edit') }}</button>
                <button class="btn btn-danger btn-sm" @click="deleteProduct(item.id)">{{ t('delete') }}</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- 3. Preorders Tab -->
    <div v-else class="animate-slide-up">
      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable
            :headers="orderHeaders"
            :items="filteredOrders"
            :loading="loading"
            :currentPage="1"
            :perPage="20"
            :totalItems="filteredOrders.length"
            :totalPages="1"
          >
            <template #cell-id="{ item }">
              <span class="font-bold text-primary">{{ item.ref_id }}</span>
            </template>

            <template #cell-store="{ item }">
              <div style="text-align: left;">
                <strong>{{ item.store_name }}</strong>
              </div>
            </template>

            <template #cell-items="{ item }">
              <div style="text-align: left; max-width: 250px;">
                <div v-for="oi in item.items" :key="oi.product_name" class="text-xs">
                  • {{ oi.quantity }}x {{ oi.product_name }}
                </div>
              </div>
            </template>

            <template #cell-total_fare="{ item }">
              <span class="font-bold text-green">{{ formatCurrency(item.total_fare) }}</span>
            </template>

            <template #cell-type="{ item }">
              <span class="badge" :class="item.delivery_type === 'delivery' ? 'badge-truck' : 'badge-info'">
                {{ item.delivery_type === 'delivery' ? t('delivery') : t('pickup') }}
              </span>
              <div v-if="item.delivery_type === 'pickup' && item.pickup_otp" class="text-xs text-muted" style="margin-top: 2px;">
                OTP: <code>{{ item.pickup_otp }}</code>
              </div>
            </template>

            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.status" />
            </template>

            <template #cell-actions="{ item }">
              <div class="flex gap-2 justify-end">
                <select 
                  :value="item.status" 
                  class="form-select text-xs" 
                  style="width: 140px; height: 1.875rem; padding: 2px 8px; border-radius: var(--radius-sm);"
                  @change="updateOrderStatus(item, $event)"
                >
                  <option value="pending">{{ lang === 'fr' ? 'En attente' : 'Pending' }}</option>
                  <option value="preparing">{{ lang === 'fr' ? 'En préparation' : 'Preparing' }}</option>
                  <option value="ready_for_pickup">{{ lang === 'fr' ? 'Prêt pour retrait' : 'Ready' }}</option>
                  <option value="delivering">{{ lang === 'fr' ? 'En livraison' : 'Delivering' }}</option>
                  <option value="delivered">{{ lang === 'fr' ? 'Livré' : 'Delivered' }}</option>
                  <option value="completed">{{ lang === 'fr' ? 'Terminé' : 'Completed' }}</option>
                  <option value="cancelled">{{ lang === 'fr' ? 'Annulé' : 'Cancelled' }}</option>
                </select>
                <button class="btn btn-danger btn-sm" @click="deleteOrder(item.id)">{{ t('delete') }}</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- Store Modal -->
    <AppModal
      :show="showStoreModal"
      :title="isEditMode ? (lang === 'fr' ? 'Modifier l\'établissement' : 'Edit Establishment Profile') : (currentType === 'restaurant' ? (lang === 'fr' ? 'Ajouter un restaurant' : 'Add Restaurant') : (lang === 'fr' ? 'Ajouter une boutique/commerce' : 'Add Boutique/Shop'))"
      @close="showStoreModal = false"
    >
      <form @submit.prevent="saveStore">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('store_name') }}</label>
          <input v-model="storeForm.name" type="text" class="form-input" required placeholder="La Fourchette Dakar" />
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Description' : 'Description' }}</label>
          <input v-model="storeForm.description" type="text" class="form-input" required :placeholder="lang === 'fr' ? 'Catalogue de restaurant et boulangerie' : 'Fine dining restaurant and bakery catalog'" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ t('store_type') }}</label>
            <select v-model="storeForm.type" class="form-select">
              <option value="restaurant">{{ t('restaurant') }}</option>
              <option value="boutique">{{ t('boutique') }}</option>
              <option value="grocery">{{ t('grocery') }}</option>
              <option value="pharmacy">{{ t('pharmacy') }}</option>
              <option value="other">{{ t('other') }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ t('store_category') }}</label>
            <input v-model="storeForm.category" type="text" class="form-input" :placeholder="lang === 'fr' ? 'Ex: Fast-food, Mode, Bio...' : 'e.g. Fast-food, Fashion, Organic...'" />
          </div>
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Adresse' : 'Address' }}</label>
          <input v-model="storeForm.address" type="text" class="form-input" required placeholder="Avenue Hassan II, Dakar" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Latitude' : 'Latitude' }}</label>
            <input v-model.number="storeForm.latitude" type="number" step="0.0001" class="form-input" required />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Longitude' : 'Longitude' }}</label>
            <input v-model.number="storeForm.longitude" type="number" step="0.0001" class="form-input" required />
          </div>
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="storeForm.is_active" type="checkbox" />
            <span class="text-sm">{{ lang === 'fr' ? 'Établissement actif (Ouvert sur l\'app client)' : 'Active Establishment (Visible to clients)' }}</span>
          </label>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showStoreModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ t('save') }}</button>
        </div>
      </form>
    </AppModal>

    <!-- Product Modal -->
    <AppModal
      :show="showProductModal"
      :title="isEditMode ? (lang === 'fr' ? 'Modifier l\'article' : 'Edit Product Details') : t('add_product')"
      @close="showProductModal = false"
    >
      <form @submit.prevent="saveProduct">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('product_name') }}</label>
          <input v-model="productForm.name" type="text" class="form-input" required placeholder="Pizza Regina" />
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Description' : 'Description' }}</label>
          <input v-model="productForm.description" type="text" class="form-input" :placeholder="lang === 'fr' ? 'Pâte fraîche, tomates, mozzarella, jambon et champignons' : 'Fresh dough, tomatoes, mozzarella, ham and mushrooms'" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ t('price') }} (FCFA)</label>
            <input v-model.number="productForm.price" type="number" class="form-input" required min="1" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Établissement propriétaire' : 'Establishment Owner' }}</label>
            <select v-model="productForm.store_id" class="form-select" required>
              <option v-for="st in filteredStores" :key="st.id" :value="st.id">{{ st.name }}</option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-3 gap-2 modal-metrics-grid" style="grid-template-columns: repeat(3, 1fr); margin-bottom: 1.5rem; text-align: left;">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="productForm.is_featured" type="checkbox" />
            <span class="text-xs">{{ t('featured') }}</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="productForm.is_deliverable" type="checkbox" />
            <span class="text-xs">{{ t('deliverable') }}</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="productForm.is_active" type="checkbox" />
            <span class="text-xs">{{ lang === 'fr' ? 'Activé' : 'Enabled' }}</span>
          </label>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showProductModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ t('save') }}</button>
        </div>
      </form>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useI18n } from '~/composables/useI18n'
import { useApi } from '~/composables/useApi'

definePageMeta({
  middleware: 'auth',
})

const route = useRoute()
const { t, lang } = useI18n()
const { get, post, put } = useApi()
const loading = ref(false)
const activeTab = ref<'stores' | 'catalog' | 'orders'>('stores')

const currentType = computed(() => (route.query.type as string) || 'restaurant')

// ── Backend fetch ─────────────────────────────────────────────────────────────
async function loadStores() {
  loading.value = true
  const typeParam = currentType.value ? `?type=${currentType.value}` : ''
  const { data, error } = await get<any[]>(`/api/admin/stores${typeParam}`)
  if (data && !error) {
    stores.value = data
  }
  loading.value = false
}

onMounted(() => loadStores())
watch(currentType, () => loadStores())

// Stores Database (mock fallback - replaced by backend data on load)
const stores = ref([
  { id: 'st_1', name: 'Le Ryad Resto', type: 'restaurant', rating: 4.8, is_active: true, description: 'Cuisine marocaine et orientale', address: 'Route de la Corniche Ouest, Dakar', latitude: 14.6811, longitude: -17.4623, category: 'Gastronomie' },
  { id: 'st_2', name: 'Alimentation Générale Diallo', type: 'grocery', rating: 4.2, is_active: true, description: 'Superette de quartier, fruits et boissons', address: 'Avenue Bourguiba, Dakar', latitude: 14.7088, longitude: -17.4512, category: 'Épicerie' },
  { id: 'st_3', name: 'Boulangerie La Parisienne', type: 'restaurant', rating: 4.6, is_active: true, description: 'Croissants chauds, pains artisanaux et pâtisseries', address: 'Rue Aimé Césaire, Dakar', latitude: 14.6934, longitude: -17.4705, category: 'Boulangerie' },
  { id: 'st_4', name: 'Zara Dakar Boutique', type: 'boutique', rating: 4.5, is_active: true, description: 'Mode vêtements, chaussures et accessoires', address: 'Sea Plaza, Corniche Ouest', latitude: 14.6854, longitude: -17.4721, category: 'Mode' },
])

// Selected Store for catalog tab
const selectedStoreId = ref('st_1')

// Computed Filtered Stores for active category
const filteredStores = computed(() => {
  if (currentType.value === 'restaurant') {
    return stores.value.filter(s => s.type === 'restaurant')
  } else {
    return stores.value.filter(s => s.type === 'boutique' || s.type === 'grocery')
  }
})

// Computed Filtered Orders for active category
const filteredOrders = computed(() => {
  return orders.value.filter(o => {
    const store = stores.value.find(s => s.id === o.store_id)
    if (!store) return false
    if (currentType.value === 'restaurant') {
      return store.type === 'restaurant'
    } else {
      return store.type === 'boutique' || store.type === 'grocery'
    }
  })
})

// Auto-select active store on page switch
watch(currentType, (newType) => {
  const matching = stores.value.filter(s => {
    if (newType === 'restaurant') return s.type === 'restaurant'
    return s.type === 'boutique' || s.type === 'grocery'
  })
  if (matching.length > 0) {
    selectedStoreId.value = matching[0].id
  }
}, { immediate: true })

// Products catalog
const products = ref([
  { id: 'prod_1', store_id: 'st_1', name: 'Couscous Royal Poulet', description: 'Semoule de blé, légumes frais, poulet fermier', price: 4500, is_featured: true, is_deliverable: true, is_active: true },
  { id: 'prod_2', store_id: 'st_1', name: 'Tajine d\'Agneau aux pruneaux', description: 'Agneau fondant, pruneaux caramélisés, amandes grillées', price: 5500, is_featured: false, is_deliverable: true, is_active: true },
  { id: 'prod_3', store_id: 'st_2', name: 'Lait Entier 1L', description: 'Brique de lait UHT longue conservation', price: 900, is_featured: false, is_deliverable: true, is_active: true },
  { id: 'prod_4', store_id: 'st_2', name: 'Café Touba Sac 500g', description: 'Café noir moulu aromatisé au poivre de Selim', price: 1800, is_featured: true, is_deliverable: true, is_active: true },
  { id: 'prod_5', store_id: 'st_3', name: 'Baguette Tradition', description: 'Farine bio, levain naturel cuit sur sole', price: 250, is_featured: false, is_deliverable: true, is_active: true },
  { id: 'prod_6', store_id: 'st_3', name: 'Croissant au Beurre', description: 'Pâte feuilletée pur beurre de baratte', price: 400, is_featured: true, is_deliverable: true, is_active: true },
  { id: 'prod_7', store_id: 'st_4', name: 'Robe d\'été lin', description: 'Robe mi-longue en lin respirant', price: 18500, is_featured: true, is_deliverable: true, is_active: true },
])

// Orders list (Preorders / Boutique precommande)
const orders = ref([
  {
    id: 'ord_1',
    ref_id: 'SO-88409',
    customer_id: 'c_1',
    customer_name: 'Amadou Ba',
    store_id: 'st_1',
    store_name: 'Le Ryad Resto',
    status: 'preparing',
    delivery_type: 'delivery',
    total_fare: 10800,
    pickup_otp: '',
    items: [
      { product_name: 'Couscous Royal Poulet', quantity: 2, price: 4500 }
    ],
    created_at: new Date().toISOString()
  },
  {
    id: 'ord_2',
    ref_id: 'SO-88402',
    customer_id: 'c_2',
    customer_name: 'Aissatou Camara',
    store_id: 'st_3',
    store_name: 'Boulangerie La Parisienne',
    status: 'ready_for_pickup',
    delivery_type: 'pickup',
    total_fare: 1950,
    pickup_otp: '482091',
    items: [
      { product_name: 'Croissant au Beurre', quantity: 4, price: 400 },
      { product_name: 'Baguette Tradition', quantity: 1, price: 250 }
    ],
    created_at: new Date(Date.now() - 3600000).toISOString()
  },
  {
    id: 'ord_3',
    ref_id: 'SO-88390',
    customer_id: 'c_3',
    customer_name: 'Mariama Kouyaté',
    store_id: 'st_4',
    store_name: 'Zara Dakar Boutique',
    status: 'delivered',
    delivery_type: 'delivery',
    total_fare: 19500,
    pickup_otp: '',
    items: [
      { product_name: 'Robe d\'été lin', quantity: 1, price: 18500 }
    ],
    created_at: new Date(Date.now() - 7200000).toISOString()
  }
])

const storeHeaders = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Nom / Description' : 'Store Details' },
  { key: 'type', label: 'Type' },
  { key: 'rating', label: lang.value === 'fr' ? 'Note' : 'Rating' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '220px', textAlign: 'right' } },
])

const productHeaders = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Article' : 'Product Name' },
  { key: 'price', label: lang.value === 'fr' ? 'Prix' : 'Price' },
  { key: 'deliverable', label: lang.value === 'fr' ? 'Livrable' : 'Deliverable' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '220px', textAlign: 'right' } },
])

const orderHeaders = computed(() => [
  { key: 'id', label: 'Reference ID' },
  { key: 'store', label: lang.value === 'fr' ? 'Établissement' : 'Store' },
  { key: 'items', label: t('items') },
  { key: 'total_fare', label: lang.value === 'fr' ? 'Total Payé' : 'Total Fare' },
  { key: 'type', label: lang.value === 'fr' ? 'Type' : 'Delivery Method' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '250px', textAlign: 'right' } },
])

const filteredProducts = computed(() => {
  return products.value.filter(p => p.store_id === selectedStoreId.value)
})

// Modal visibility & forms
const showStoreModal = ref(false)
const showProductModal = ref(false)
const isEditMode = ref(false)
const editingId = ref<string | null>(null)

const storeForm = ref({
  name: '',
  description: '',
  type: 'restaurant' as string,
  category: '',
  latitude: 14.6928,
  longitude: -17.4467,
  address: '',
  is_active: true
})

const productForm = ref({
  name: '',
  description: '',
  price: 500,
  store_id: 'st_1',
  is_featured: false,
  is_deliverable: true,
  is_active: true
})

function openAddModal() {
  isEditMode.value = false
  editingId.value = null
  if (activeTab.value === 'stores') {
    storeForm.value = {
      name: '',
      description: '',
      type: currentType.value === 'restaurant' ? 'restaurant' : 'boutique',
      latitude: 14.6928,
      longitude: -17.4467,
      address: '',
      is_active: true
    }
    showStoreModal.value = true
  } else if (activeTab.value === 'catalog') {
    productForm.value = {
      name: '',
      description: '',
      price: 500,
      store_id: selectedStoreId.value,
      is_featured: false,
      is_deliverable: true,
      is_active: true
    }
    showProductModal.value = true
  }
}

function openEditStoreModal(store: any) {
  isEditMode.value = true
  editingId.value = store.id
  storeForm.value = { ...store }
  showStoreModal.value = true
}

function openEditProductModal(prod: any) {
  isEditMode.value = true
  editingId.value = prod.id
  productForm.value = { ...prod }
  showProductModal.value = true
}

function saveStore() {
  if (isEditMode.value && editingId.value) {
    const idx = stores.value.findIndex(s => s.id === editingId.value)
    if (idx !== -1) stores.value[idx] = { ...stores.value[idx], ...storeForm.value }
  } else {
    stores.value.push({
      id: `st_${Date.now()}`,
      rating: 5.0,
      ...storeForm.value
    })
  }
  showStoreModal.value = false
}

function saveProduct() {
  if (isEditMode.value && editingId.value) {
    const idx = products.value.findIndex(p => p.id === editingId.value)
    if (idx !== -1) products.value[idx] = { ...products.value[idx], ...productForm.value }
  } else {
    products.value.push({
      id: `prod_${Date.now()}`,
      ...productForm.value
    })
  }
  showProductModal.value = false
}

function toggleStoreStatus(store: any) {
  store.is_active = !store.is_active
}

function updateOrderStatus(order: any, event: Event) {
  const nextStatus = (event.target as HTMLSelectElement).value
  order.status = nextStatus
}

function deleteStore(id: string) {
  stores.value = stores.value.filter(s => s.id !== id)
}

function deleteProduct(id: string) {
  products.value = products.value.filter(p => p.id !== id)
}

function deleteOrder(id: string) {
  orders.value = orders.value.filter(o => o.id !== id)
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}
</script>

<style scoped>
.text-left {
  text-align: left;
}

@media (max-width: 640px) {
  .modal-form-grid {
    grid-template-columns: 1fr !important;
    gap: 1rem !important;
  }
  .modal-metrics-grid {
    grid-template-columns: 1fr !important;
    gap: 0.5rem !important;
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

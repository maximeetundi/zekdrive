<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Commandes Commerce' : 'Store Orders' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Toutes les commandes passées sur les restaurants et boutiques' : 'All orders placed on restaurants and shops' }}</p>
      </div>
      <div class="page-actions">
        <select v-model="statusFilter" class="form-input" style="width:auto; padding: 0.5rem 1rem;">
          <option value="">{{ lang === 'fr' ? 'Tous les statuts' : 'All statuses' }}</option>
          <option value="pending">{{ lang === 'fr' ? 'En attente' : 'Pending' }}</option>
          <option value="accepted">{{ lang === 'fr' ? 'Acceptée' : 'Accepted' }}</option>
          <option value="preparing">{{ lang === 'fr' ? 'En préparation' : 'Preparing' }}</option>
          <option value="delivering">{{ lang === 'fr' ? 'En livraison' : 'Delivering' }}</option>
          <option value="delivered">{{ lang === 'fr' ? 'Livrée' : 'Delivered' }}</option>
          <option value="cancelled">{{ lang === 'fr' ? 'Annulée' : 'Cancelled' }}</option>
        </select>
        <select v-model="typeFilter" class="form-input" style="width:auto; padding: 0.5rem 1rem;">
          <option value="">{{ lang === 'fr' ? 'Tous les types' : 'All types' }}</option>
          <option value="restaurant">🍽️ Restaurant</option>
          <option value="boutique">🛍️ {{ lang === 'fr' ? 'Boutique' : 'Shop' }}</option>
          <option value="grocery">🛒 {{ lang === 'fr' ? 'Épicerie' : 'Grocery' }}</option>
          <option value="pharmacy">💊 {{ lang === 'fr' ? 'Pharmacie' : 'Pharmacy' }}</option>
        </select>
      </div>
    </div>

    <!-- Stats Row -->
    <div class="stats-grid animate-fade-in" style="grid-template-columns: repeat(5, 1fr); margin-bottom: 2rem;">
      <AppStatsCard :title="lang === 'fr' ? 'Total commandes' : 'Total Orders'" :value="orders.length.toString()" icon="📋" color="blue" />
      <AppStatsCard :title="lang === 'fr' ? 'En attente' : 'Pending'" :value="countByStatus('pending').toString()" icon="⏳" color="orange" />
      <AppStatsCard :title="lang === 'fr' ? 'En livraison' : 'Delivering'" :value="countByStatus('delivering').toString()" icon="🚴" color="purple" />
      <AppStatsCard :title="lang === 'fr' ? 'Livrées' : 'Delivered'" :value="countByStatus('delivered').toString()" icon="✅" color="green" />
      <AppStatsCard :title="lang === 'fr' ? 'Revenus' : 'Revenue'" :value="totalRevenue + ' XOF'" icon="💰" color="blue" />
    </div>

    <!-- Table -->
    <div class="card animate-slide-up">
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="headers"
          :items="filteredOrders"
          :loading="loading"
          :currentPage="1"
          :perPage="20"
          :totalItems="filteredOrders.length"
          :totalPages="1"
        >
          <template #cell-order="{ item }">
            <div style="text-align: left;">
              <div class="font-semibold text-primary">#{{ item.id.slice(0,8).toUpperCase() }}</div>
              <div class="text-xs text-muted">{{ formatDate(item.created_at) }}</div>
            </div>
          </template>

          <template #cell-store="{ item }">
            <div style="text-align: left;">
              <div class="flex items-center gap-2">
                <span>{{ storeIcon(item.store_type) }}</span>
                <span class="font-semibold">{{ item.store_name }}</span>
              </div>
              <div class="text-xs text-muted">{{ item.store_type }}</div>
            </div>
          </template>

          <template #cell-customer="{ item }">
            <div style="text-align: left;">
              <div class="font-semibold">{{ item.customer_name }}</div>
              <div class="text-xs text-muted">{{ item.customer_phone }}</div>
            </div>
          </template>

          <template #cell-items="{ item }">
            <div style="text-align: left; font-size: 0.8rem; color: var(--text-secondary);">
              <div v-for="(line, i) in item.items.slice(0,2)" :key="i">{{ line.qty }}× {{ line.name }}</div>
              <div v-if="item.items.length > 2" class="text-xs text-muted">+{{ item.items.length - 2 }} {{ lang === 'fr' ? 'autres' : 'more' }}</div>
            </div>
          </template>

          <template #cell-amount="{ item }">
            <span class="font-semibold text-primary">{{ item.total.toLocaleString() }} XOF</span>
          </template>

          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status" />
          </template>

          <template #cell-courier="{ item }">
            <span v-if="item.courier_name" class="text-sm">{{ item.courier_name }}</span>
            <span v-else class="text-xs text-muted">—</span>
          </template>

          <template #cell-actions="{ item }">
            <div class="flex gap-2 justify-end">
              <button class="btn btn-secondary btn-sm" @click="openDetail(item)">
                {{ lang === 'fr' ? 'Détail' : 'Detail' }}
              </button>
              <button v-if="item.status === 'pending'" class="btn btn-primary btn-sm" @click="forceAccept(item)">
                {{ lang === 'fr' ? 'Forcer' : 'Force' }}
              </button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Detail Modal -->
    <AppModal :show="!!selectedOrder" :title="lang === 'fr' ? 'Détail commande' : 'Order Detail'" @close="selectedOrder = null">
      <div v-if="selectedOrder" style="text-align:left;">
        <!-- Store + Customer -->
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:1rem; margin-bottom:1.5rem;">
          <div class="card" style="padding:1rem;">
            <div class="text-xs text-muted" style="margin-bottom:0.5rem;">{{ lang === 'fr' ? 'Commerce' : 'Store' }}</div>
            <div class="font-semibold">{{ storeIcon(selectedOrder.store_type) }} {{ selectedOrder.store_name }}</div>
            <div class="text-xs text-muted">{{ selectedOrder.store_address }}</div>
          </div>
          <div class="card" style="padding:1rem;">
            <div class="text-xs text-muted" style="margin-bottom:0.5rem;">{{ lang === 'fr' ? 'Client' : 'Customer' }}</div>
            <div class="font-semibold">{{ selectedOrder.customer_name }}</div>
            <div class="text-xs text-muted">{{ selectedOrder.customer_phone }}</div>
            <div class="text-xs text-muted">{{ selectedOrder.delivery_address }}</div>
          </div>
        </div>

        <!-- Items -->
        <div style="margin-bottom:1.5rem;">
          <div class="text-xs text-muted" style="margin-bottom:0.75rem; font-weight:600; text-transform:uppercase;">{{ lang === 'fr' ? 'Articles commandés' : 'Ordered Items' }}</div>
          <div v-for="item in selectedOrder.items" :key="item.name" style="display:flex; justify-content:space-between; padding:0.5rem 0; border-bottom:1px solid var(--border-color); font-size:0.875rem;">
            <span>{{ item.qty }}× {{ item.name }}</span>
            <span class="font-semibold">{{ (item.qty * item.price).toLocaleString() }} XOF</span>
          </div>
          <div style="display:flex; justify-content:space-between; padding:0.75rem 0; font-weight:700;">
            <span>Total</span>
            <span class="text-primary">{{ selectedOrder.total.toLocaleString() }} XOF</span>
          </div>
        </div>

        <!-- Status + Courier -->
        <div style="display:flex; gap:1rem; align-items:center;">
          <AppStatusBadge :status="selectedOrder.status" />
          <span v-if="selectedOrder.courier_name" class="text-sm text-muted">🚴 {{ selectedOrder.courier_name }}</span>
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
const { get } = useApi()
const loading = ref(false)
const statusFilter = ref('')
const typeFilter = ref('')
const selectedOrder = ref<any>(null)

interface OrderItem { name: string; qty: number; price: number }
interface Order {
  id: string; store_name: string; store_type: string; store_address: string;
  customer_name: string; customer_phone: string; delivery_address: string;
  items: OrderItem[]; total: number; status: string; courier_name?: string;
  created_at: string;
}

const orders = ref<Order[]>([
  {
    id: 'ord-001-a2b3c4d5', store_name: 'Chez Mamie Fatou', store_type: 'restaurant', store_address: 'Plateau, Dakar',
    customer_name: 'Ibrahima Diallo', customer_phone: '+221 77 111 22 33', delivery_address: 'Almadies Rue 10',
    items: [{ name: 'Thiéboudienne', qty: 2, price: 3500 }, { name: 'Bissap', qty: 2, price: 500 }],
    total: 8000, status: 'delivering', courier_name: 'Cheikh Fall', created_at: new Date(Date.now() - 1800000).toISOString()
  },
  {
    id: 'ord-002-e5f6g7h8', store_name: 'Boutique Mode Dakar', store_type: 'boutique', store_address: 'Sandaga, Dakar',
    customer_name: 'Aissatou Ndiaye', customer_phone: '+221 78 444 55 66', delivery_address: 'Mermoz, Dakar',
    items: [{ name: 'Robe Bazin bleue', qty: 1, price: 25000 }, { name: 'Ceinture cuir', qty: 1, price: 5000 }],
    total: 30000, status: 'accepted', created_at: new Date(Date.now() - 3600000).toISOString()
  },
  {
    id: 'ord-003-i9j0k1l2', store_name: 'PharmaDakar Express', store_type: 'pharmacy', store_address: 'Point E, Dakar',
    customer_name: 'Ousmane Sow', customer_phone: '+221 70 777 88 99', delivery_address: 'Fann Résidence',
    items: [{ name: 'Paracétamol 1g', qty: 2, price: 1500 }, { name: 'Vitamine C', qty: 1, price: 3000 }],
    total: 6000, status: 'delivered', courier_name: 'Moussa Diop', created_at: new Date(Date.now() - 7200000).toISOString()
  },
  {
    id: 'ord-004-m3n4o5p6', store_name: 'Super Épicerie Hann', store_type: 'grocery', store_address: 'Hann, Dakar',
    customer_name: 'Mariama Ba', customer_phone: '+221 76 222 33 44', delivery_address: 'Sicap Liberté 4',
    items: [{ name: 'Riz 5kg', qty: 1, price: 5000 }, { name: 'Huile 1L', qty: 2, price: 1500 }, { name: 'Sucre 2kg', qty: 1, price: 2000 }],
    total: 10000, status: 'pending', created_at: new Date(Date.now() - 600000).toISOString()
  },
  {
    id: 'ord-005-q7r8s9t0', store_name: 'Chez Mamie Fatou', store_type: 'restaurant', store_address: 'Plateau, Dakar',
    customer_name: 'Fatou Kane', customer_phone: '+221 77 999 00 11', delivery_address: 'Ouakam',
    items: [{ name: 'Yassa Poulet', qty: 1, price: 4000 }, { name: 'Thiakry', qty: 1, price: 1500 }],
    total: 5500, status: 'cancelled', created_at: new Date(Date.now() - 86400000).toISOString()
  },
])

onMounted(async () => {
  loading.value = true
  const res = await get<Order[]>('/api/admin/store-orders')
  if (res.data && res.data.length) orders.value = res.data
  loading.value = false
})

const filteredOrders = computed(() => orders.value.filter(o => {
  if (statusFilter.value && o.status !== statusFilter.value) return false
  if (typeFilter.value && o.store_type !== typeFilter.value) return false
  return true
}))

const countByStatus = (s: string) => orders.value.filter(o => o.status === s).length
const totalRevenue = computed(() =>
  orders.value.filter(o => o.status === 'delivered').reduce((sum, o) => sum + o.total, 0).toLocaleString()
)

const headers = computed(() => [
  { key: 'order', label: lang.value === 'fr' ? 'Commande' : 'Order' },
  { key: 'store', label: lang.value === 'fr' ? 'Commerce' : 'Store' },
  { key: 'customer', label: lang.value === 'fr' ? 'Client' : 'Customer' },
  { key: 'items', label: lang.value === 'fr' ? 'Articles' : 'Items' },
  { key: 'amount', label: lang.value === 'fr' ? 'Montant' : 'Amount' },
  { key: 'status', label: 'Statut' },
  { key: 'courier', label: lang.value === 'fr' ? 'Livreur' : 'Courier' },
  { key: 'actions', label: '', style: { width: '140px', textAlign: 'right' } },
])

function storeIcon(type: string) {
  const icons: Record<string, string> = { restaurant: '🍽️', boutique: '🛍️', grocery: '🛒', pharmacy: '💊', other: '🏪' }
  return icons[type] ?? '🏪'
}

function formatDate(d: string) {
  return new Date(d).toLocaleString(lang.value === 'fr' ? 'fr-FR' : 'en-GB', { dateStyle: 'short', timeStyle: 'short' })
}

function openDetail(order: any) { selectedOrder.value = order }

function forceAccept(order: any) {
  const idx = orders.value.findIndex(o => o.id === order.id)
  if (idx !== -1) orders.value[idx].status = 'accepted'
}
</script>

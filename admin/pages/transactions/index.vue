<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Registre des transactions' : 'Transactions Ledger' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Consulter les journaux de paiement, les commissions de la plateforme, les modes de règlement et exporter les rapports' : 'Review payments logs, platform commissions, gateway methods, and export ledgers' }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-secondary flex items-center gap-2" @click="exportCSV">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          <span>{{ lang === 'fr' ? 'Exporter en CSV' : 'Export CSV Ledger' }}</span>
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div class="card animate-fade-in" style="margin-bottom: 1.5rem; padding: 1rem;">
      <div class="filter-bar">
        <!-- Search -->
        <div style="flex: 1; min-width: 240px;">
          <input
            v-model="search"
            type="text"
            class="form-input"
            :placeholder="lang === 'fr' ? 'Rechercher par ID transaction, nom client, réf course...' : 'Search by txn ID, client name, or trip ref...'"
          />
        </div>

        <!-- Payment Method Filter -->
        <div style="width: 170px;">
          <select v-model="methodFilter" class="form-select">
            <option value="">{{ lang === 'fr' ? 'Tous les paiements' : 'All Payment Types' }}</option>
            <option value="wave">Wave Mobile</option>
            <option value="orange_money">Orange Money</option>
            <option value="cash">{{ lang === 'fr' ? 'Espèces' : 'Cash Payment' }}</option>
            <option value="card">{{ lang === 'fr' ? 'Carte bancaire' : 'Credit Card' }}</option>
          </select>
        </div>

        <!-- Status Filter -->
        <div style="width: 170px;">
          <select v-model="statusFilter" class="form-select">
            <option value="">{{ lang === 'fr' ? 'Tous les statuts' : 'All Statuses' }}</option>
            <option value="success">{{ lang === 'fr' ? 'Réussi' : 'Success' }}</option>
            <option value="pending">{{ lang === 'fr' ? 'En cours' : 'Pending' }}</option>
            <option value="failed">{{ lang === 'fr' ? 'Échoué' : 'Failed' }}</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">{{ t('reset') }}</button>
      </div>
    </div>

    <!-- Transactions Data Table -->
    <div class="card animate-slide-up">
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="headers"
          :items="filteredTransactions"
          :loading="loading"
          :currentPage="1"
          :perPage="30"
          :totalItems="filteredTransactions.length"
          :totalPages="1"
        >
          <!-- Transaction Reference -->
          <template #cell-id="{ item }">
            <span class="font-bold text-primary">{{ item.id }}</span>
          </template>

          <template #cell-trip_ref="{ item }">
            <span class="text-xs font-semibold text-accent">{{ item.trip_ref }}</span>
          </template>

          <template #cell-amount="{ item }">
            <span class="font-semibold text-primary">{{ formatCurrency(item.amount) }}</span>
          </template>

          <template #cell-method="{ item }">
            <span class="text-xs text-primary" style="text-transform: uppercase;">
              {{ item.method.replace('_', ' ') }}
            </span>
          </template>

          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status" />
          </template>

          <template #cell-created_at="{ item }">
            <span>{{ formatDateTime(item.created_at) }}</span>
          </template>
        </AppDataTable>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const { t, lang } = useI18n()
const loading = ref(false)

const search = ref('')
const methodFilter = ref('')
const statusFilter = ref('')

const transactions = ref(Array.from({ length: 45 }, (_, i) => {
  const methods = ['orange_money', 'wave', 'cash', 'card']
  const statuses = ['success', 'success', 'success', 'pending', 'failed']
  const customers = ['Amadou Ba', 'Fatoumata Diallo', 'Moussa Sow', 'Aissatou Camara', 'Omar Traoré', 'Mariama Kouyaté']
  const drivers = ['Seydou Keita', 'Lamine Koné', 'Boubacar Diarra', 'Abdoulaye Cissé', 'Mamadou Barry']
  
  return {
    id: `TX-${String(100500 + i)}`,
    trip_ref: `ZD-${String(1000 + i).padStart(5, '0')}`,
    customer_name: customers[i % customers.length],
    driver_name: drivers[i % drivers.length],
    amount: Math.floor(Math.random() * 8000 + 1000),
    method: methods[i % methods.length],
    status: statuses[i % statuses.length] as 'success' | 'pending' | 'failed',
    created_at: new Date(Date.now() - i * 1800000 * 3).toISOString()
  }
}))

const headers = computed(() => [
  { key: 'id', label: lang.value === 'fr' ? 'ID Transaction' : 'Transaction ID' },
  { key: 'trip_ref', label: lang.value === 'fr' ? 'Référence Course' : 'Trip Reference' },
  { key: 'customer_name', label: lang.value === 'fr' ? 'Client' : 'Customer' },
  { key: 'driver_name', label: lang.value === 'fr' ? 'Chauffeur' : 'Driver' },
  { key: 'amount', label: lang.value === 'fr' ? 'Montant Payé' : 'Amount Paid' },
  { key: 'method', label: lang.value === 'fr' ? 'Mode de paiement' : 'Payment Gateway' },
  { key: 'status', label: lang.value === 'fr' ? 'Statut Passerelle' : 'Gateway Status' },
  { key: 'created_at', label: lang.value === 'fr' ? 'Date d\'exécution' : 'Execution Date' }
])

const filteredTransactions = computed(() => {
  return transactions.value.filter(t => {
    const q = search.value.toLowerCase()
    const matchesSearch =
      t.id.toLowerCase().includes(q) ||
      t.trip_ref.toLowerCase().includes(q) ||
      t.customer_name.toLowerCase().includes(q) ||
      t.driver_name.toLowerCase().includes(q)
      
    const matchesMethod = !methodFilter.value || t.method === methodFilter.value
    const matchesStatus = !statusFilter.value || t.status === statusFilter.value
    
    return matchesSearch && matchesMethod && matchesStatus
  })
})

function clearFilters() {
  search.value = ''
  methodFilter.value = ''
  statusFilter.value = ''
}

function exportCSV() {
  // Construct CSV Header
  const headersRow = lang.value === 'fr' 
    ? ['ID Transaction', 'Référence Course', 'Client', 'Chauffeur', 'Montant (FCFA)', 'Mode de Paiement', 'Statut', 'Date']
    : ['Transaction ID', 'Trip Reference', 'Customer', 'Driver', 'Amount (FCFA)', 'Payment Method', 'Status', 'Date']
  
  // Construct CSV Rows
  const rows = filteredTransactions.value.map(t => [
    t.id,
    t.trip_ref,
    t.customer_name,
    t.driver_name,
    t.amount,
    t.method,
    t.status,
    t.created_at
  ])

  const csvContent = [
    headersRow.join(','),
    ...rows.map(r => r.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(','))
  ].join('\n')

  // Create client-side file trigger
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  if (link.download !== undefined) {
    const url = URL.createObjectURL(blob)
    link.setAttribute('href', url)
    link.setAttribute('download', `zekdrive-transactions-export-${new Date().toISOString().split('T')[0]}.csv`)
    link.style.visibility = 'hidden'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}

function formatDateTime(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
  } catch {
    return dateStr
  }
}
</script>

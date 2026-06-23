<template>
  <div>
    <!-- Table Wrapper -->
    <div class="table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th v-for="header in headers" :key="header.key" :style="header.style">
              {{ header.label }}
            </th>
          </tr>
        </thead>
        <tbody>
          <!-- Loading State Skeletons -->
          <template v-if="loading">
            <tr v-for="n in 5" :key="'skeleton-' + n">
              <td v-for="header in headers" :key="'col-' + header.key">
                <div class="skeleton" style="height: 1.25rem; width: 80%; border-radius: 4px;"></div>
              </td>
            </tr>
          </template>
          
          <!-- Empty State -->
          <tr v-else-if="items.length === 0">
            <td :colspan="headers.length">
              <div class="empty-state" style="padding: 3rem 1rem;">
                <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="margin: 0 auto 1rem; color: var(--text-muted);">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="8" y1="12" x2="16" y2="12"></line>
                </svg>
                <h4>No data available</h4>
                <p>Try modifying your search or filters.</p>
              </div>
            </td>
          </tr>
          
          <!-- Item Rows -->
          <template v-else>
            <tr v-for="(item, index) in items" :key="item.id || index">
              <td v-for="header in headers" :key="header.key" :style="header.style">
                <slot :name="'cell-' + header.key" :item="item" :index="index">
                  {{ item[header.key] }}
                </slot>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="pagination animate-fade-in">
      <div class="pagination-info">
        Showing <strong>{{ rangeStart }}</strong> to <strong>{{ rangeEnd }}</strong> of <strong>{{ totalItems }}</strong> items
      </div>
      <div class="pagination-controls">
        <button class="page-btn" :disabled="currentPage === 1" @click="changePage(currentPage - 1)">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="15 18 9 12 15 6"></polyline>
          </svg>
        </button>
        
        <button v-for="p in visiblePages" :key="p" class="page-btn" :class="{ active: p === currentPage }" @click="changePage(p)">
          {{ p }}
        </button>
        
        <button class="page-btn" :disabled="currentPage === totalPages" @click="changePage(currentPage + 1)">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  headers: {
    type: Array as () => Array<{ key: string; label: string; style?: Record<string, string> }>,
    required: true,
  },
  items: {
    type: Array as () => Array<any>,
    required: true,
  },
  loading: {
    type: Boolean,
    default: false,
  },
  currentPage: {
    type: Number,
    default: 1,
  },
  perPage: {
    type: Number,
    default: 15,
  },
  totalItems: {
    type: Number,
    default: 0,
  },
  totalPages: {
    type: Number,
    default: 1,
  },
})

const emit = defineEmits(['update:page'])

const rangeStart = computed(() => {
  if (props.totalItems === 0) return 0
  return (props.currentPage - 1) * props.perPage + 1
})

const rangeEnd = computed(() => {
  return Math.min(props.currentPage * props.perPage, props.totalItems)
})

const visiblePages = computed(() => {
  const pages: number[] = []
  const maxVisible = 5
  let start = Math.max(1, props.currentPage - 2)
  let end = Math.min(props.totalPages, start + maxVisible - 1)

  if (end - start + 1 < maxVisible) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

function changePage(p: number) {
  if (p >= 1 && p <= props.totalPages) {
    emit('update:page', p)
  }
}
</script>

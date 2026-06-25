<template>
  <div class="chart-container" style="position: relative; width: 100%; height: 300px;">
    <Line v-if="loaded" :data="chartData" :options="chartOptions" />
    <div v-else class="flex justify-center items-center h-full">
      <div class="skeleton" style="width: 100%; height: 100%; border-radius: var(--radius-md);"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
  Filler,
} from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, LineElement, PointElement, CategoryScale, LinearScale, Filler)

interface RevenuePoint {
  date: string
  revenue: number
  trips: number
}

const props = defineProps({
  points: {
    type: Array as () => RevenuePoint[],
    default: () => [],
  },
})

const loaded = ref(false)

onMounted(() => {
  loaded.value = true
})

const chartData = computed(() => {
  // Take last 7 or 15 days if list is long, let's show up to 15 points for legibility
  const dataPoints = props.points.slice(-15)
  const labels = dataPoints.map(p => {
    // Format date string (YYYY-MM-DD) to short format (e.g. Jun 15)
    try {
      const parts = p.date.split('-')
      if (parts.length === 3) {
        const dateObj = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]))
        return dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
      }
    } catch {}
    return p.date
  })
  
  const revenues = dataPoints.map(p => p.revenue)

  return {
    labels,
    datasets: [
      {
        label: 'Daily Revenue (FCFA)',
        data: revenues,
        borderColor: '#14b19e',
        backgroundColor: 'rgba(20, 177, 158, 0.1)',
        borderWidth: 3,
        tension: 0.4,
        fill: true,
        pointBackgroundColor: '#14b19e',
        pointBorderColor: 'rgba(255, 255, 255, 0.8)',
        pointHoverRadius: 6,
        pointHoverBackgroundColor: '#00d4aa',
      },
    ],
  }
})

const chartOptions = computed(() => {
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        backgroundColor: '#16181f',
        titleColor: '#f8f9fa',
        bodyColor: '#f8f9fa',
        borderColor: 'rgba(255, 255, 255, 0.08)',
        borderWidth: 1,
        padding: 10,
        cornerRadius: 8,
        displayColors: false,
        callbacks: {
          label: function (context: any) {
            let label = context.dataset.label || ''
            if (label) {
              label += ': '
            }
            if (context.parsed.y !== null) {
              label += new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(context.parsed.y)
            }
            return label
          },
        },
      },
    },
    scales: {
      x: {
        grid: {
          color: 'rgba(255, 255, 255, 0.03)',
        },
        ticks: {
          color: 'rgba(248, 249, 250, 0.5)',
          font: {
            family: 'Inter',
            size: 11,
          },
        },
      },
      y: {
        grid: {
          color: 'rgba(255, 255, 255, 0.03)',
        },
        ticks: {
          color: 'rgba(248, 249, 250, 0.5)',
          font: {
            family: 'Inter',
            size: 11,
          },
          callback: function (value: any) {
            if (value >= 1e6) return (value / 1e6).toFixed(1) + 'M'
            if (value >= 1e3) return (value / 1e3).toFixed(0) + 'k'
            return value
          },
        },
      },
    },
  }
})
</script>

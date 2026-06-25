<script setup lang="ts">
import { ref, computed } from 'vue'
import { useLanguage } from '~/composables/useLanguage'

const { t } = useLanguage()

const faqs = computed(() => [
  {
    q: t('faq.q1_q'),
    a: t('faq.q1_a'),
  },
  {
    q: t('faq.q2_q'),
    a: t('faq.q2_a'),
  },
  {
    q: t('faq.q3_q'),
    a: t('faq.q3_a'),
  },
  {
    q: t('faq.q4_q'),
    a: t('faq.q4_a'),
  },
  {
    q: t('faq.q5_q'),
    a: t('faq.q5_a'),
  },
  {
    q: t('faq.q6_q'),
    a: t('faq.q6_a'),
  },
  {
    q: t('faq.q7_q'),
    a: t('faq.q7_a'),
  },
  {
    q: t('faq.q8_q'),
    a: t('faq.q8_a'),
  },
])

const openIndex = ref<number | null>(null)

function toggle(i: number) {
  openIndex.value = openIndex.value === i ? null : i
}

function getMaxHeight(i: number) {
  return openIndex.value === i ? '400px' : '0'
}
</script>

<template>
  <section class="section" style="position:relative;overflow:hidden;">
    <div class="orb orb-violet" style="width:400px;height:400px;right:-100px;top:0;opacity:0.3;" />

    <div class="container" style="position:relative;z-index:1;">
      <div class="section-header centered fade-up">
        <div class="section-tag">{{ t('faq.tag') }}</div>
        <h2 class="section-title">{{ t('faq.title_1') }}<span class="gradient-text">{{ t('faq.title_highlight') }}</span></h2>
        <p class="section-subtitle">{{ t('faq.subtitle') }}</p>
      </div>

      <div class="faq-list fade-up">
        <div
          v-for="(faq, i) in faqs"
          :key="i"
          class="faq-item"
          :class="{ open: openIndex === i }"
        >
          <button class="faq-question" @click="toggle(i)">
            {{ faq.q }}
            <div class="faq-icon">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M12 5v14M5 12h14"/>
              </svg>
            </div>
          </button>
          <div
            class="faq-answer"
            :style="{ maxHeight: getMaxHeight(i) }"
          >
            <div class="faq-answer-inner">{{ faq.a }}</div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

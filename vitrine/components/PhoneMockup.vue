<template>
  <div class="phone-wrapper">
    <svg
      width="280"
      height="560"
      viewBox="0 0 280 560"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <!-- Phone frame -->
      <rect x="8" y="8" width="264" height="544" rx="40" fill="url(#phoneGrad)" stroke="url(#frameGrad)" stroke-width="1.5"/>
      
      <!-- Screen area -->
      <rect x="16" y="16" width="248" height="528" rx="34" fill="#0a0e1a"/>
      
      <!-- Notch/Camera island -->
      <rect x="100" y="24" width="80" height="24" rx="12" fill="#0d1220"/>
      <circle cx="156" cy="36" r="5" fill="#1a1f35"/>
      <circle cx="156" cy="36" r="2.5" fill="#0a0e1a"/>

      <!-- Status bar -->
      <text x="28" y="50" font-family="Inter,sans-serif" font-size="11" fill="rgba(248,250,252,0.7)">9:41</text>
      <g transform="translate(212, 40)">
        <rect x="0" y="0" width="18" height="10" rx="2" stroke="rgba(248,250,252,0.5)" stroke-width="1.2" fill="none"/>
        <rect x="1.5" y="1.5" width="12" height="7" rx="1" fill="url(#battGrad)"/>
        <rect x="18.5" y="3" width="2" height="4" rx="1" fill="rgba(248,250,252,0.3)"/>
        <rect x="30" y="1" width="10" height="8" rx="2" fill="rgba(248,250,252,0.5)"/>
        <rect x="24" y="2.5" width="5" height="5" rx="1" fill="rgba(248,250,252,0.5)"/>
      </g>

      <!-- Map background (gradient) -->
      <rect x="16" y="58" width="248" height="350" rx="4" fill="url(#mapGrad)"/>
      
      <!-- Map grid lines (streets) -->
      <!-- Horizontal streets -->
      <line x1="16" y1="100" x2="264" y2="100" stroke="rgba(255,255,255,0.05)" stroke-width="8"/>
      <line x1="16" y1="150" x2="264" y2="150" stroke="rgba(255,255,255,0.05)" stroke-width="8"/>
      <line x1="16" y1="200" x2="264" y2="200" stroke="rgba(255,255,255,0.07)" stroke-width="12"/>
      <line x1="16" y1="260" x2="264" y2="260" stroke="rgba(255,255,255,0.05)" stroke-width="8"/>
      <line x1="16" y1="320" x2="264" y2="320" stroke="rgba(255,255,255,0.05)" stroke-width="8"/>
      
      <!-- Vertical streets -->
      <line x1="70" y1="58" x2="70" y2="408" stroke="rgba(255,255,255,0.05)" stroke-width="8"/>
      <line x1="140" y1="58" x2="140" y2="408" stroke="rgba(255,255,255,0.07)" stroke-width="12"/>
      <line x1="200" y1="58" x2="200" y2="408" stroke="rgba(255,255,255,0.05)" stroke-width="8"/>

      <!-- Block fills (buildings) -->
      <rect x="24" y="106" width="38" height="36" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="78" y="106" width="54" height="36" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="148" y="106" width="44" height="36" rx="4" fill="rgba(255,255,255,0.03)"/>
      <rect x="208" y="106" width="48" height="36" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="24" y="156" width="38" height="36" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="78" y="156" width="54" height="36" rx="4" fill="rgba(255,255,255,0.03)"/>
      <rect x="148" y="156" width="44" height="36" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="208" y="156" width="48" height="36" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="24" y="210" width="38" height="40" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="78" y="210" width="54" height="40" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="148" y="210" width="44" height="40" rx="4" fill="rgba(255,255,255,0.03)"/>
      <rect x="208" y="210" width="48" height="40" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="24" y="268" width="38" height="44" rx="4" fill="rgba(255,255,255,0.03)"/>
      <rect x="78" y="268" width="54" height="44" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="148" y="268" width="44" height="44" rx="4" fill="rgba(255,255,255,0.04)"/>
      <rect x="208" y="268" width="48" height="44" rx="4" fill="rgba(255,255,255,0.03)"/>

      <!-- Route path (gradient highlight) -->
      <path
        d="M 70 350 L 70 200 L 140 200 L 140 150 L 200 150"
        stroke="url(#routeGrad)"
        stroke-width="5"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
        stroke-dasharray="8 4"
      />
      <path
        d="M 70 350 L 70 200 L 140 200 L 140 150 L 200 150"
        stroke="url(#routeGrad)"
        stroke-width="8"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
        opacity="0.3"
      />

      <!-- Pickup marker (teal) -->
      <circle cx="70" cy="350" r="10" fill="#00e5cc" opacity="0.2"/>
      <circle cx="70" cy="350" r="6" fill="#00e5cc"/>
      <circle cx="70" cy="350" r="3" fill="white"/>

      <!-- Dropoff marker (violet) -->
      <g transform="translate(192, 132)">
        <path d="M8 0C3.58 0 0 3.58 0 8c0 5.25 8 16 8 16s8-10.75 8-16c0-4.42-3.58-8-8-8zm0 11c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z" fill="#7c3aed"/>
        <circle cx="8" cy="8" r="3" fill="white"/>
      </g>

      <!-- Moving car icon with animation -->
      <g class="car-icon">
        <animateTransform
          attributeName="transform"
          type="translate"
          values="62,342; 62,202; 132,202; 132,142; 192,142"
          keyTimes="0; 0.3; 0.5; 0.7; 1"
          dur="4s"
          repeatCount="indefinite"
          calcMode="linear"
        />
        <rect x="-12" y="-8" width="24" height="16" rx="4" fill="url(#carGrad)"/>
        <rect x="-8" y="-14" width="16" height="10" rx="2" fill="url(#carGrad)" opacity="0.8"/>
        <circle cx="-7" cy="8" r="4" fill="#1a1f35"/>
        <circle cx="-7" cy="8" r="2" fill="#2a2f45"/>
        <circle cx="7" cy="8" r="4" fill="#1a1f35"/>
        <circle cx="7" cy="8" r="2" fill="#2a2f45"/>
        <rect x="-5" y="-12" width="4" height="3" rx="1" fill="rgba(255,220,100,0.6)"/>
        <rect x="1" y="-12" width="4" height="3" rx="1" fill="rgba(255,220,100,0.6)"/>
      </g>

      <!-- User location pulse -->
      <circle cx="70" cy="350" r="18" fill="rgba(0,229,204,0.1)">
        <animate attributeName="r" values="10;20;10" dur="3s" repeatCount="indefinite"/>
        <animate attributeName="opacity" values="0.4;0;0.4" dur="3s" repeatCount="indefinite"/>
      </circle>

      <!-- ETA Bottom Card -->
      <rect x="20" y="400" width="240" height="90" rx="16" fill="url(#cardGrad)" stroke="rgba(255,255,255,0.08)" stroke-width="1"/>
      
      <!-- Divider line in card -->
      <line x1="130" y1="418" x2="130" y2="472" stroke="rgba(255,255,255,0.08)" stroke-width="1"/>
      
      <!-- ETA info left -->
      <text x="40" y="432" font-family="Inter,sans-serif" font-size="10" fill="rgba(248,250,252,0.5)">ARRIVÉE</text>
      <text x="40" y="452" font-family="Sora,sans-serif" font-weight="700" font-size="22" fill="white">3 min</text>
      <text x="40" y="470" font-family="Inter,sans-serif" font-size="11" fill="rgba(248,250,252,0.5)">2.4 km de distance</text>
      
      <!-- Price info right -->
      <text x="148" y="432" font-family="Inter,sans-serif" font-size="10" fill="rgba(248,250,252,0.5)">TARIF</text>
      <text x="148" y="452" font-family="Sora,sans-serif" font-weight="700" font-size="18" fill="url(#priceGrad)">1 200 F</text>
      <text x="148" y="470" font-family="Inter,sans-serif" font-size="11" fill="rgba(248,250,252,0.5)">CFA estimé</text>

      <!-- Confirm button -->
      <rect x="24" y="500" width="232" height="36" rx="18" fill="url(#btnGrad)"/>
      <text x="140" y="522" font-family="Sora,sans-serif" font-weight="600" font-size="13" fill="white" text-anchor="middle">Confirmer la course</text>

      <!-- App header bar -->
      <rect x="16" y="58" width="248" height="48" rx="4" fill="url(#headerGrad)"/>
      <text x="36" y="87" font-family="Sora,sans-serif" font-weight="700" font-size="15" fill="white">Où allons-nous ?</text>
      <rect x="160" y="70" width="80" height="26" rx="13" fill="rgba(124,58,237,0.2)" stroke="rgba(124,58,237,0.3)" stroke-width="1"/>
      <text x="200" y="88" font-family="Inter,sans-serif" font-size="11" fill="#a855f7" text-anchor="middle">VTC ▾</text>

      <!-- Gradient definitions -->
      <defs>
        <linearGradient id="phoneGrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#1a1f35"/>
          <stop offset="100%" stop-color="#0d1120"/>
        </linearGradient>
        <linearGradient id="frameGrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="rgba(124,58,237,0.5)"/>
          <stop offset="100%" stop-color="rgba(0,229,204,0.3)"/>
        </linearGradient>
        <radialGradient id="mapGrad" cx="50%" cy="50%">
          <stop offset="0%" stop-color="#0f1628"/>
          <stop offset="100%" stop-color="#080b14"/>
        </radialGradient>
        <linearGradient id="routeGrad" x1="0" y1="1" x2="1" y2="0">
          <stop offset="0%" stop-color="#00e5cc"/>
          <stop offset="100%" stop-color="#7c3aed"/>
        </linearGradient>
        <linearGradient id="carGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#a855f7"/>
          <stop offset="100%" stop-color="#7c3aed"/>
        </linearGradient>
        <linearGradient id="cardGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#141929"/>
          <stop offset="100%" stop-color="#0d1120"/>
        </linearGradient>
        <linearGradient id="priceGrad" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#a855f7"/>
          <stop offset="100%" stop-color="#00e5cc"/>
        </linearGradient>
        <linearGradient id="btnGrad" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#7c3aed"/>
          <stop offset="100%" stop-color="#00e5cc"/>
        </linearGradient>
        <linearGradient id="battGrad" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#00e5cc"/>
          <stop offset="100%" stop-color="#7c3aed"/>
        </linearGradient>
        <linearGradient id="headerGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#111828" stop-opacity="1"/>
          <stop offset="100%" stop-color="#111828" stop-opacity="0"/>
        </linearGradient>
      </defs>
    </svg>
  </div>
</template>

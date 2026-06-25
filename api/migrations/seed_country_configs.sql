-- Seed country_configs for ALL countries
-- Prix adaptés au niveau de vie local + devise de chaque pays
-- Exemple : course 5km → environ 5-8 minutes en voiture en zone urbaine

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Zone UEMOA (XOF) — revenu moyen ~200 USD/mois
-- 1 USD ≈ 600 XOF
-- ═══════════════════════════════════════════════════════
INSERT INTO country_configs (country_code,base_fare,per_km_rate,per_min_rate,min_fare,airport_surcharge,delivery_base,delivery_per_km,delivery_min,commission_ride,commission_delivery,commission_store,service_fee,driver_bonus_bronze,driver_bonus_silver,driver_bonus_gold,payment_cash,payment_mobile_money,payment_card,mobile_money_providers,vat_rate,driver_age_min,notes)
VALUES
-- Sénégal (déjà seedé — ON CONFLICT pour mettre à jour)
('SN',500,300,50,500,2000,300,150,300,20,18,15,100,5000,12000,25000,TRUE,TRUE,FALSE,'orange_money,wave,free_money',18,21,'Marché principal. Dakar zone 1.'),
-- Côte d'Ivoire
('CI',600,350,60,600,2500,350,175,350,20,18,15,100,6000,14000,28000,TRUE,TRUE,FALSE,'orange_money,mtn_money,moov_money',18,21,'Abidjan. Fort trafic.'),
-- Mali
('ML',450,280,45,450,1800,280,140,280,20,18,15,75,4500,10000,20000,TRUE,TRUE,FALSE,'orange_money,moov_money',18,21,'Bamako. Infrastructure variable.'),
-- Burkina Faso
('BF',400,250,40,400,1500,250,125,250,18,15,12,75,4000,9000,18000,TRUE,TRUE,FALSE,'orange_money,moov_money',18,21,'Ouagadougou. Marché émergent.'),
-- Togo
('TG',450,280,45,450,1800,280,140,280,18,15,12,75,4500,10000,20000,TRUE,TRUE,FALSE,'togocel_money,moov_money',18,21,'Lomé. Port actif.'),
-- Bénin
('BJ',400,260,42,400,1600,260,130,260,18,15,12,75,4000,9000,18000,TRUE,TRUE,FALSE,'mtn_money,moov_money',18,21,'Cotonou.'),
-- Niger
('NE',380,240,38,380,1500,240,120,240,18,15,12,50,3500,8000,16000,TRUE,TRUE,FALSE,'airtel_money',18,21,'Niamey.'),
-- Guinée-Bissau
('GW',380,230,38,380,1400,230,115,230,18,15,12,50,3500,8000,16000,TRUE,TRUE,FALSE,'orange_money',18,21,'Bissau.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Guinée (GNF) — 1 USD ≈ 8 600 GNF
-- ═══════════════════════════════════════════════════════
('GN',8000,5000,700,8000,30000,5000,2500,5000,20,18,15,1000,80000,180000,350000,TRUE,TRUE,FALSE,'orange_money,mtn_money',18,21,'Conakry. GNF. Forte inflation.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Zone CEMAC (XAF) — même parité que XOF
-- ═══════════════════════════════════════════════════════
('CM',600,350,60,600,2500,350,175,350,20,18,15,100,6000,14000,28000,TRUE,TRUE,FALSE,'orange_money,mtn_money',18,21,'Douala / Yaoundé. XAF = XOF.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Ghana (GHS) — 1 USD ≈ 15 GHS
-- ═══════════════════════════════════════════════════════
('GH',15,10,1.50,15,50,10,5,10,20,18,15,2,150,350,700,TRUE,TRUE,FALSE,'mtn_money,vodafone_cash,airtel_tigo',0,21,'Accra. GHS. Économie dynamique.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Nigeria (NGN) — 1 USD ≈ 1 600 NGN
-- ═══════════════════════════════════════════════════════
('NG',2000,1200,150,2000,8000,1200,600,1200,20,18,15,200,20000,45000,90000,TRUE,TRUE,FALSE,'opay,palmpay,mtn_money',7.5,21,'Lagos / Abuja. NGN. Grand marché.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Mauritanie (MRU) — 1 USD ≈ 39 MRU
-- ═══════════════════════════════════════════════════════
('MR',50,30,5,50,200,30,15,30,18,15,12,10,500,1200,2500,TRUE,TRUE,FALSE,'chinguitel_money',0,21,'Nouakchott. MRU.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Maroc (MAD) — 1 USD ≈ 10 MAD
-- ═══════════════════════════════════════════════════════
('MA',25,12,2,25,80,12,6,12,18,15,12,3,250,600,1200,TRUE,TRUE,FALSE,'cih_bank,orange_money_ma',20,21,'Casablanca / Rabat. MAD.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Algérie (DZD) — 1 USD ≈ 135 DZD
-- ═══════════════════════════════════════════════════════
('DZ',200,100,15,200,800,100,50,100,18,15,12,20,2000,5000,10000,TRUE,TRUE,FALSE,'ccp_algerie',19,21,'Alger. DZD.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Tunisie (TND) — 1 USD ≈ 3.1 TND
-- ═══════════════════════════════════════════════════════
('TN',5,3,0.50,5,20,3,1.50,3,18,15,12,0.5,50,120,250,TRUE,TRUE,FALSE,'d17,zitouna_bank',19,21,'Tunis. TND.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Égypte (EGP) — 1 USD ≈ 50 EGP
-- ═══════════════════════════════════════════════════════
('EG',50,30,4,50,200,30,15,30,15,12,10,5,500,1200,2500,TRUE,TRUE,FALSE,'vodafone_cash,orange_money_eg,we_pay',14,21,'Le Caire. EGP. Grand marché.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Kenya (KES) — 1 USD ≈ 130 KES
-- ═══════════════════════════════════════════════════════
('KE',200,100,15,200,800,100,50,100,20,18,15,20,2000,5000,10000,TRUE,TRUE,FALSE,'mpesa,airtel_money',16,21,'Nairobi. KES. M-Pesa dominant.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Tanzanie (TZS) — 1 USD ≈ 2 500 TZS
-- ═══════════════════════════════════════════════════════
('TZ',3000,1800,250,3000,12000,1800,900,1800,20,18,15,300,30000,70000,140000,TRUE,TRUE,FALSE,'mpesa,tigopesa,airtel_money',18,21,'Dar es Salaam. TZS.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Ouganda (UGX) — 1 USD ≈ 3 700 UGX
-- ═══════════════════════════════════════════════════════
('UG',5000,3000,400,5000,18000,3000,1500,3000,20,18,15,500,50000,120000,250000,TRUE,TRUE,FALSE,'mtn_money,airtel_money',18,21,'Kampala. UGX.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Rwanda (RWF) — 1 USD ≈ 1 300 RWF
-- ═══════════════════════════════════════════════════════
('RW',2000,1200,160,2000,8000,1200,600,1200,20,18,15,200,20000,50000,100000,TRUE,TRUE,FALSE,'mtn_money,airtel_money',18,21,'Kigali. RWF. Tech hub Afrique.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Éthiopie (ETB) — 1 USD ≈ 57 ETB
-- ═══════════════════════════════════════════════════════
('ET',100,60,8,100,400,60,30,60,20,18,15,10,1000,2500,5000,TRUE,TRUE,FALSE,'telebirr',15,21,'Addis-Abeba. ETB.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Afrique du Sud (ZAR) — 1 USD ≈ 18 ZAR
-- ═══════════════════════════════════════════════════════
('ZA',25,12,2,25,80,12,6,12,18,15,12,2,250,600,1200,TRUE,TRUE,TRUE,'snapscan,zapper',15,21,'Johannesburg / Cape Town. ZAR. Carte bankaire répandue.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — RDC Congo (CDF) — 1 USD ≈ 2 800 CDF
-- ═══════════════════════════════════════════════════════
('CD',4000,2500,350,4000,15000,2500,1200,2500,20,18,15,400,40000,100000,200000,TRUE,TRUE,FALSE,'m_pesa_drc,orange_money',0,21,'Kinshasa. CDF.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Angola (AOA) — 1 USD ≈ 900 AOA
-- ═══════════════════════════════════════════════════════
('AO',1200,700,100,1200,5000,700,350,700,20,18,15,100,12000,30000,60000,TRUE,TRUE,FALSE,'multicaixa',14,21,'Luanda. AOA.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Mozambique (MZN) — 1 USD ≈ 63 MZN
-- ═══════════════════════════════════════════════════════
('MZ',100,60,8,100,400,60,30,60,20,18,15,10,1000,2500,5000,TRUE,TRUE,FALSE,'mpesa_mz,emola',16,18,'Maputo. MZN.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Sierra Leone (SLE) — 1 USD ≈ 22 SLE
-- ═══════════════════════════════════════════════════════
('SL',30,18,2.50,30,120,18,9,18,20,18,15,3,300,700,1500,TRUE,TRUE,FALSE,'orange_money',0,21,'Freetown. SLE.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Libéria (LRD) — 1 USD ≈ 192 LRD
-- ═══════════════════════════════════════════════════════
('LR',300,180,25,300,1200,180,90,180,20,18,15,30,3000,7000,14000,TRUE,TRUE,FALSE,'orange_money',0,21,'Monrovia. LRD.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Gambie (GMD) — 1 USD ≈ 70 GMD
-- ═══════════════════════════════════════════════════════
('GM',100,60,8,100,400,60,30,60,20,18,15,10,1000,2500,5000,TRUE,TRUE,FALSE,'qmoney',0,21,'Banjul. GMD.'),

-- ═══════════════════════════════════════════════════════
-- AFRIQUE — Cap-Vert (CVE) — 1 USD ≈ 100 CVE
-- ═══════════════════════════════════════════════════════
('CV',150,80,12,150,600,80,40,80,18,15,12,15,1500,3500,7000,TRUE,TRUE,FALSE,'vinti4',0,18,'Praia. CVE. Île touristique.'),

-- ═══════════════════════════════════════════════════════
-- EUROPE — Zone Euro (EUR) — 1 USD ≈ 0.92 EUR
-- Revenu moyen ~2 000-3 500 EUR/mois
-- ═══════════════════════════════════════════════════════
('FR',3.50,1.50,0.30,5,10,3,1.50,3,20,18,15,0.50,80,200,400,TRUE,FALSE,TRUE,'',20,21,'France. EUR. Réglementation VTC stricte.'),
('BE',3.50,1.50,0.30,5,10,3,1.50,3,20,18,15,0.50,80,200,400,TRUE,FALSE,TRUE,'',21,21,'Belgique. EUR.'),
('DE',3.50,1.50,0.30,5,10,3,1.50,3,20,18,15,0.50,80,200,400,TRUE,FALSE,TRUE,'',19,21,'Allemagne. EUR.'),
('ES',3,1.30,0.25,5,10,3,1.30,3,20,18,15,0.50,75,175,350,TRUE,FALSE,TRUE,'',21,21,'Espagne. EUR.'),
('IT',3,1.30,0.25,5,10,3,1.30,3,20,18,15,0.50,75,175,350,TRUE,FALSE,TRUE,'',22,21,'Italie. EUR.'),
('PT',2.50,1.20,0.22,4,8,2.50,1.20,2.50,20,18,15,0.40,60,150,300,TRUE,FALSE,TRUE,'',23,21,'Portugal. EUR.'),
('NL',3.50,1.60,0.32,5,10,3.50,1.60,3.50,21,18,15,0.50,80,200,400,TRUE,FALSE,TRUE,'',21,21,'Pays-Bas. EUR.'),

-- ═══════════════════════════════════════════════════════
-- EUROPE — Suisse (CHF) — 1 USD ≈ 0.9 CHF — pays le plus cher
-- ═══════════════════════════════════════════════════════
('CH',6,2.50,0.50,8,15,5,2.50,5,18,15,12,1,150,350,700,TRUE,FALSE,TRUE,'',7.7,21,'Suisse. CHF. Tarifs les plus élevés.'),

-- ═══════════════════════════════════════════════════════
-- EUROPE — Royaume-Uni (GBP) — 1 USD ≈ 0.79 GBP
-- ═══════════════════════════════════════════════════════
('GB',3,1.60,0.30,5,10,3,1.60,3,20,18,15,0.50,80,200,400,TRUE,FALSE,TRUE,'',20,21,'UK. GBP. Uber très présent.'),

-- ═══════════════════════════════════════════════════════
-- AMÉRIQUE — États-Unis (USD) — 1 USD = 1 USD
-- ═══════════════════════════════════════════════════════
('US',3,1.50,0.28,5,10,3,1.50,3,20,18,15,0.50,80,200,400,TRUE,FALSE,TRUE,'',0,21,'USA. USD. Marché mature.'),

-- ═══════════════════════════════════════════════════════
-- AMÉRIQUE — Canada (CAD) — 1 USD ≈ 1.36 CAD
-- ═══════════════════════════════════════════════════════
('CA',4,2,0.38,6,12,4,2,4,20,18,15,0.75,100,250,500,TRUE,FALSE,TRUE,'',5,21,'Canada. CAD.'),

-- ═══════════════════════════════════════════════════════
-- AMÉRIQUE — Brésil (BRL) — 1 USD ≈ 5 BRL
-- ═══════════════════════════════════════════════════════
('BR',6,3,0.50,6,20,6,3,6,20,18,15,1,60,150,300,TRUE,TRUE,TRUE,'pix,picpay',12,21,'Brésil. BRL. Pix très utilisé.'),

-- ═══════════════════════════════════════════════════════
-- AMÉRIQUE — Mexique (MXN) — 1 USD ≈ 17 MXN
-- ═══════════════════════════════════════════════════════
('MX',30,15,2,30,100,15,8,15,20,18,15,3,300,700,1500,TRUE,TRUE,TRUE,'oxxo_pay',16,21,'Mexique. MXN.'),

-- ═══════════════════════════════════════════════════════
-- AMÉRIQUE — Haïti (HTG) — 1 USD ≈ 133 HTG
-- ═══════════════════════════════════════════════════════
('HT',200,120,18,200,800,120,60,120,20,18,15,20,2000,5000,10000,TRUE,TRUE,FALSE,'moncash,natcash',0,21,'Port-au-Prince. HTG. Marché difficile.'),

-- ═══════════════════════════════════════════════════════
-- ASIE / MOYEN-ORIENT — Émirats (AED) — 1 USD ≈ 3.67 AED
-- Revenu élevé, pas d''impôt
-- ═══════════════════════════════════════════════════════
('AE',10,3,0.50,15,30,8,3,8,18,15,12,2,200,500,1000,TRUE,FALSE,TRUE,'',5,21,'Dubai / Abu Dhabi. AED. Pas de TVA jusqu''au seuil.'),

-- ═══════════════════════════════════════════════════════
-- ASIE — Arabie Saoudite (SAR) — 1 USD ≈ 3.75 SAR
-- ═══════════════════════════════════════════════════════
('SA',15,4,0.60,20,40,10,4,10,18,15,12,2,200,500,1000,TRUE,FALSE,TRUE,'stcpay,apple_pay',15,21,'Riyadh. SAR.'),

-- ═══════════════════════════════════════════════════════
-- ASIE — Inde (INR) — 1 USD ≈ 83 INR — énorme marché
-- ═══════════════════════════════════════════════════════
('IN',50,12,2,50,200,30,12,30,20,18,15,5,500,1200,2500,TRUE,TRUE,FALSE,'upi,paytm,phonepe',18,21,'Inde. INR. Ola / Uber très présent.'),

-- ═══════════════════════════════════════════════════════
-- ASIE — Chine (CNY) — 1 USD ≈ 7.2 CNY
-- ═══════════════════════════════════════════════════════
('CN',15,3,0.50,15,50,10,3,10,18,15,12,1.50,150,350,700,TRUE,FALSE,FALSE,'wechat_pay,alipay',13,21,'Chine. CNY. Didi dominant.'),

-- ═══════════════════════════════════════════════════════
-- ASIE — Japon (JPY) — 1 USD ≈ 155 JPY — très chères
-- ═══════════════════════════════════════════════════════
('JP',500,120,20,700,2000,400,120,400,15,12,10,50,5000,12000,25000,TRUE,FALSE,TRUE,'paypay,suica',10,21,'Japon. JPY. Taxis très réglementés.')
ON CONFLICT (country_code) DO UPDATE SET
  base_fare=EXCLUDED.base_fare, per_km_rate=EXCLUDED.per_km_rate,
  per_min_rate=EXCLUDED.per_min_rate, min_fare=EXCLUDED.min_fare,
  airport_surcharge=EXCLUDED.airport_surcharge,
  delivery_base=EXCLUDED.delivery_base, delivery_per_km=EXCLUDED.delivery_per_km,
  delivery_min=EXCLUDED.delivery_min,
  commission_ride=EXCLUDED.commission_ride, commission_delivery=EXCLUDED.commission_delivery,
  commission_store=EXCLUDED.commission_store, service_fee=EXCLUDED.service_fee,
  driver_bonus_bronze=EXCLUDED.driver_bonus_bronze, driver_bonus_silver=EXCLUDED.driver_bonus_silver,
  driver_bonus_gold=EXCLUDED.driver_bonus_gold,
  payment_cash=EXCLUDED.payment_cash, payment_mobile_money=EXCLUDED.payment_mobile_money,
  payment_card=EXCLUDED.payment_card, mobile_money_providers=EXCLUDED.mobile_money_providers,
  vat_rate=EXCLUDED.vat_rate, driver_age_min=EXCLUDED.driver_age_min,
  notes=EXCLUDED.notes, updated_at=NOW();

-- Migration 009: Countries of the world + per-country configuration
-- COMPLET — persiste après docker compose down -v puis up -d

-- ─────────────────────────────────────────────
-- 1. Countries table
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS countries (
    code             CHAR(2)      PRIMARY KEY,
    code3            CHAR(3)      UNIQUE NOT NULL,
    name_fr          VARCHAR(80)  NOT NULL,
    name_en          VARCHAR(80)  NOT NULL,
    currency_code    CHAR(3)      NOT NULL,
    currency_name_fr VARCHAR(60)  NOT NULL,
    currency_name_en VARCHAR(60)  NOT NULL,
    currency_symbol  VARCHAR(10)  NOT NULL,
    phone_code       VARCHAR(10)  NOT NULL,
    flag_emoji       VARCHAR(10)  NOT NULL,
    continent        VARCHAR(20)  NOT NULL,
    is_active        BOOLEAN      DEFAULT FALSE,
    created_at       TIMESTAMPTZ  DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- 2. Per-country config table
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS country_configs (
    country_code          CHAR(2)      PRIMARY KEY REFERENCES countries(code) ON DELETE CASCADE,
    base_fare             NUMERIC(12,2) DEFAULT 500,
    per_km_rate           NUMERIC(12,2) DEFAULT 300,
    per_min_rate          NUMERIC(12,2) DEFAULT 50,
    min_fare              NUMERIC(12,2) DEFAULT 500,
    airport_surcharge     NUMERIC(12,2) DEFAULT 2000,
    delivery_base         NUMERIC(12,2) DEFAULT 300,
    delivery_per_km       NUMERIC(12,2) DEFAULT 150,
    delivery_min          NUMERIC(12,2) DEFAULT 300,
    commission_ride       NUMERIC(5,2)  DEFAULT 20.00,
    commission_delivery   NUMERIC(5,2)  DEFAULT 18.00,
    commission_store      NUMERIC(5,2)  DEFAULT 15.00,
    service_fee           NUMERIC(12,2) DEFAULT 100,
    driver_bonus_bronze   NUMERIC(12,2) DEFAULT 5000,
    driver_bonus_silver   NUMERIC(12,2) DEFAULT 12000,
    driver_bonus_gold     NUMERIC(12,2) DEFAULT 25000,
    payment_cash          BOOLEAN       DEFAULT TRUE,
    payment_mobile_money  BOOLEAN       DEFAULT TRUE,
    payment_card          BOOLEAN       DEFAULT FALSE,
    mobile_money_providers VARCHAR(200) DEFAULT '',
    vat_rate              NUMERIC(5,2)  DEFAULT 0,
    driver_age_min        INTEGER       DEFAULT 21,
    launch_date           DATE,
    notes                 TEXT,
    updated_at            TIMESTAMPTZ   DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- 3. Surge pricing rules table (liée aux pays)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS country_surge_rules (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code CHAR(2)      NOT NULL REFERENCES countries(code) ON DELETE CASCADE,
    name_fr      VARCHAR(100) NOT NULL,
    name_en      VARCHAR(100) NOT NULL,
    rule_type    VARCHAR(30)  NOT NULL, -- 'time_of_day','weather','event','holiday'
    multiplier   NUMERIC(4,2) NOT NULL DEFAULT 1.00,
    schedule     VARCHAR(200),          -- 'Mon-Fri 07:30-09:30'
    is_active    BOOLEAN      DEFAULT TRUE,
    created_at   TIMESTAMPTZ  DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- 4. SEED: Pays du monde
-- ─────────────────────────────────────────────

-- ── UEMOA (XOF) ──────────────────────────────
INSERT INTO countries (code,code3,name_fr,name_en,currency_code,currency_name_fr,currency_name_en,currency_symbol,phone_code,flag_emoji,continent,is_active) VALUES
('SN','SEN','Sénégal','Senegal','XOF','Franc CFA UEMOA','West African CFA','XOF','+221','🇸🇳','Africa',TRUE),
('CI','CIV','Côte d''Ivoire','Ivory Coast','XOF','Franc CFA UEMOA','West African CFA','XOF','+225','🇨🇮','Africa',TRUE),
('ML','MLI','Mali','Mali','XOF','Franc CFA UEMOA','West African CFA','XOF','+223','🇲🇱','Africa',FALSE),
('BF','BFA','Burkina Faso','Burkina Faso','XOF','Franc CFA UEMOA','West African CFA','XOF','+226','🇧🇫','Africa',FALSE),
('GN','GIN','Guinée','Guinea','GNF','Franc guinéen','Guinean Franc','GNF','+224','🇬🇳','Africa',FALSE),
('GW','GNB','Guinée-Bissau','Guinea-Bissau','XOF','Franc CFA UEMOA','West African CFA','XOF','+245','🇬🇼','Africa',FALSE),
('TG','TGO','Togo','Togo','XOF','Franc CFA UEMOA','West African CFA','XOF','+228','🇹🇬','Africa',FALSE),
('BJ','BEN','Bénin','Benin','XOF','Franc CFA UEMOA','West African CFA','XOF','+229','🇧🇯','Africa',FALSE),
('NE','NER','Niger','Niger','XOF','Franc CFA UEMOA','West African CFA','XOF','+227','🇳🇪','Africa',FALSE),
('MR','MRT','Mauritanie','Mauritania','MRU','Ouguiya','Mauritanian Ouguiya','MRU','+222','🇲🇷','Africa',FALSE),
-- ── CEMAC (XAF) ──────────────────────────────
('CM','CMR','Cameroun','Cameroon','XAF','Franc CFA CEMAC','CFA Franc BEAC','XAF','+237','🇨🇲','Africa',TRUE),
('CG','COG','Congo (Rép.)','Congo Republic','XAF','Franc CFA CEMAC','CFA Franc BEAC','XAF','+242','🇨🇬','Africa',FALSE),
('GA','GAB','Gabon','Gabon','XAF','Franc CFA CEMAC','CFA Franc BEAC','XAF','+241','🇬🇦','Africa',FALSE),
('TD','TCD','Tchad','Chad','XAF','Franc CFA CEMAC','CFA Franc BEAC','XAF','+235','🇹🇩','Africa',FALSE),
('CF','CAF','Centrafrique','C.A.R.','XAF','Franc CFA CEMAC','CFA Franc BEAC','XAF','+236','🇨🇫','Africa',FALSE),
('GQ','GNQ','Guinée Équatoriale','Equatorial Guinea','XAF','Franc CFA CEMAC','CFA Franc BEAC','XAF','+240','🇬🇶','Africa',FALSE),
-- ── Afrique de l'Ouest ───────────────────────
('NG','NGA','Nigéria','Nigeria','NGN','Naira','Nigerian Naira','₦','+234','🇳🇬','Africa',FALSE),
('GH','GHA','Ghana','Ghana','GHS','Cedi','Ghanaian Cedi','₵','+233','🇬🇭','Africa',FALSE),
('SL','SLE','Sierra Leone','Sierra Leone','SLE','Leone','Leone','Le','+232','🇸🇱','Africa',FALSE),
('LR','LBR','Libéria','Liberia','LRD','Dollar libérien','Liberian Dollar','L$','+231','🇱🇷','Africa',FALSE),
('GM','GMB','Gambie','Gambia','GMD','Dalasi','Gambian Dalasi','D','+220','🇬🇲','Africa',FALSE),
('CV','CPV','Cap-Vert','Cape Verde','CVE','Escudo','Cape Verdean Escudo','Esc','+238','🇨🇻','Africa',FALSE),
-- ── Afrique du Nord ───────────────────────────
('MA','MAR','Maroc','Morocco','MAD','Dirham marocain','Moroccan Dirham','MAD','+212','🇲🇦','Africa',FALSE),
('DZ','DZA','Algérie','Algeria','DZD','Dinar algérien','Algerian Dinar','DA','+213','🇩🇿','Africa',FALSE),
('TN','TUN','Tunisie','Tunisia','TND','Dinar tunisien','Tunisian Dinar','DT','+216','🇹🇳','Africa',FALSE),
('EG','EGY','Égypte','Egypt','EGP','Livre égyptienne','Egyptian Pound','E£','+20','🇪🇬','Africa',FALSE),
('LY','LBY','Libye','Libya','LYD','Dinar libyen','Libyan Dinar','LD','+218','🇱🇾','Africa',FALSE),
-- ── Afrique de l'Est / Corne ──────────────────
('KE','KEN','Kenya','Kenya','KES','Shilling kényan','Kenyan Shilling','KSh','+254','🇰🇪','Africa',FALSE),
('TZ','TZA','Tanzanie','Tanzania','TZS','Shilling tanzanien','Tanzanian Shilling','TSh','+255','🇹🇿','Africa',FALSE),
('UG','UGA','Ouganda','Uganda','UGX','Shilling ougandais','Ugandan Shilling','USh','+256','🇺🇬','Africa',FALSE),
('RW','RWA','Rwanda','Rwanda','RWF','Franc rwandais','Rwandan Franc','RF','+250','🇷🇼','Africa',FALSE),
('ET','ETH','Éthiopie','Ethiopia','ETB','Birr éthiopien','Ethiopian Birr','Br','+251','🇪🇹','Africa',FALSE),
('SO','SOM','Somalie','Somalia','SOS','Shilling somalien','Somali Shilling','Sh','+252','🇸🇴','Africa',FALSE),
('DJ','DJI','Djibouti','Djibouti','DJF','Franc djiboutien','Djiboutian Franc','Fdj','+253','🇩🇯','Africa',FALSE),
('SD','SDN','Soudan','Sudan','SDG','Livre soudanaise','Sudanese Pound','SDG','+249','🇸🇩','Africa',FALSE),
('SS','SSD','Soudan du Sud','South Sudan','SSP','Livre sud-soud.','S. Sudanese Pound','SSP','+211','🇸🇸','Africa',FALSE),
('BI','BDI','Burundi','Burundi','BIF','Franc burundais','Burundian Franc','Fr','+257','🇧🇮','Africa',FALSE),
('ER','ERI','Érythrée','Eritrea','ERN','Nakfa','Eritrean Nakfa','Nfk','+291','🇪🇷','Africa',FALSE),
-- ── Afrique Australe ──────────────────────────
('ZA','ZAF','Afrique du Sud','South Africa','ZAR','Rand','South African Rand','R','+27','🇿🇦','Africa',FALSE),
('AO','AGO','Angola','Angola','AOA','Kwanza','Angolan Kwanza','Kz','+244','🇦🇴','Africa',FALSE),
('MZ','MOZ','Mozambique','Mozambique','MZN','Metical','Mozambican Metical','MT','+258','🇲🇿','Africa',FALSE),
('CD','COD','Congo (RDC)','Congo DRC','CDF','Franc congolais','Congolese Franc','FC','+243','🇨🇩','Africa',FALSE),
('ZM','ZMB','Zambie','Zambia','ZMW','Kwacha zambien','Zambian Kwacha','ZK','+260','🇿🇲','Africa',FALSE),
('ZW','ZWE','Zimbabwe','Zimbabwe','USD','Dollar US','US Dollar','$','+263','🇿🇼','Africa',FALSE),
('MW','MWI','Malawi','Malawi','MWK','Kwacha malawien','Malawian Kwacha','MK','+265','🇲🇼','Africa',FALSE),
('BW','BWA','Botswana','Botswana','BWP','Pula','Botswana Pula','P','+267','🇧🇼','Africa',FALSE),
('NA','NAM','Namibie','Namibia','NAD','Dollar namibien','Namibian Dollar','N$','+264','🇳🇦','Africa',FALSE),
('MG','MDG','Madagascar','Madagascar','MGA','Ariary','Malagasy Ariary','Ar','+261','🇲🇬','Africa',FALSE),
('MU','MUS','Maurice (Île)','Mauritius','MUR','Roupie mauricienne','Mauritian Rupee','₨','+230','🇲🇺','Africa',FALSE),
-- ── Europe ────────────────────────────────────
('FR','FRA','France','France','EUR','Euro','Euro','€','+33','🇫🇷','Europe',FALSE),
('BE','BEL','Belgique','Belgium','EUR','Euro','Euro','€','+32','🇧🇪','Europe',FALSE),
('CH','CHE','Suisse','Switzerland','CHF','Franc suisse','Swiss Franc','CHF','+41','🇨🇭','Europe',FALSE),
('DE','DEU','Allemagne','Germany','EUR','Euro','Euro','€','+49','🇩🇪','Europe',FALSE),
('GB','GBR','Royaume-Uni','United Kingdom','GBP','Livre sterling','British Pound','£','+44','🇬🇧','Europe',FALSE),
('ES','ESP','Espagne','Spain','EUR','Euro','Euro','€','+34','🇪🇸','Europe',FALSE),
('IT','ITA','Italie','Italy','EUR','Euro','Euro','€','+39','🇮🇹','Europe',FALSE),
('PT','PRT','Portugal','Portugal','EUR','Euro','Euro','€','+351','🇵🇹','Europe',FALSE),
('NL','NLD','Pays-Bas','Netherlands','EUR','Euro','Euro','€','+31','🇳🇱','Europe',FALSE),
-- ── Amérique ──────────────────────────────────
('US','USA','États-Unis','United States','USD','Dollar américain','US Dollar','$','+1','🇺🇸','America',FALSE),
('CA','CAN','Canada','Canada','CAD','Dollar canadien','Canadian Dollar','C$','+1','🇨🇦','America',FALSE),
('BR','BRA','Brésil','Brazil','BRL','Réal brésilien','Brazilian Real','R$','+55','🇧🇷','America',FALSE),
('MX','MEX','Mexique','Mexico','MXN','Peso mexicain','Mexican Peso','$','+52','🇲🇽','America',FALSE),
('HT','HTI','Haïti','Haiti','HTG','Gourde','Haitian Gourde','G','+509','🇭🇹','America',FALSE),
-- ── Asie / Moyen-Orient ───────────────────────
('AE','ARE','Émirats Arabes Unis','UAE','AED','Dirham des EAU','UAE Dirham','AED','+971','🇦🇪','Asia',FALSE),
('SA','SAU','Arabie Saoudite','Saudi Arabia','SAR','Riyal saoudien','Saudi Riyal','SAR','+966','🇸🇦','Asia',FALSE),
('CN','CHN','Chine','China','CNY','Yuan','Chinese Yuan','¥','+86','🇨🇳','Asia',FALSE),
('IN','IND','Inde','India','INR','Roupie indienne','Indian Rupee','₹','+91','🇮🇳','Asia',FALSE),
('JP','JPN','Japon','Japan','JPY','Yen','Japanese Yen','¥','+81','🇯🇵','Asia',FALSE)
ON CONFLICT (code) DO NOTHING;

-- ─────────────────────────────────────────────
-- 5. SEED: Configs par pays — TOUS LES PAYS
-- Format: (code, base, /km, /min, min, aeroport, del_base, del_km, del_min,
--          comm_ride, comm_del, comm_store, service_fee,
--          bonus_bronze, bonus_silver, bonus_gold,
--          cash, mobile_money, card, providers, vat, age_min, notes)
-- ─────────────────────────────────────────────
INSERT INTO country_configs (country_code,base_fare,per_km_rate,per_min_rate,min_fare,airport_surcharge,delivery_base,delivery_per_km,delivery_min,commission_ride,commission_delivery,commission_store,service_fee,driver_bonus_bronze,driver_bonus_silver,driver_bonus_gold,payment_cash,payment_mobile_money,payment_card,mobile_money_providers,vat_rate,driver_age_min,notes) VALUES
-- ── UEMOA (XOF) — 1 USD ≈ 600 XOF ──────────
('SN',500,300,50,500,2000,300,150,300,20,18,15,100,5000,12000,25000,TRUE,TRUE,FALSE,'orange_money,wave,free_money',18,21,'Sénégal. Marché principal. Dakar.'),
('CI',600,350,60,600,2500,350,175,350,20,18,15,100,6000,14000,28000,TRUE,TRUE,FALSE,'orange_money,mtn_money,moov_money',18,21,'Côte d''Ivoire. Abidjan. Fort trafic.'),
('ML',450,280,45,450,1800,280,140,280,20,18,15,75,4500,10000,20000,TRUE,TRUE,FALSE,'orange_money,moov_money',18,21,'Mali. Bamako.'),
('BF',400,250,40,400,1500,250,125,250,18,15,12,75,4000,9000,18000,TRUE,TRUE,FALSE,'orange_money,moov_money',18,21,'Burkina Faso. Ouagadougou.'),
('GN',8000,5000,700,8000,30000,5000,2500,5000,20,18,15,1000,80000,180000,350000,TRUE,TRUE,FALSE,'orange_money,mtn_money',18,21,'Guinée. GNF. 1 USD ≈ 8600 GNF.'),
('GW',380,230,38,380,1400,230,115,230,18,15,12,50,3500,8000,16000,TRUE,TRUE,FALSE,'orange_money',18,21,'Guinée-Bissau. Bissau.'),
('TG',450,280,45,450,1800,280,140,280,18,15,12,75,4500,10000,20000,TRUE,TRUE,FALSE,'togocel_money,moov_money',18,21,'Togo. Lomé.'),
('BJ',400,260,42,400,1600,260,130,260,18,15,12,75,4000,9000,18000,TRUE,TRUE,FALSE,'mtn_money,moov_money',18,21,'Bénin. Cotonou.'),
('NE',380,240,38,380,1500,240,120,240,18,15,12,50,3500,8000,16000,TRUE,TRUE,FALSE,'airtel_money',18,21,'Niger. Niamey.'),
('MR',50,30,5,50,200,30,15,30,18,15,12,10,500,1200,2500,TRUE,TRUE,FALSE,'chinguitel_money',0,21,'Mauritanie. Nouakchott. MRU. 1 USD ≈ 39 MRU.'),
-- ── CEMAC (XAF) — même parité XOF ───────────
('CM',600,350,60,600,2500,350,175,350,20,18,15,100,6000,14000,28000,TRUE,TRUE,FALSE,'orange_money,mtn_money',18,21,'Cameroun. Douala/Yaoundé. XAF.'),
('CG',600,350,60,600,2500,350,175,350,20,18,15,100,6000,14000,28000,TRUE,TRUE,FALSE,'airtel_money,mtn_money',18,21,'Congo Brazzaville. XAF.'),
('GA',800,500,80,800,3000,500,250,500,20,18,15,150,8000,18000,36000,TRUE,TRUE,FALSE,'airtel_money,moov_money',18,21,'Gabon. Libreville. XAF. Revenus pétroliers élevés.'),
('TD',400,240,40,400,1500,240,120,240,18,15,12,75,4000,9000,18000,TRUE,TRUE,FALSE,'airtel_money,moov_money',0,21,'Tchad. N''Djamena. XAF. Économie fragile.'),
('CF',350,200,35,350,1200,200,100,200,18,15,12,50,3000,7000,14000,TRUE,TRUE,FALSE,'orange_money',19,21,'Centrafrique. Bangui. XAF. Très faible revenu.'),
('GQ',700,400,70,700,2800,400,200,400,20,18,15,120,7000,16000,32000,TRUE,FALSE,TRUE,'',15,21,'Guinée Équatoriale. Malabo. XAF. PIB pétrole élevé.'),
-- ── Afrique de l''Ouest ──────────────────────
('NG',2000,1200,150,2000,8000,1200,600,1200,20,18,15,200,20000,45000,90000,TRUE,TRUE,FALSE,'opay,palmpay,mtn_money',7.5,21,'Nigéria. Lagos/Abuja. NGN. 1 USD ≈ 1600 NGN.'),
('GH',15,10,1.5,15,50,10,5,10,20,18,15,2,150,350,700,TRUE,TRUE,FALSE,'mtn_money,vodafone_cash,airtel_tigo',0,21,'Ghana. Accra. GHS. 1 USD ≈ 15 GHS.'),
('SL',30,18,2.5,30,120,18,9,18,20,18,15,3,300,700,1500,TRUE,TRUE,FALSE,'orange_money',0,21,'Sierra Leone. Freetown. SLE.'),
('LR',300,180,25,300,1200,180,90,180,20,18,15,30,3000,7000,14000,TRUE,TRUE,FALSE,'orange_money',0,21,'Libéria. Monrovia. LRD. 1 USD ≈ 192 LRD.'),
('GM',100,60,8,100,400,60,30,60,20,18,15,10,1000,2500,5000,TRUE,TRUE,FALSE,'qmoney',0,21,'Gambie. Banjul. GMD. 1 USD ≈ 70 GMD.'),
('CV',150,80,12,150,600,80,40,80,18,15,12,15,1500,3500,7000,TRUE,TRUE,FALSE,'vinti4',0,18,'Cap-Vert. Praia. CVE. 1 USD ≈ 100 CVE. Île touristique.'),
-- ── Afrique du Nord ──────────────────────────
('MA',25,12,2,25,80,12,6,12,18,15,12,3,250,600,1200,TRUE,TRUE,FALSE,'cih_bank,orange_money_ma',20,21,'Maroc. Casablanca. MAD. 1 USD ≈ 10 MAD.'),
('DZ',200,100,15,200,800,100,50,100,18,15,12,20,2000,5000,10000,TRUE,TRUE,FALSE,'ccp_algerie',19,21,'Algérie. Alger. DZD. 1 USD ≈ 135 DZD.'),
('TN',5,3,0.5,5,20,3,1.5,3,18,15,12,0.5,50,120,250,TRUE,TRUE,FALSE,'d17,zitouna_bank',19,21,'Tunisie. Tunis. TND. 1 USD ≈ 3.1 TND.'),
('EG',50,30,4,50,200,30,15,30,15,12,10,5,500,1200,2500,TRUE,TRUE,FALSE,'vodafone_cash,orange_money_eg,we_pay',14,21,'Égypte. Le Caire. EGP. 1 USD ≈ 50 EGP.'),
('LY',8,4,0.6,8,30,4,2,4,15,12,10,1,80,200,400,TRUE,FALSE,FALSE,'',0,21,'Libye. Tripoli. LYD. Situation instable. Cash dominant.'),
-- ── Afrique de l''Est / Corne ─────────────────
('KE',200,100,15,200,800,100,50,100,20,18,15,20,2000,5000,10000,TRUE,TRUE,FALSE,'mpesa,airtel_money',16,21,'Kenya. Nairobi. KES. M-Pesa dominant. 1 USD ≈ 130 KES.'),
('TZ',3000,1800,250,3000,12000,1800,900,1800,20,18,15,300,30000,70000,140000,TRUE,TRUE,FALSE,'mpesa,tigopesa,airtel_money',18,21,'Tanzanie. Dar es Salaam. TZS. 1 USD ≈ 2500 TZS.'),
('UG',5000,3000,400,5000,18000,3000,1500,3000,20,18,15,500,50000,120000,250000,TRUE,TRUE,FALSE,'mtn_money,airtel_money',18,21,'Ouganda. Kampala. UGX. 1 USD ≈ 3700 UGX.'),
('RW',2000,1200,160,2000,8000,1200,600,1200,20,18,15,200,20000,50000,100000,TRUE,TRUE,FALSE,'mtn_money,airtel_money',18,21,'Rwanda. Kigali. RWF. Tech hub Afrique.'),
('ET',100,60,8,100,400,60,30,60,20,18,15,10,1000,2500,5000,TRUE,TRUE,FALSE,'telebirr',15,21,'Éthiopie. Addis-Abeba. ETB.'),
('SO',3000,1800,250,3000,10000,1800,900,1800,20,18,15,300,30000,70000,140000,TRUE,TRUE,FALSE,'hormuud_zaad,evc_plus',0,21,'Somalie. Mogadiscio. SOS. Zaad/EVC dominant.'),
('DJ',1500,800,120,1500,5000,800,400,800,18,15,12,150,15000,35000,70000,TRUE,TRUE,FALSE,'telesom_money',0,21,'Djibouti. DJF. Port stratégique.'),
('SD',3000,1800,250,3000,12000,1800,900,1800,18,15,12,300,30000,70000,140000,TRUE,TRUE,FALSE,'fawry',17,21,'Soudan. Khartoum. SDG. Forte inflation.'),
('SS',5000,3000,400,5000,18000,3000,1500,3000,20,18,15,500,50000,120000,240000,TRUE,FALSE,FALSE,'',18,21,'Soudan du Sud. Juba. SSP. Cash uniquement.'),
('BI',5000,3000,450,5000,18000,3000,1500,3000,20,18,15,500,50000,120000,240000,TRUE,TRUE,FALSE,'lumicash,econet',18,21,'Burundi. Bujumbura. BIF.'),
('ER',20,12,1.8,20,80,12,6,12,18,15,12,2,200,500,1000,TRUE,FALSE,FALSE,'',5,21,'Érythrée. Asmara. ERN. Économie fermée.'),
-- ── Afrique Australe ─────────────────────────
('ZA',25,12,2,25,80,12,6,12,18,15,12,2,250,600,1200,TRUE,TRUE,TRUE,'snapscan,zapper',15,21,'Afrique du Sud. Johannesburg. ZAR.'),
('AO',1200,700,100,1200,5000,700,350,700,20,18,15,100,12000,30000,60000,TRUE,TRUE,FALSE,'multicaixa',14,21,'Angola. Luanda. AOA. 1 USD ≈ 900 AOA.'),
('MZ',100,60,8,100,400,60,30,60,20,18,15,10,1000,2500,5000,TRUE,TRUE,FALSE,'mpesa_mz,emola',16,18,'Mozambique. Maputo. MZN.'),
('CD',4000,2500,350,4000,15000,2500,1200,2500,20,18,15,400,40000,100000,200000,TRUE,TRUE,FALSE,'m_pesa_drc,orange_money',0,21,'Congo RDC. Kinshasa. CDF.'),
('ZM',60,35,5,60,220,35,18,35,18,15,12,6,600,1400,2800,TRUE,TRUE,FALSE,'mtn_money,airtel_money',16,21,'Zambie. Lusaka. ZMW.'),
('ZW',3,1.5,0.28,5,10,3,1.5,3,20,18,15,0.5,80,200,400,TRUE,TRUE,TRUE,'ecocash',15,21,'Zimbabwe. Harare. USD officiel. EcoCash.'),
('MW',3000,1800,250,3000,12000,1800,900,1800,20,18,15,300,30000,70000,140000,TRUE,TRUE,FALSE,'airtel_money,tnm_mpamba',16.5,21,'Malawi. Lilongwe. MWK.'),
('BW',20,10,1.5,20,70,10,5,10,18,15,12,2,200,500,1000,TRUE,TRUE,FALSE,'orange_money_bw,fnb_ewallets',14,21,'Botswana. Gaborone. BWP.'),
('NA',25,12,2,25,80,12,6,12,18,15,12,2,250,600,1200,TRUE,TRUE,FALSE,'fnb_ewallet',15,21,'Namibie. Windhoek. NAD = ZAR.'),
('MG',8000,5000,700,8000,30000,5000,2500,5000,20,18,15,800,80000,200000,400000,TRUE,TRUE,FALSE,'mvola,orange_money_mg',20,21,'Madagascar. Antananarivo. MGA.'),
('MU',80,40,6,80,300,40,20,40,18,15,12,8,800,2000,4000,TRUE,TRUE,TRUE,'juice_mtn,my_t_money',15,18,'Île Maurice. Port-Louis. MUR.'),
-- ── Europe ────────────────────────────────────
('FR',3.5,1.5,0.3,5,10,3,1.5,3,20,18,15,0.5,80,200,400,TRUE,FALSE,TRUE,'',20,21,'France. EUR.'),
('BE',3.5,1.5,0.3,5,10,3,1.5,3,20,18,15,0.5,80,200,400,TRUE,FALSE,TRUE,'',21,21,'Belgique. EUR.'),
('CH',6,2.5,0.5,8,15,5,2.5,5,18,15,12,1,150,350,700,TRUE,FALSE,TRUE,'',7.7,21,'Suisse. CHF. Tarifs les plus élevés.'),
('DE',3.5,1.5,0.3,5,10,3,1.5,3,20,18,15,0.5,80,200,400,TRUE,FALSE,TRUE,'',19,21,'Allemagne. EUR.'),
('GB',3,1.6,0.3,5,10,3,1.6,3,20,18,15,0.5,80,200,400,TRUE,FALSE,TRUE,'',20,21,'Royaume-Uni. GBP.'),
('ES',3,1.3,0.25,5,10,3,1.3,3,20,18,15,0.5,75,175,350,TRUE,FALSE,TRUE,'',21,21,'Espagne. EUR.'),
('IT',3,1.3,0.25,5,10,3,1.3,3,20,18,15,0.5,75,175,350,TRUE,FALSE,TRUE,'',22,21,'Italie. EUR.'),
('PT',2.5,1.2,0.22,4,8,2.5,1.2,2.5,20,18,15,0.4,60,150,300,TRUE,FALSE,TRUE,'',23,21,'Portugal. EUR.'),
('NL',3.5,1.6,0.32,5,10,3.5,1.6,3.5,21,18,15,0.5,80,200,400,TRUE,FALSE,TRUE,'',21,21,'Pays-Bas. EUR.'),
-- ── Amérique ─────────────────────────────────
('US',3,1.5,0.28,5,10,3,1.5,3,20,18,15,0.5,80,200,400,TRUE,FALSE,TRUE,'',0,21,'USA. USD.'),
('CA',4,2,0.38,6,12,4,2,4,20,18,15,0.75,100,250,500,TRUE,FALSE,TRUE,'',5,21,'Canada. CAD.'),
('BR',6,3,0.5,6,20,6,3,6,20,18,15,1,60,150,300,TRUE,TRUE,TRUE,'pix,picpay',12,21,'Brésil. BRL. Pix très utilisé.'),
('MX',30,15,2,30,100,15,8,15,20,18,15,3,300,700,1500,TRUE,TRUE,TRUE,'oxxo_pay',16,21,'Mexique. MXN.'),
('HT',200,120,18,200,800,120,60,120,20,18,15,20,2000,5000,10000,TRUE,TRUE,FALSE,'moncash,natcash',0,21,'Haïti. HTG.'),
-- ── Asie / Moyen-Orient ──────────────────────
('AE',10,3,0.5,15,30,8,3,8,18,15,12,2,200,500,1000,TRUE,FALSE,TRUE,'',5,21,'Émirats. AED. Dubaï.'),
('SA',15,4,0.6,20,40,10,4,10,18,15,12,2,200,500,1000,TRUE,FALSE,TRUE,'stcpay,apple_pay',15,21,'Arabie Saoudite. SAR.'),
('CN',15,3,0.5,15,50,10,3,10,18,15,12,1.5,150,350,700,TRUE,FALSE,FALSE,'wechat_pay,alipay',13,21,'Chine. CNY. Didi dominant.'),
('IN',50,12,2,50,200,30,12,30,20,18,15,5,500,1200,2500,TRUE,TRUE,FALSE,'upi,paytm,phonepe',18,21,'Inde. INR. Énorme marché.'),
('JP',500,120,20,700,2000,400,120,400,15,12,10,50,5000,12000,25000,TRUE,FALSE,TRUE,'paypay,suica',10,21,'Japon. JPY. Très réglementé.')
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

-- ─────────────────────────────────────────────
-- 6. Surge rules de base pour SN et CI
-- ─────────────────────────────────────────────
INSERT INTO country_surge_rules (country_code,name_fr,name_en,rule_type,multiplier,schedule,is_active) VALUES
('SN','Heure de pointe matin','Morning Rush Hour','time_of_day',1.4,'Lun-Ven 07:30-09:30',TRUE),
('SN','Heure de pointe soir','Evening Rush Hour','time_of_day',1.5,'Lun-Ven 16:30-19:30',TRUE),
('SN','Pluie / Intempéries','Rain / Bad weather','weather',1.15,'Si pluie détectée',FALSE),
('SN','Tabaski / Korité','Eid al-Adha / Fitr','holiday',1.4,'Dates variables',TRUE),
('SN','Nuit tardive','Late Night','time_of_day',1.25,'23:00-05:00',TRUE),
('SN','Supplément aéroport AIBD','AIBD Airport Surcharge','event',1.0,'Fixe +2000 XOF',TRUE),
('CI','Heure de pointe matin','Morning Rush Hour','time_of_day',1.4,'Lun-Ven 07:00-09:30',TRUE),
('CI','Heure de pointe soir','Evening Rush Hour','time_of_day',1.5,'Lun-Ven 16:00-19:00',TRUE),
('CI','Ramadan','Ramadan','holiday',1.2,'Mois de Ramadan',FALSE),
('CI','Nuit tardive','Late Night','time_of_day',1.3,'23:00-05:00',TRUE)
ON CONFLICT DO NOTHING;

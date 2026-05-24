# 🛒 FreshMart Supermarket Analytics Dashboard

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Excel](https://img.shields.io/badge/Microsoft%20Excel-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)

## 📌 Deskripsi Proyek

Dashboard analitik komprehensif untuk **FreshMart Supermarket Chain** — jaringan supermarket dengan 15 cabang di 9 kota Indonesia. Proyek ini menganalisis performa bisnis sepanjang tahun 2024 mencakup revenue, profit, produk, supplier, cabang, dan segmen customer.

Data dikelola menggunakan **PostgreSQL** sebagai database, dianalisis menggunakan **SQL**, dan divisualisasikan menggunakan **Power BI** dengan kalkulasi **DAX**.

> ⚠️ **Disclaimer:** Dataset yang digunakan dalam proyek ini adalah **data simulasi (dummy)** yang dibuat secara sintetis untuk keperluan pembelajaran dan pengembangan portofolio. Nama perusahaan, cabang, produk, supplier, dan customer bersifat fiktif. Pola data dirancang agar realistis dan merepresentasikan kondisi bisnis supermarket pada umumnya.

---

## 📊 Dashboard Preview

### Page 1 — Dashboard Performance Overview
Ringkasan performa bisnis secara keseluruhan mencakup KPI utama, tren bulanan, performa cabang, kategori produk, dan segmen customer.
<img width="1515" height="848" alt="image" src="https://github.com/user-attachments/assets/e5e91433-f3f1-4373-9c58-b68a9202d103" />


### Page 2 — Dashboard Analisis Detail
Analisis mendalam mencakup Top 10 produk terlaris, profit margin per kategori, performa supplier, dan breakdown revenue per cabang vs kategori.
<img width="1513" height="851" alt="image" src="https://github.com/user-attachments/assets/e0e5fac0-b9dc-4f27-a474-af389752819b" />


---

## 🗃️ Struktur Database

Proyek ini menggunakan arsitektur **Star Schema** dengan 4 tabel:

```
dim_produk ──────┐
dim_cabang ──────┤──── fact_transaksi
dim_customer ────┘
```

| Tabel | Rows | Deskripsi |
|---|---|---|
| `dim_produk` | 60 | Data produk: nama, kategori, supplier, harga beli & jual |
| `dim_cabang` | 15 | Data cabang: nama, kota, provinsi |
| `dim_customer` | 1.000 | Data customer: nama, segmen, kota, jenis kelamin |
| `fact_transaksi` | 17.946 | Data transaksi: tanggal, qty, revenue, profit, diskon |

---

## 📈 Key Insights

| Metrik | Nilai |
|---|---|
| Total Revenue | Rp 784.1 Juta |
| Total Profit | Rp 269.6 Juta |
| Profit Margin | 34% |
| Total Transaksi | 17.95K |
| Total Qty Terjual | 41.84K |
| Avg Transaction Value | Rp 43.69K |

**Top Findings:**
- 🏆 **FreshMart Sudirman** cabang dengan revenue tertinggi (Rp 98M)
- 📦 **Beras Premium 5kg** produk terlaris (Rp 67M)
- 🏭 **Unilever** supplier dengan kontribusi revenue terbesar (Rp 147M)
- 💰 **Minuman** kategori dengan profit margin tertinggi (40%)
- 👥 **Non-Member** segmen dengan revenue terbesar (Rp 243M)

---

## 🛠️ Tools & Technologies

| Tool | Kegunaan |
|---|---|
| PostgreSQL | Database management & SQL analysis |
| pgAdmin 4 | PostgreSQL GUI |
| Power BI Desktop | Data visualization & dashboard |
| DAX | Kalkulasi measures di Power BI |
| Microsoft Excel | Dataset sumber data |
| Python | Generate dataset |

---

## 📁 Struktur File

```
freshmart-supermarket-analytics/
│
├── 📊 dashboard/
│   └── Dashboard_FreshMart_Supermarket_Analytics.pbix
│
├── 📂 dataset/
│   └── Dataset_Supermarket_FreshMart.xlsx
│
├── 🗄️ sql/
│   ├── 01_create_tables.sql
│   ├── 02_insert_data.sql
│   └── 03_analysis_queries.sql
│
└── README.md
```

---

## 🚀 Cara Menjalankan Proyek

### Prerequisites
- PostgreSQL 14+ & pgAdmin 4
- Power BI Desktop
- psqlODBC driver

### Langkah-langkah

**1. Setup Database**
```sql
-- Buat database baru di pgAdmin
CREATE DATABASE freshmart_db;
```

**2. Buat Tabel**
```bash
-- Jalankan di pgAdmin Query Tool
01_create_tables.sql
```

**3. Import Data**
```bash
-- Jalankan di pgAdmin Query Tool
02_insert_data.sql
```

**4. Eksplorasi Data (Opsional)**
```bash
-- Jalankan query analisis
03_analysis_queries.sql
```

**5. Buka Dashboard**
- Buka file `Dashboard_FreshMart_Supermarket_Analytics.pbix` di Power BI Desktop
- Jika diminta koneksi ulang: Get Data → PostgreSQL → localhost → freshmart_db

---

## 📐 DAX Measures

```dax
Total Revenue = SUM('public fact_transaksi'[total_bayar])

Total Profit = SUM('public fact_transaksi'[profit])

Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0) * 100

Total Transaksi = DISTINCTCOUNT('public fact_transaksi'[transaksi_id])

Total Qty = SUM('public fact_transaksi'[qty])

Avg Transaction Value = DIVIDE([Total Revenue], [Total Transaksi], 0)
```

---

## 🔍 SQL Analysis Highlights

```sql
-- Ranking Cabang berdasarkan Revenue
SELECT
    c.nama_cabang,
    SUM(t.total_bayar) AS revenue,
    RANK() OVER (ORDER BY SUM(t.total_bayar) DESC) AS rank_revenue
FROM fact_transaksi t
JOIN dim_cabang c ON t.cabang_id = c.cabang_id
GROUP BY c.nama_cabang
ORDER BY rank_revenue;

-- Revenue Kumulatif per Bulan (Running Total)
SELECT
    bulan,
    SUM(total_bayar) AS revenue_bulanan,
    SUM(SUM(total_bayar)) OVER (ORDER BY bulan) AS revenue_kumulatif
FROM fact_transaksi
GROUP BY bulan
ORDER BY bulan;
```

---

## 👤 Author

**Vezan Hidayatullah**
- 📧 hidyatullahvezan@gmail.com
- 🌐 [vezanhd.github.io](https://vezanhd.github.io)
- 💼 [LinkedIn](https://linkedin.com/in/vezanhidayatullah)
- 🐙 [GitHub](https://github.com/vezanhd)

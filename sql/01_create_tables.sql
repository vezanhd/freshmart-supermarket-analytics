-- ============================================================
-- PROJECT: FreshMart Supermarket Analytics
-- DATABASE: freshmart_db
-- Author: Vezan Hidayatullah
-- ============================================================

-- STEP 1: Buat Database (jalankan di pgAdmin Query Tool)
-- CREATE DATABASE freshmart_db;

-- ============================================================
-- STEP 2: Buat semua tabel
-- ============================================================

-- Tabel 1: dim_produk
CREATE TABLE IF NOT EXISTS dim_produk (
    produk_id       VARCHAR(10) PRIMARY KEY,
    nama_produk     VARCHAR(100) NOT NULL,
    kategori        VARCHAR(50) NOT NULL,
    supplier        VARCHAR(50) NOT NULL,
    harga_beli      INTEGER NOT NULL,
    harga_jual      INTEGER NOT NULL,
    margin_pct      DECIMAL(5,1) NOT NULL
);

-- Tabel 2: dim_cabang
CREATE TABLE IF NOT EXISTS dim_cabang (
    cabang_id       VARCHAR(10) PRIMARY KEY,
    nama_cabang     VARCHAR(100) NOT NULL,
    kota            VARCHAR(50) NOT NULL,
    provinsi        VARCHAR(50) NOT NULL
);

-- Tabel 3: dim_customer
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id     VARCHAR(10) PRIMARY KEY,
    nama_customer   VARCHAR(100) NOT NULL,
    segmen          VARCHAR(30) NOT NULL,
    kota            VARCHAR(50) NOT NULL,
    jenis_kelamin   VARCHAR(15) NOT NULL
);

-- Tabel 4: fact_transaksi
CREATE TABLE IF NOT EXISTS fact_transaksi (
    transaksi_id        VARCHAR(15) PRIMARY KEY,
    tanggal             DATE NOT NULL,
    bulan               INTEGER NOT NULL,
    kuartal             VARCHAR(5) NOT NULL,
    hari_dalam_minggu   VARCHAR(15) NOT NULL,
    cabang_id           VARCHAR(10) REFERENCES dim_cabang(cabang_id),
    customer_id         VARCHAR(10) REFERENCES dim_customer(customer_id),
    produk_id           VARCHAR(10) REFERENCES dim_produk(produk_id),
    qty                 INTEGER NOT NULL,
    harga_jual_satuan   INTEGER NOT NULL,
    harga_beli_satuan   INTEGER NOT NULL,
    subtotal            INTEGER NOT NULL,
    diskon_pct          DECIMAL(4,2) NOT NULL,
    diskon_nominal      INTEGER NOT NULL,
    total_bayar         INTEGER NOT NULL,
    total_hpb           INTEGER NOT NULL,
    profit              INTEGER NOT NULL
);

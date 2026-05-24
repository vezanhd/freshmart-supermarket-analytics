-- ============================================================
-- PROJECT: FreshMart Supermarket Analytics
-- QUERY ANALYSIS: Sales, Profit, Customer, Product Performance
-- Author: Vezan Hidayatullah
-- ============================================================


-- ============================================================
-- SECTION 1: OVERVIEW BISNIS (Basic JOIN + Agregasi)
-- ============================================================

-- 1.1 Total Revenue, Profit, dan Transaksi Keseluruhan
SELECT
    COUNT(DISTINCT t.transaksi_id)          AS total_transaksi,
    COUNT(t.produk_id)                      AS total_item_terjual,
    SUM(t.subtotal)                         AS total_revenue_kotor,
    SUM(t.diskon_nominal)                   AS total_diskon,
    SUM(t.total_bayar)                      AS total_revenue_bersih,
    SUM(t.total_hpb)                        AS total_harga_pokok,
    SUM(t.profit)                           AS total_profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t;


-- 1.2 Revenue & Profit per Bulan (Tren Bulanan)
SELECT
    t.bulan,
    TO_CHAR(TO_DATE(t.bulan::TEXT, 'MM'), 'Month') AS nama_bulan,
    t.kuartal,
    COUNT(DISTINCT t.transaksi_id)          AS total_transaksi,
    SUM(t.total_bayar)                      AS revenue,
    SUM(t.profit)                           AS profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
GROUP BY t.bulan, t.kuartal
ORDER BY t.bulan;


-- 1.3 Revenue & Profit per Kuartal
SELECT
    kuartal,
    COUNT(DISTINCT transaksi_id)    AS total_transaksi,
    SUM(total_bayar)                AS revenue,
    SUM(profit)                     AS profit,
    ROUND(SUM(profit)::NUMERIC / SUM(total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi
GROUP BY kuartal
ORDER BY kuartal;


-- ============================================================
-- SECTION 2: ANALISIS CABANG & WILAYAH (JOIN + GROUP BY)
-- ============================================================

-- 2.1 Performa Revenue & Profit per Cabang
SELECT
    c.cabang_id,
    c.nama_cabang,
    c.kota,
    c.provinsi,
    COUNT(DISTINCT t.transaksi_id)  AS total_transaksi,
    SUM(t.qty)                      AS total_qty,
    SUM(t.total_bayar)              AS revenue,
    SUM(t.profit)                   AS profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
JOIN dim_cabang c ON t.cabang_id = c.cabang_id
GROUP BY c.cabang_id, c.nama_cabang, c.kota, c.provinsi
ORDER BY revenue DESC;


-- 2.2 Performa per Provinsi / Region
SELECT
    c.provinsi,
    COUNT(DISTINCT c.cabang_id)     AS jumlah_cabang,
    COUNT(DISTINCT t.transaksi_id)  AS total_transaksi,
    SUM(t.total_bayar)              AS revenue,
    SUM(t.profit)                   AS profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
JOIN dim_cabang c ON t.cabang_id = c.cabang_id
GROUP BY c.provinsi
ORDER BY revenue DESC;


-- 2.3 Ranking Cabang berdasarkan Revenue (Window Function - RANK)
SELECT
    c.nama_cabang,
    c.kota,
    c.provinsi,
    SUM(t.total_bayar)  AS revenue,
    SUM(t.profit)       AS profit,
    RANK() OVER (ORDER BY SUM(t.total_bayar) DESC) AS rank_revenue,
    RANK() OVER (ORDER BY SUM(t.profit) DESC)      AS rank_profit
FROM fact_transaksi t
JOIN dim_cabang c ON t.cabang_id = c.cabang_id
GROUP BY c.nama_cabang, c.kota, c.provinsi
ORDER BY rank_revenue;


-- ============================================================
-- SECTION 3: ANALISIS PRODUK & KATEGORI
-- ============================================================

-- 3.1 Revenue & Profit per Kategori Produk
SELECT
    p.kategori,
    COUNT(DISTINCT p.produk_id)     AS jumlah_produk,
    SUM(t.qty)                      AS total_qty_terjual,
    SUM(t.total_bayar)              AS revenue,
    SUM(t.profit)                   AS profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
JOIN dim_produk p ON t.produk_id = p.produk_id
GROUP BY p.kategori
ORDER BY revenue DESC;


-- 3.2 Top 10 Produk Terlaris berdasarkan Revenue
SELECT
    p.produk_id,
    p.nama_produk,
    p.kategori,
    p.supplier,
    SUM(t.qty)          AS total_qty,
    SUM(t.total_bayar)  AS revenue,
    SUM(t.profit)       AS profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
JOIN dim_produk p ON t.produk_id = p.produk_id
GROUP BY p.produk_id, p.nama_produk, p.kategori, p.supplier
ORDER BY revenue DESC
LIMIT 10;


-- 3.3 Top 10 Produk Paling Profitable
SELECT
    p.nama_produk,
    p.kategori,
    SUM(t.qty)          AS total_qty,
    SUM(t.total_bayar)  AS revenue,
    SUM(t.profit)       AS profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
JOIN dim_produk p ON t.produk_id = p.produk_id
GROUP BY p.nama_produk, p.kategori
ORDER BY profit DESC
LIMIT 10;


-- 3.4 Performa Supplier berdasarkan Revenue
SELECT
    p.supplier,
    COUNT(DISTINCT p.produk_id)     AS jumlah_produk,
    SUM(t.qty)                      AS total_qty,
    SUM(t.total_bayar)              AS revenue,
    SUM(t.profit)                   AS profit,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
JOIN dim_produk p ON t.produk_id = p.produk_id
GROUP BY p.supplier
ORDER BY revenue DESC;


-- ============================================================
-- SECTION 4: ANALISIS CUSTOMER & SEGMEN
-- ============================================================

-- 4.1 Revenue per Segmen Customer
SELECT
    c.segmen,
    COUNT(DISTINCT c.customer_id)   AS jumlah_customer,
    COUNT(DISTINCT t.transaksi_id)  AS total_transaksi,
    SUM(t.total_bayar)              AS revenue,
    SUM(t.profit)                   AS profit,
    ROUND(AVG(t.total_bayar), 0)    AS avg_transaksi_value,
    ROUND(SUM(t.profit)::NUMERIC / SUM(t.total_bayar) * 100, 2) AS profit_margin_pct
FROM fact_transaksi t
JOIN dim_customer c ON t.customer_id = c.customer_id
GROUP BY c.segmen
ORDER BY revenue DESC;


-- 4.2 Top 10 Customer berdasarkan Total Belanja (JOIN 3 tabel)
SELECT
    c.customer_id,
    c.nama_customer,
    c.segmen,
    c.kota,
    COUNT(DISTINCT t.transaksi_id)  AS total_transaksi,
    SUM(t.total_bayar)              AS total_belanja,
    SUM(t.diskon_nominal)           AS total_diskon_diterima,
    SUM(t.profit)                   AS profit_dari_customer
FROM fact_transaksi t
JOIN dim_customer c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.nama_customer, c.segmen, c.kota
ORDER BY total_belanja DESC
LIMIT 10;


-- 4.3 Distribusi Transaksi berdasarkan Hari dalam Minggu
SELECT
    hari_dalam_minggu,
    COUNT(DISTINCT transaksi_id)    AS total_transaksi,
    SUM(total_bayar)                AS revenue,
    ROUND(AVG(total_bayar), 0)      AS avg_revenue_per_transaksi
FROM fact_transaksi
GROUP BY hari_dalam_minggu
ORDER BY revenue DESC;


-- ============================================================
-- SECTION 5: ADVANCED QUERIES (Window Function + CTE)
-- ============================================================

-- 5.1 Revenue Kumulatif per Bulan (Running Total - Window Function)
SELECT
    bulan,
    TO_CHAR(TO_DATE(bulan::TEXT, 'MM'), 'Month') AS nama_bulan,
    SUM(total_bayar)    AS revenue_bulanan,
    SUM(SUM(total_bayar)) OVER (ORDER BY bulan)  AS revenue_kumulatif,
    SUM(profit)         AS profit_bulanan,
    SUM(SUM(profit)) OVER (ORDER BY bulan)       AS profit_kumulatif
FROM fact_transaksi
GROUP BY bulan
ORDER BY bulan;


-- 5.2 Kontribusi Revenue per Cabang terhadap Total (Window Function)
SELECT
    c.nama_cabang,
    c.kota,
    SUM(t.total_bayar)  AS revenue,
    ROUND(
        SUM(t.total_bayar)::NUMERIC /
        SUM(SUM(t.total_bayar)) OVER () * 100, 2
    ) AS pct_kontribusi_revenue
FROM fact_transaksi t
JOIN dim_cabang c ON t.cabang_id = c.cabang_id
GROUP BY c.nama_cabang, c.kota
ORDER BY revenue DESC;


-- 5.3 CTE: Cabang di Atas Rata-Rata Revenue
WITH avg_revenue AS (
    SELECT AVG(total_revenue) AS rata_rata
    FROM (
        SELECT cabang_id, SUM(total_bayar) AS total_revenue
        FROM fact_transaksi
        GROUP BY cabang_id
    ) sub
),
cabang_revenue AS (
    SELECT
        c.nama_cabang,
        c.kota,
        c.provinsi,
        SUM(t.total_bayar) AS revenue,
        SUM(t.profit)      AS profit
    FROM fact_transaksi t
    JOIN dim_cabang c ON t.cabang_id = c.cabang_id
    GROUP BY c.nama_cabang, c.kota, c.provinsi
)
SELECT
    cr.nama_cabang,
    cr.kota,
    cr.provinsi,
    cr.revenue,
    cr.profit,
    ar.rata_rata,
    CASE WHEN cr.revenue > ar.rata_rata
         THEN 'Di Atas Rata-Rata'
         ELSE 'Di Bawah Rata-Rata'
    END AS status_performa
FROM cabang_revenue cr
CROSS JOIN avg_revenue ar
ORDER BY cr.revenue DESC;


-- 5.4 CTE: Produk dengan Revenue di Atas Rata-Rata per Kategori
WITH revenue_per_produk AS (
    SELECT
        p.produk_id,
        p.nama_produk,
        p.kategori,
        SUM(t.total_bayar) AS revenue,
        SUM(t.profit)      AS profit
    FROM fact_transaksi t
    JOIN dim_produk p ON t.produk_id = p.produk_id
    GROUP BY p.produk_id, p.nama_produk, p.kategori
),
avg_per_kategori AS (
    SELECT kategori, AVG(revenue) AS avg_revenue_kategori
    FROM revenue_per_produk
    GROUP BY kategori
)
SELECT
    r.nama_produk,
    r.kategori,
    r.revenue,
    r.profit,
    ROUND(a.avg_revenue_kategori, 0) AS avg_kategori,
    CASE WHEN r.revenue > a.avg_revenue_kategori
         THEN '⭐ Di Atas Rata-Rata'
         ELSE 'Di Bawah Rata-Rata'
    END AS status
FROM revenue_per_produk r
JOIN avg_per_kategori a ON r.kategori = a.kategori
ORDER BY r.kategori, r.revenue DESC;


-- 5.5 Full JOIN 4 Tabel: Detail Transaksi Lengkap (Sample 20 rows)
SELECT
    t.transaksi_id,
    t.tanggal,
    t.kuartal,
    t.hari_dalam_minggu,
    cb.nama_cabang,
    cb.kota,
    cb.provinsi,
    cu.nama_customer,
    cu.segmen,
    p.nama_produk,
    p.kategori,
    p.supplier,
    t.qty,
    t.harga_jual_satuan,
    t.diskon_pct,
    t.total_bayar,
    t.profit
FROM fact_transaksi t
JOIN dim_cabang  cb ON t.cabang_id  = cb.cabang_id
JOIN dim_customer cu ON t.customer_id = cu.customer_id
JOIN dim_produk   p  ON t.produk_id   = p.produk_id
ORDER BY t.tanggal DESC
LIMIT 20;

--SQL Project: CRM Sales Opportunities

--Data Understanding
select * from accounts a;
select distinct sector, count(account) as total_account from accounts a group by sector order by total_account desc;
select min(year_established), max(year_established) from accounts a;
select min(revenue), max(revenue) from accounts a;
select * from accounts a where year_established  = (select max(year_established) from accounts a);
select * from accounts a where year_established  = (select min(year_established) from accounts a);
select * from accounts a where employees  = (select max(employees) from accounts a);
select * from accounts a where employees  = (select min(employees) from accounts a);
select * from accounts a where revenue = (select max(revenue) from accounts a);
select * from accounts a where revenue = (select min(revenue) from accounts a);
select office_location, count(*) as total_accounts from accounts a group by office_location;
select avg(employees) from accounts a;
select * from accounts a where employees > 5000 order by employees asc;
select avg(revenue) from accounts a;
select * from accounts a where revenue >5000 order by revenue asc;


select * from products p;
select distinct series, count(*) as total_product from products p group by series;
select * from products p where sales_price = (select max(sales_price) from products p);
select * from products p where sales_price = (select min(sales_price) from products p);
select avg(sales_price) from products p;
select * from products p where sales_price >6000;

select * from sales_teams st;
select manager, regional_office, count(sales_agent) as total_agents_managed from sales_teams st group by manager, regional_office;

select * from sales_pipeline sp;
select distinct opportunity_id, count(*) as total_opportunity_id from sales_pipeline sp group by opportunity_id;
select distinct sales_agent, count(*) as total_sales_agent from sales_pipeline sp group by sales_agent;
select distinct product, count(*) as total_product from sales_pipeline sp group by product;
select distinct deal_stage, count(*) as total_deal_stage from sales_pipeline sp group by deal_stage;

--Data Exploration
--1. Melihat total pendapatan per sektor industri
select sector, sum(revenue) as total_revenue from accounts a group by sector order by total_revenue desc;
--2. Menampilkan jumlah penjualan per produk
select distinct deal_stage from sales_pipeline sp;
select * from sales_pipeline sp;
select product,
	   sum(case when deal_stage = 'Won' then 1 else 0 end) as total_won,
	   sum(case when deal_stage = 'Lost' then 1 else 0 end) as total_lost,
	   sum(case when deal_stage = 'Prospecting' then 1 else 0 end) as total_prospecting,
	   sum(case when deal_stage = 'Engaging' then 1 else 0 end) as total_engaging
from sales_pipeline sp group by product order by total_won desc;
--3. Menghitung jumlah kesepakatan yang berhasil dan gagal per tahapan penjualan
select deal_stage, count(*) as total_deals from sales_pipeline sp group by deal_stage;
--4. Menampilkan jumlah karyawan perusahaan bersubsidi
select a.account, a.subsidiary_of, a.employees from accounts as a inner join accounts as b on a.subsidiary_of = b.account order by a.employees desc;
--5. Melihat total pendapatan tahunan per kantor pusat
select office_location, sum(revenue) as total_revenue from accounts a group by office_location order by total_revenue desc;


-- 1. Kinerja Tim Penjualan
--Membandingkan kinerja setiap tim penjualan berdasarkan total nilai kesepakatan yang dimenangkan:
SELECT st.manager, st.regional_office, COUNT(sp.opportunity_id) AS won_deals, SUM(sp.close_value) AS total_revenue
FROM sales_pipeline sp
JOIN sales_teams st ON sp.sales_agent = st.sales_agent
WHERE sp.deal_stage = 'Won'
GROUP BY st.manager, st.regional_office
ORDER BY total_revenue DESC;

-- 2. Agen Penjualan yang Tertinggal
--Mengidentifikasi agen penjualan yang memiliki performa terendah berdasarkan total nilai kesepakatan yang dimenangkan
--Mengidentifikasi agen penjualan yang mungkin tertinggal dengan melihat 10 agen dengan performa terendah.
SELECT sp.sales_agent, COUNT(sp.opportunity_id) AS won_deals, SUM(sp.close_value) AS total_revenue
FROM sales_pipeline sp
WHERE sp.deal_stage = 'Won'
GROUP BY sp.sales_agent
ORDER BY total_revenue ASC
LIMIT 10;

-- 3. Tren Kuartal ke Kuartal
--Melihat tren nilai kesepakatan yang dimenangkan per kuartal:
--Mengidentifikasi tren penjualan kuartal ke kuartal berdasarkan jumlah dan nilai kesepakatan yang dimenangkan.
select
    concat(extract(year from TO_DATE(sp.close_date, 'MM/DD/YYYY')), ' Q', extract(quarter from TO_DATE(sp.close_date, 'MM/DD/YYYY'))) as quarter,
    count(sp.opportunity_id) as won_deals,
    sum(sp.close_value) as total_revenue
from sales_pipeline sp where sp.deal_stage = 'Won'
group by extract(year from TO_DATE(sp.close_date, 'MM/DD/YYYY')), extract(quarter from TO_DATE(sp.close_date, 'MM/DD/YYYY'))
order by extract(year from TO_DATE(sp.close_date, 'MM/DD/YYYY')), extract(quarter from TO_DATE(sp.close_date, 'MM/DD/YYYY'));

select * from sales_pipeline sp;

-- 4. Tingkat Kemenangan Produk
--Menghitung tingkat kemenangan setiap produk:
--Mengidentifikasi produk mana yang memiliki tingkat kemenangan tertinggi.
select
    sp.product,
    count(case when sp.deal_stage = 'Won' then 1 end) as won_deals,
    count(sp.opportunity_id) as total_deals,
    round(cast(count(case when sp.deal_stage = 'Won' then 1 end) as decimal) / count(sp.opportunity_id) * 100, 2) as win_rate_percentage
from sales_pipeline sp
group by sp.product
order by win_rate_percentage desc;


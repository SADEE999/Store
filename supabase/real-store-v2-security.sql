-- SADEE XDIMA REAL STORE V2: run once in Supabase SQL Editor.
-- First inspect duplicate rows. If either query returns rows, resolve those records
-- manually before creating the unique indexes. Do not delete paid orders blindly.
select lower(btrim(payment_reference)) as normalized_reference, count(*)
from public.store_orders
where payment_reference is not null and btrim(payment_reference) <> ''
group by lower(btrim(payment_reference)) having count(*) > 1;

select lower(btrim(license_key)) as normalized_license_key, count(*)
from public.store_orders
where license_key is not null and btrim(license_key) <> ''
group by lower(btrim(license_key)) having count(*) > 1;

-- Normalize whitespace at storage level and enforce one reference / one key globally.
create unique index if not exists store_orders_payment_reference_normalized_uq
on public.store_orders (lower(btrim(regexp_replace(payment_reference, '\\s+', ' ', 'g'))));

create unique index if not exists store_orders_license_key_normalized_uq
on public.store_orders (lower(btrim(license_key))) where license_key is not null;

-- Keep the server-only order table inaccessible to public client roles.
alter table public.store_orders enable row level security;
revoke all on public.store_orders from anon, authenticated;
grant all on public.store_orders to service_role;

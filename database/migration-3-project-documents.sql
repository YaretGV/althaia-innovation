-- ============================================================
-- ALTHAIA INNOVACIÓ — Migració 3: Documentació de projectes
-- ============================================================
-- Crea l'espai de fitxers i prepara la taula documents existent
-- per associar fitxers a projectes.
--
-- Executa aquest fitxer a:
-- Supabase → SQL Editor → New Query
-- ============================================================

-- Bucket públic per als documents del projecte.
-- La metadada i els permisos de l'aplicació continuen passant per la
-- taula documents i pel backend /api/db.
insert into storage.buckets (id, name, public)
values ('project-documents', 'project-documents', true)
on conflict (id) do update set public = true;

-- La taula documents ja existeix a database/schema.sql.
-- Aquestes ordres també funcionen si la migració es repeteix.
alter table documents enable row level security;

drop policy if exists select_documents on documents;
create policy select_documents
  on documents for select
  using (true);

-- Les escriptures de metadades es fan amb la service role a través de /api/db.
drop policy if exists insert_documents on documents;
drop policy if exists update_documents on documents;
drop policy if exists delete_documents on documents;

-- Storage: lectura pública perquè els fitxers es puguin obrir directament
-- des de la web. Les rutes sempre s'organitzen per projecte.
drop policy if exists project_documents_read on storage.objects;
create policy project_documents_read
  on storage.objects for select
  using (bucket_id = 'project-documents');

drop policy if exists project_documents_insert on storage.objects;
create policy project_documents_insert
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'project-documents');

drop policy if exists project_documents_delete on storage.objects;
create policy project_documents_delete
  on storage.objects for delete
  to anon, authenticated
  using (bucket_id = 'project-documents');

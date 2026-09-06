/* ============================================================
   OPTIONAL Supabase backend for short share-links.
   ------------------------------------------------------------
   Leave both values EMPTY to keep the app 100% serverless:
   share-links then travel compressed inside the URL itself.

   To enable short links (#s=xxxxxxxx):
     1. Create a project at https://supabase.com
     2. Run supabase/schema.sql in the project's SQL editor
     3. Project Settings → API → copy "Project URL" and
        the "anon public" / "publishable" key (sb_publishable_…) into the two fields below
     4. Redeploy this folder
   The anon key is SAFE to ship: Row-Level-Security limits it to
   inserting and reading quiz_sets rows — nothing else.
   ============================================================ */
window.SUPABASE_CONFIG = {
  url: "https://bnlstzibpceptcjifixy.supabase.co",
  anonKey: "sb_publishable_kFc5yTFXgTH8w-SWsd2BOg_t5PTF455",
};

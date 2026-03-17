-- Adds minimal columns for Google/Apple sign-in to the existing NeonDB `users` table.
-- Idempotent: safe to run multiple times.

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS google_id varchar(255);

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS apple_id varchar(255);

-- Ensure provider subject identifiers are unique when present.
-- Partial unique indexes allow multiple NULL values.
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_google_id
    ON public.users (google_id)
    WHERE google_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_apple_id
    ON public.users (apple_id)
    WHERE apple_id IS NOT NULL;

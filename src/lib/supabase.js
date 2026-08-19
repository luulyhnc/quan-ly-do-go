import { createClient } from '@supabase/supabase-js'
const url = import.meta.env.VITE_SUPABASE_URL?.trim()
const key = import.meta.env.VITE_SUPABASE_ANON_KEY?.trim()
const validUrl = /^https:\/\/[a-z0-9-]+\.supabase\.co$/.test(url || '')
export const configError = key?.toLowerCase().includes('service_role') ? 'Không được dùng service-role key ở frontend.' : (url && !validUrl ? 'VITE_SUPABASE_URL không hợp lệ.' : '')
export const isSupabaseConfigured = Boolean(url && key && validUrl && !configError)
export const supabase = isSupabaseConfigured ? createClient(url, key) : null

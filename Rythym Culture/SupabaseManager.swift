// SupabaseManager.swift
// Single shared Supabase client — import Supabase wherever you need DB/auth access.
//
// SETUP: Add the Swift Package before building:
//   Xcode → File → Add Package Dependencies...
//   URL: https://github.com/supabase/supabase-swift
//   Version: Up to Next Major from 2.0.0

import Supabase
import Foundation

let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.projectURL)!,
    supabaseKey: SupabaseConfig.anonKey
)

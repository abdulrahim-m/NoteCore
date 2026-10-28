//! FFI bindings for `notecore`.
//!
//! Layout:
//! * [`dto`]   - plain, FFI-friendly data types + conversions from the core `UI*` types.
//!               No bridge-specific code lives here, so other targets (UniFFI, JNI,
//!               a C ABI, ...) can reuse it.
//! * [`error`] - the single error type every bridged function returns.
//! * [`api`]   - the flutter_rust_bridge surface.

pub mod api;
pub mod dto;
pub mod error;
pub mod frb_generated;
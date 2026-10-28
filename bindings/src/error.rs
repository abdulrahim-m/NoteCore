use std::fmt;

use notecore::utils::app_error::{AppError, ErrorType};

/// Mirrors `notecore::utils::app_error::ErrorType`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ApiErrorKind {
    Internal,
    Forbidden,
    Validation,
}

/// The error every bridged function returns. On the Dart side it is thrown as an exception.
#[derive(Debug, Clone)]
pub struct ApiError {
    pub kind: ApiErrorKind,
    pub message: String,
}

impl ApiError {
    pub fn validation(message: impl Into<String>) -> Self {
        ApiError {
            kind: ApiErrorKind::Validation,
            message: message.into(),
        }
    }
}

impl From<ErrorType> for ApiErrorKind {
    fn from(t: ErrorType) -> Self {
        match t {
            ErrorType::Internal => ApiErrorKind::Internal,
            ErrorType::Forbidden => ApiErrorKind::Forbidden,
            ErrorType::Validation => ApiErrorKind::Validation,
        }
    }
}

impl From<AppError> for ApiError {
    fn from(e: AppError) -> Self {
        ApiError {
            kind: e.error_type.into(),
            message: e.message,
        }
    }
}

impl From<sqlx::Error> for ApiError {
    fn from(e: sqlx::Error) -> Self {
        AppError::from(e).into()
    }
}

impl fmt::Display for ApiError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}: {}", self.kind, self.message)
    }
}

impl std::error::Error for ApiError {}

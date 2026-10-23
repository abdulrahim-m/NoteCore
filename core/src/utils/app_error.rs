#[derive(Debug)]
pub enum ErrorType{
    Internal,
    Forbidden,
    Validation
}

#[derive(Debug)]
pub struct AppError{
    pub text: String,
    pub err_type: ErrorType
}

impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        AppError{
            text: err.to_string(),
            err_type: ErrorType::Internal
        }
    }
}

impl AppError {
    pub fn new(err: &str, err_type: ErrorType) -> Self {
        AppError{
            text: err.to_string(),
            err_type
        }
    }
}


pub type Result<T, E = AppError> = ::std::result::Result<T, E>;
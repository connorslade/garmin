use axum::{
    body::Body,
    http::{Response, StatusCode},
    response::IntoResponse,
};

pub type AnyResult<T> = axum::response::Result<T, AnyError>;
pub struct AnyError(anyhow::Error);

impl IntoResponse for AnyError {
    fn into_response(self) -> Response<Body> {
        let msg = format!("Internal server error: {}", self.0);
        (StatusCode::INTERNAL_SERVER_ERROR, msg).into_response()
    }
}

impl<E> From<E> for AnyError
where
    E: Into<anyhow::Error>,
{
    fn from(err: E) -> Self {
        Self(err.into())
    }
}

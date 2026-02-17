use std::sync::Arc;

use axum::{
    Form,
    extract::{Path, State},
};
use serde::Deserialize;

use crate::{app::App, misc::AnyResult};

#[derive(Deserialize)]
pub struct Body {
    value: u8,
}

pub async fn post(
    State(app): State<Arc<App>>,
    Path(id): Path<String>,
    Form(body): Form<Body>,
) -> AnyResult<()> {
    app.request::<()>(&format!("/rest/nodes/{id}/cmd/DON/{}", body.value))
        .await?;
    Ok(())
}

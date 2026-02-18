use std::{fs, sync::Arc};

use anyhow::Result;
use axum::{
    Router,
    extract::{Request, State},
    middleware::{self, Next},
    response::Response,
    routing::{get, post},
};
use tokio::net::TcpListener;

use crate::app::App;

mod app;
mod misc;
mod routes;

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<()> {
    let config_file = fs::read("config.toml")?;
    let config = toml::from_slice(&config_file)?;
    let state = Arc::new(App::new(config));

    let listener = TcpListener::bind(&state.config.api.address).await.unwrap();
    let app = Router::new()
        .route("/devices", get(routes::devices::get))
        .route("/device/{id}", post(routes::device::post))
        .layer(middleware::from_fn_with_state(state.clone(), auth))
        .with_state(state);

    axum::serve(listener, app).await?;
    Ok(())
}

async fn auth(State(app): State<Arc<App>>, request: Request, next: Next) -> Response {
    if let Some(header) = request.headers().get("Authorization")
        && let Ok(auth) = header.to_str()
        && auth == app.config.api.authentication
    {
        return next.run(request).await;
    }

    Response::builder()
        .status(401)
        .body("Unauthorized".into())
        .unwrap()
}

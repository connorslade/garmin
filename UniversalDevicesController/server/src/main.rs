use std::sync::Arc;

use axum::{
    Router,
    extract::{Request, State},
    middleware::{self, Next},
    response::Response,
    routing::{get, post},
};
use reqwest::Client;
use tokio::net::TcpListener;

use crate::app::{ApiConfig, App, Config, ControllerConfig};

mod app;
mod misc;
mod routes;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let config = Config {
        api: ApiConfig {
            address: "0.0.0.0:3000".into(),
            authentication: "DPR&j8Vr*s4KxJwfWcB2MJahhXZhun0P".into(),
        },
        controller: ControllerConfig {
            host: "http://192.168.1.67".into(),
            username: "admin".into(),
            password: "admin".into(),
        },
    };

    let state = Arc::new(App {
        client: Client::new(),
        config,
    });

    let listener = TcpListener::bind(&state.config.api.address).await.unwrap();
    let app = Router::new()
        .route("/devices", get(routes::devices::get))
        .route("/device/{id}", post(routes::device::post))
        .layer(middleware::from_fn_with_state(state.clone(), auth))
        .with_state(state);

    axum::serve(listener, app).await.unwrap();
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

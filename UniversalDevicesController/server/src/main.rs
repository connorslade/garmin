use std::{str::FromStr, sync::Arc};

use axum::{
    Router,
    routing::{get, post},
};
use reqwest::Client;
use tokio::net::TcpListener;
use url::Url;

use crate::app::{App, Config};

mod app;
mod misc;
mod routes;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let config = Config {
        host: Url::from_str("http://192.168.1.67").unwrap(),
        username: "admin".into(),
        password: "admin".into(),
    };

    let state = App {
        client: Client::new(),
        config,
    };

    let app = Router::new()
        .route("/devices", get(routes::devices::get))
        .route("/device/{id}", post(routes::device::post))
        .with_state(Arc::new(state));

    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

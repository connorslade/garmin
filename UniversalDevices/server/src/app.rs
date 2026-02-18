use anyhow::Result;
use base64::{Engine, prelude::BASE64_STANDARD};
use reqwest::Client;
use serde::Deserialize;

pub struct App {
    pub config: Config,
    pub client: Client,
}

#[derive(Deserialize)]
pub struct Config {
    pub api: ApiConfig,
    pub controller: ControllerConfig,
}

#[derive(Deserialize)]
pub struct ApiConfig {
    pub address: String,
    pub authentication: String,
}

#[derive(Deserialize)]
pub struct ControllerConfig {
    pub host: String,
    pub username: String,
    pub password: String,
}

impl ControllerConfig {
    pub fn auth(&self) -> String {
        BASE64_STANDARD.encode(format!("{}:{}", self.username, self.password))
    }
}

impl App {
    pub fn new(config: Config) -> Self {
        Self { config, client: Client::new() }
    }

    pub async fn request<'a, T: Deserialize<'a>>(&self, path: &str) -> Result<T> {
        let url = self.config.controller.host.clone() + path;
        let auth = self.config.controller.auth();

        let request = (self.client.get(url)).header("Authorization", format!("Basic {auth}"));
        let response = request.send().await?;

        let text = response.text().await?;
        Ok(serde_xml_rs::from_str::<T>(&text)?)
    }
}

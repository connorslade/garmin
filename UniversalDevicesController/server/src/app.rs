use anyhow::Result;
use base64::{Engine, prelude::BASE64_STANDARD};
use reqwest::Client;
use serde::Deserialize;
use url::Url;

pub struct App {
    pub config: Config,
    pub client: Client,
}

pub struct Config {
    pub host: Url,
    pub username: String,
    pub password: String,
}

impl Config {
    pub fn auth(&self) -> String {
        BASE64_STANDARD.encode(format!("{}:{}", self.username, self.password))
    }
}

impl App {
    pub async fn request<'a, T: Deserialize<'a>>(&self, path: &str) -> Result<T> {
        let url = self.config.host.join(path)?;
        let auth = self.config.auth();

        let request = (self.client.get(url)).header("Authorization", format!("Basic {auth}"));
        let response = request.send().await?;

        let text = response.text().await?;
        Ok(serde_xml_rs::from_str::<T>(&text)?)
    }
}

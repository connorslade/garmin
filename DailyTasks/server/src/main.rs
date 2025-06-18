use std::{
    env, fs,
    path::{Path, PathBuf},
};

use afire::{Content, Method, Server};
use anyhow::Result;
use chrono::{Local, NaiveDate};
use serde::Serialize;
use serde_json::json;

use crate::markdown::extract_tasks;

mod markdown;

struct App {
    path: PathBuf,
}

#[derive(Serialize)]
struct Task {
    content: String,
    complete: bool,
    children: Vec<Task>,
}

fn main() -> Result<()> {
    dotenv::dotenv()?;

    let host = env::var("HOST")?;
    let port = env::var("PORT")?.parse()?;
    let path = env::var("DAILY")?.into();

    let mut server = Server::builder(host, port, App { path })
        .keep_alive(false)
        .build()?;

    server.route(Method::GET, "/api/private/tasks/{date}", |ctx| {
        let date = NaiveDate::parse_from_str(ctx.param_idx(0), "%Y-%m-%d")?;
        let tasks = handle(&ctx.app().path, date)?;

        ctx.text(json!(tasks)).content(Content::JSON).send()?;
        Ok(())
    });

    server.route(Method::GET, "/api/private/tasks/today", |ctx| {
        let tasks = handle(&ctx.app().path, current_date())?;

        ctx.text(json!(tasks)).content(Content::JSON).send()?;
        Ok(())
    });

    server.run()?;

    Ok(())
}

fn current_date() -> NaiveDate {
    Local::now().date_naive()
}

fn file_path(date: NaiveDate) -> PathBuf {
    date.format("%Y/%m/%Y-%m-%d.md").to_string().into()
}

fn handle(root: &Path, date: NaiveDate) -> Result<Vec<Task>> {
    let path = root.join(file_path(date));
    let content = fs::read_to_string(path)?;
    Ok(extract_tasks(&content)?)
}

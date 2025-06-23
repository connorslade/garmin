use std::{collections::HashMap, env, fs, path::PathBuf};

use afire::{Content, Method, Server, route::RouteContext};
use anyhow::Result;
use chrono::{Datelike, NaiveDate};
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

    server.route(Method::GET, "/api/private/tasks/{year}/{month}", |ctx| {
        let year = ctx.param_idx(0).parse()?;
        let month = ctx.param_idx(1).parse()?;
        let date = NaiveDate::default()
            .with_year(year)
            .context("Invalid year")?
            .with_month(month)
            .context("Invalid month")?;

        let mut tasks = HashMap::new();

        let dir = ctx.app().path.join(folder_path(date));
        for file in fs::read_dir(dir)?.filter_map(|x| x.ok()) {
            if file.file_type().map(|x| !x.is_file()).unwrap_or_default() {
                continue;
            }

            let date = file.file_name();
            let Ok(date) = NaiveDate::parse_from_str(&date.to_string_lossy(), "%Y-%m-%d.md") else {
                continue;
            };

            let content = fs::read_to_string(file.path())?;
            if let Ok(result) = extract_tasks(&content) {
                tasks.insert(date.format("%Y-%m-%d").to_string(), result);
            }
        }

        ctx.text(json!(tasks)).content(Content::JSON).send()?;
        Ok(())
    });

    server.run()?;

    Ok(())
}

fn folder_path(date: NaiveDate) -> PathBuf {
    date.format("%Y/%m").to_string().into()
}

use std::sync::Arc;

use axum::{Json, extract::State};
use serde::{Deserialize, Serialize};

use crate::{app::App, misc::AnyResult};

#[derive(Serialize)]
pub struct Device {
    address: String,
    name: String,
    value: u8,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename = "nodes")]
struct Nodes {
    node: Vec<Node>,
}

#[derive(Debug, Deserialize, Serialize)]
struct Node {
    address: String,
    name: String,
    property: Property,
}

#[derive(Debug, Deserialize, Serialize)]
struct Property {
    #[serde(rename = "@id")]
    id: String,
    #[serde(rename = "@value")]
    value: String,
}

impl Node {
    fn into_device(self) -> Option<Device> {
        (self.property.id == "ST").then_some(Device {
            address: self.address,
            name: self.name,
            value: self.property.value.parse().ok()?,
        })
    }
}

pub async fn get(State(app): State<Arc<App>>) -> AnyResult<Json<Vec<Device>>> {
    let nodes = app.request::<Nodes>("/rest/nodes/devices").await?.node;
    let devices = nodes.into_iter().filter_map(|x| x.into_device()).collect();
    Ok(Json(devices))
}

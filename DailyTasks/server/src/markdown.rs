use anyhow::{Context, Result, bail};
use markdown::{
    ParseOptions,
    mdast::{Emphasis, Heading, Link, ListItem, Node, Paragraph, Strong, Text},
};

use crate::Task;

pub fn extract_tasks(raw: &str) -> Result<Vec<Task>> {
    let Ok(root) = markdown::to_mdast(raw, &ParseOptions::gfm()) else {
        bail!("Invalid markdown");
    };

    let children = root.children().context("No children")?;
    let list_start = children
        .iter()
        .position(|x| {
            matches!(
                x,
                Node::Heading(Heading { children, depth: 2, .. })
                if matches!(&children[0], Node::Text(Text { value, .. }) if value == "Todo")
            )
        })
        .context("No Todo section found")?;

    let mut items = Vec::new();

    for i in (list_start + 1).. {
        let tasks = parse_task(&children[i]);
        if tasks.is_empty() {
            break;
        };

        items.extend(tasks);
    }

    Ok(items)
}

fn parse_task(child: &Node) -> Vec<Task> {
    let Node::List(list) = child else {
        return vec![];
    };

    let mut out = Vec::new();
    for child in list.children.iter() {
        let Node::ListItem(item) = child else {
            break;
        };

        out.push(Task {
            content: to_plain_text(child),
            complete: item.checked.unwrap_or_default(),
            children: item.children.iter().flat_map(parse_task).collect(),
        });
    }

    out
}

fn to_plain_text(node: &Node) -> String {
    match node {
        Node::Text(Text { value, .. }) => value.into(),
        Node::Link(Link { title, .. }) => title.as_ref().map(|x| x.to_string()).unwrap_or_default(),
        Node::Strong(Strong { children, .. })
        | Node::Emphasis(Emphasis { children, .. })
        | Node::ListItem(ListItem { children, .. })
        | Node::Paragraph(Paragraph { children, .. }) => {
            let mut out = String::new();
            for item in children {
                out.push_str(&to_plain_text(item));
            }
            out
        }
        _ => String::new(),
    }
}

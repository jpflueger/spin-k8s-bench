use spin_sdk::http::{IntoResponse, Request, Response};
use spin_sdk::http_component;
use serde::Serialize;

#[derive(Serialize)]
struct Message {
    message: String,
}

/// A simple Spin HTTP component.
#[http_component]
fn handle_spin_func_rust(req: Request) -> anyhow::Result<impl IntoResponse> {
    println!("Handling request to {:?}", req.header("spin-full-url"));
    let message = Message {
        message: "Hello, world!".to_string(),
    };
    Ok(Response::builder()
      .status(200)
      .header("content-type", "application/json")
      .header("server", "spin")
      .body(serde_json::to_vec(&message).unwrap())
      .build()
    )
}

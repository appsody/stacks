#![feature(proc_macro_hygiene, decl_macro)]

use rust_rocket;

#[macro_use] extern crate rocket;

#[get("/")]
fn world() -> &'static str {
    "Hello from Appsody!"
}

fn rocket() -> rocket::Rocket {
    rust_rocket::initialize_metrics().mount("/", routes![world])
}

fn main() {
    rocket().launch();
}

#[cfg(test)]
mod tests;


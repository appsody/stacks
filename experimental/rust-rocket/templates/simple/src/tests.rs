use super::rocket;
use rocket::local::Client;
use rocket::http::Status;

#[test]
fn hello_world() {
    let client = Client::new(rocket()).unwrap();
    let mut response = client.get("/").dispatch();
    assert_eq!(response.status(), Status::Ok);
    assert_eq!(response.body_string(), Some("Hello from Appsody!".into()));
}

#[test]
fn metrics() {
    let client = Client::new(rocket()).unwrap();
    let response = client.get("/metrics").dispatch();
    assert_eq!(response.status(), Status::Ok)
}

#[test]
fn random() {
    let client = Client::new(rocket()).unwrap();
    let response = client.get("/random").dispatch();
    assert_eq!(response.status(), Status::NotFound);
}
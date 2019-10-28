use rocket::local::Client;
use rocket::http::Status;
use crate::initialize_metrics;

#[test]
fn metrics() {
    let client = Client::new(initialize_metrics()).unwrap();
    let response = client.get("/metrics").dispatch();
    assert_eq!(response.status(), Status::Ok)
}

#[test]
fn random() {
    let client = Client::new(initialize_metrics()).unwrap();
    let response = client.get("/random").dispatch();
    assert_eq!(response.status(), Status::NotFound);
}
pub fn app() -> tide::server::Server<()> {    
    let mut api = tide::new();
    api.at("/hello").get(|_| async move { "Hello, world" });
    api
}
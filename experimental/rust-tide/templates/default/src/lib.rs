pub fn app() -> tide::Server<()> {    
    let mut api = tide::new();
    api.at("/hello").get(|_| async move { Ok("Hello, world!") });
    api
}
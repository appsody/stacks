pub fn app() -> tide::Server<()> {    
    let mut api = tide::new();
    api.at("/").get(|_| async move { Ok("Hello, world!") });
    api
}
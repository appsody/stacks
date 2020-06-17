use std::env;
use async_std::task;
use application;

fn main() -> Result<(), std::io::Error> {
    
    let port = env::var("PORT").unwrap_or_else(|_| "8000".to_string());
    let address = format!("0.0.0.0:{}", port);
    task::block_on(async {
        tide::log::start();
        let mut app = tide::new();
        app.at("/").nest({
            application::app()
        });
        println!("      Running server on: http://localhost:{}/", port);
        app.listen(address).await?;
        Ok(())
    })
}
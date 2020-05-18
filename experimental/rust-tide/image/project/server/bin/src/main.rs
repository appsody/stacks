use async_std::task;
use application;
fn main() -> Result<(), std::io::Error> {
    task::block_on(async {
        let mut app = tide::new();
        app.at("/").nest({
            application::app()
        });
        println!("      Running server on: http://localhost:8000/");
        app.listen("0.0.0.0:8000").await?;
        Ok(())
    })
}
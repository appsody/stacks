use async_std::task;

#[test]
fn hello_world() -> Result<(), http_types::Error> {
    task::block_on(async {
        let string = surf::get(format!("http://127.0.0.1:{}", 8000))
        .recv_string()
        .await
        .unwrap();
        assert_eq!(string, "Hello, world!".to_string());
        Ok(())
    })
}
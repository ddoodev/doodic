use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn say_hello(i: bool) -> i32 {
    if i {
      panic!("kekw");
    }
    2 + 2
}

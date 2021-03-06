#![feature(alloc)]
#![no_std]

extern crate alloc;
extern crate tock;

use alloc::fmt::Write;

#[inline(never)]
fn main() {
    let mut console = tock::console::Console::new();
    write!(&mut console, "Tock App\n").unwrap();
}


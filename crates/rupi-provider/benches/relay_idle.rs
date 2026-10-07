//! Windows regression budget for idle provider relay CPU, exact forwarding and bounded stop.
//! Uses an owned delayed loopback server, never a configured model endpoint.
//! cargo bench --profile dev -p rupi-provider --bench relay_idle -- --json <path>
// The private relay is compiled unchanged, so this benchmark exercises the production source.
#[cfg(windows)]
// Cargo sets cfg(test) for benches while omitting the included module's test harness.
#[allow(unused_imports)]
#[path = "../src/relay.rs"]
mod relay;
#[cfg(windows)]
mod windows {
  use super::relay;
  use std::{
    io::{Read, Write},
    net::{TcpListener, TcpStream},
    thread,
    time::{Duration, Instant},
  };

  #[repr(C)]
  #[derive(Default)]
  struct FileTime {
    low: u32,
    high: u32,
  }
  #[link(name = "kernel32")]
  unsafe extern "system" {
    fn GetCurrentProcess() -> *mut std::ffi::c_void;
    fn GetProcessTimes(
      handle: *mut std::ffi::c_void,
      created: *mut FileTime,
      exited: *mut FileTime,
      kernel: *mut FileTime,
      user: *mut FileTime,
    ) -> i32;
  }
  fn cpu_ms() -> f64 {
    let (mut created, mut exited, mut kernel, mut user) = (
      FileTime::default(),
      FileTime::default(),
      FileTime::default(),
      FileTime::default(),
    );
    // FILETIME storage and the current-process pseudo-handle remain valid for this call.
    let ok = unsafe {
      GetProcessTimes(
        GetCurrentProcess(),
        &mut created,
        &mut exited,
        &mut kernel,
        &mut user,
      )
    };
    assert_ne!(ok, 0);
    let ticks = |time: FileTime| (u64::from(time.high) << 32) | u64::from(time.low);
    (ticks(kernel) + ticks(user)) as f64 / 10_000.0
  }
  fn sample() -> serde_json::Value {
    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    let address = listener.local_addr().unwrap();
    assert!(!(8000..=8004).contains(&address.port()));
    let target = thread::spawn(move || {
      let (mut stream, _) = listener.accept().unwrap();
      stream
        .set_read_timeout(Some(Duration::from_secs(2)))
        .unwrap();
      let mut request = Vec::new();
      let mut byte = [0u8; 1];
      while !request.ends_with(b"\r\n\r\n") {
        stream.read_exact(&mut byte).unwrap();
        request.push(byte[0]);
        assert!(request.len() < 4096);
      }
      assert!(request.starts_with(b"POST /owned HTTP/1.1\r\n"));
      let mut body = [0u8; 5];
      stream.read_exact(&mut body).unwrap();
      assert_eq!(&body, b"owned");
      thread::sleep(Duration::from_secs(3));
      stream
        .write_all(b"HTTP/1.1 200 OK\r\nContent-Length: 5\r\nConnection: close\r\n\r\nowned")
        .unwrap();
      1
    });
    let before = cpu_ms();
    let started = Instant::now();
    let mut relay = relay::CancellableHttpRelay::start(
      &format!("http://{address}/owned"),
      Duration::from_secs(1),
    )
    .unwrap();
    let proxy = relay.proxy_url();
    let mut client = TcpStream::connect(proxy.strip_prefix("http://").unwrap()).unwrap();
    client
      .set_read_timeout(Some(Duration::from_secs(5)))
      .unwrap();
    write!(
      client,
      concat!(
        "POST http://{}/owned HTTP/1.1\r\nHost: {}\r\n",
        "Content-Length: 5\r\nX-Rupi-Relay-Nonce: {}\r\n\r\nowned"
      ),
      address,
      address,
      relay.nonce()
    )
    .unwrap();
    let mut response = Vec::new();
    client.read_to_end(&mut response).unwrap();
    assert_eq!(
      response,
      b"HTTP/1.1 200 OK\r\nContent-Length: 5\r\nConnection: close\r\n\r\nowned"
    );
    drop(client);
    let stop_started = Instant::now();
    relay.stop();
    let stop_ms = stop_started.elapsed().as_secs_f64() * 1000.0;
    let posts = target.join().unwrap();
    let cpu = cpu_ms() - before;
    serde_json::json!({"cpu_ms": cpu, "wall_ms": started.elapsed().as_secs_f64() * 1000.0,
    "stop_ms": stop_ms, "posts": posts, "exact_response": true, "eof": true})
  }
  pub fn run() -> std::process::ExitCode {
    let args: Vec<String> = std::env::args().collect();
    let value = |name: &str| {
      args
        .iter()
        .position(|arg| arg == name)
        .and_then(|index| args.get(index + 1))
    };
    if args.iter().any(|arg| arg == "--help") {
      println!("Usage: relay_idle [--iterations <N>] [--json <path>]");
      return std::process::ExitCode::SUCCESS;
    }
    let iterations = value("--iterations").map_or(3, |text| text.parse::<usize>().unwrap());
    assert!((1..=10).contains(&iterations));
    let samples: Vec<_> = (0..iterations).map(|_| sample()).collect();
    let passed = samples.iter().all(|sample| {
      sample["cpu_ms"].as_f64().unwrap() < 250.0 && sample["stop_ms"].as_f64().unwrap() < 500.0
    });
    for sample in &samples {
      println!(
        "owned relay: cpu={}ms wall={}ms stop={}ms posts=1 exact_response=true eof=true",
        sample["cpu_ms"], sample["wall_ms"], sample["stop_ms"]
      );
    }
    println!("Windows idle relay budgets: CPU250ms, stop500ms; passed={passed}");
    if let Some(path) = value("--json") {
      std::fs::write(
        path,
        serde_json::to_string_pretty(&serde_json::json!({
          "platform": "windows", "iterations": iterations, "cpu_budget_ms": 250.0,
          "upstream_wait_ms": 3000, "stop_budget_ms": 500, "samples": samples, "passed": passed
        }))
        .unwrap(),
      )
      .unwrap();
    }
    if passed {
      std::process::ExitCode::SUCCESS
    } else {
      std::process::ExitCode::FAILURE
    }
  }
}
#[cfg(windows)]
fn main() -> std::process::ExitCode {
  windows::run()
}
#[cfg(not(windows))]
fn main() {
  println!("The accepted-socket idle CPU budget applies on Windows.");
}

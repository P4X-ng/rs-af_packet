//! # AF_PACKET bindings for Rust
//!
//! This library provides high-performance AF_PACKET bindings for Rust, designed for
//! network security and monitoring applications. It enables zero-copy packet capture
//! on Linux using the PACKET_MMAP API.
//!
//! ## Features
//!
//! - Zero-copy packet capture using memory-mapped ring buffers
//! - Multi-threaded packet processing with kernel-side flow distribution
//! - Support for PACKET_FANOUT modes for efficient load balancing
//! - Access to packet metadata including timestamps, VLAN tags, and RX hash
//!
//! ## Example
//!
//! ```no_run
//! use af_packet::rx::Ring;
//!
//! // Create a ring buffer on eth0
//! let mut ring = Ring::from_if_name("eth0").unwrap();
//!
//! // Process packets
//! loop {
//!     let mut block = ring.get_block();
//!     for packet in block.get_raw_packets() {
//!         // Process packet.data
//!         println!("Received {} bytes", packet.data.len());
//!     }
//!     block.mark_as_consumed();
//! }
//! ```
//!
//! ## Safety
//!
//! This library uses unsafe code to interface with Linux kernel APIs. Care has been
//! taken to ensure memory safety, but users should be aware that packet capture
//! requires elevated privileges (CAP_NET_RAW capability).

extern crate libc;
extern crate nom;

pub mod rx;
pub mod socket;
pub mod tpacket3;
pub mod tx;

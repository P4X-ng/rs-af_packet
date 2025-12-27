//! Socket management and configuration for AF_PACKET
//!
//! This module provides low-level socket operations for creating and configuring
//! AF_PACKET sockets. It handles interface configuration, socket options, and
//! ioctl operations.

extern crate libc;

use libc::{
    c_char, c_int, c_short, c_uint, c_ulong, c_void, getsockopt, if_nametoindex, ioctl, setsockopt,
    socket, socklen_t, ETH_P_ALL, IF_NAMESIZE, SOCK_RAW, SOL_PACKET,
};
pub use libc::{AF_PACKET, IFF_PROMISC, PF_PACKET};

use std::ffi::CString;
use std::io::{self, Error};
use std::mem;

const IFREQUNIONSIZE: usize = 24;

const SIOCGIFFLAGS: c_ulong = 35091; //0x00008913;
const SIOCSIFFLAGS: c_ulong = 35092; //0x00008914;

pub const PACKET_FANOUT: c_int = 18;

#[repr(C)]
struct IfReq {
    //TODO: these are actually both unions, implement them as such now that Rust supports it
    ifr_name: [c_char; IF_NAMESIZE],
    data: [u8; IFREQUNIONSIZE],
}

impl IfReq {
    fn as_short(&self) -> c_short {
        c_short::from_be((self.data[0] as c_short) << 8 | (self.data[1] as c_short))
    }

    fn from_short(i: c_short) -> IfReq {
        let mut req = IfReq::default();
        let bytes: [u8; 2] = i.to_ne_bytes();
        req.data[0] = bytes[0];
        req.data[1] = bytes[1];
        req
    }

    fn with_if_name(if_name: &str) -> io::Result<IfReq> {
        let mut if_req = IfReq::default();

        if if_name.len() >= if_req.ifr_name.len() {
            return Err(io::Error::other("Interface name too long"));
        }

        // basically a memcpy
        for (a, c) in if_req.ifr_name.iter_mut().zip(if_name.bytes()) {
            *a = c as i8;
        }

        Ok(if_req)
    }

    fn ifr_flags(&self) -> c_short {
        self.as_short()
    }
}

impl Default for IfReq {
    fn default() -> IfReq {
        IfReq {
            ifr_name: [0; IF_NAMESIZE],
            data: [0; IFREQUNIONSIZE],
        }
    }
}

#[derive(Clone, Debug)]
pub struct Socket {
    ///File descriptor
    pub fd: c_int,
    ///Interface name
    pub if_name: String,
    pub if_index: c_uint,
    pub sock_type: c_int,
}

impl Socket {
    pub fn from_if_name(if_name: &str, socket_type: c_int) -> io::Result<Socket> {
        //this typecasting sucks :(
        let fd = unsafe { socket(socket_type, SOCK_RAW, (ETH_P_ALL as u16).to_be() as i32) };
        if fd < 0 {
            return Err(Error::last_os_error());
        }

        Ok(Socket {
            if_name: String::from(if_name),
            if_index: get_if_index(if_name)?,
            sock_type: socket_type,
            fd,
        })
    }

    fn ioctl(&self, ident: c_ulong, if_req: IfReq) -> io::Result<IfReq> {
        let mut req: Box<IfReq> = Box::new(if_req);
        match unsafe { ioctl(self.fd, ident, &mut *req) } {
            -1 => Err(Error::last_os_error()),
            _ => Ok(*req),
        }
    }

    fn get_flags(&self) -> io::Result<IfReq> {
        self.ioctl(SIOCGIFFLAGS, IfReq::with_if_name(&self.if_name)?)
    }

    pub fn set_flag(&mut self, flag: c_ulong) -> io::Result<()> {
        let flags = &self.get_flags()?.ifr_flags();
        let new_flags = flags | flag as c_short;
        let mut if_req = IfReq::with_if_name(&self.if_name)?;
        if_req.data = IfReq::from_short(new_flags).data;
        self.ioctl(SIOCSIFFLAGS, if_req)?;
        Ok(())
    }

    pub fn setsockopt<T>(&mut self, opt: c_int, opt_val: T) -> io::Result<()> {
        match unsafe {
            setsockopt(
                self.fd,
                SOL_PACKET,
                opt,
                &opt_val as *const _ as *const c_void,
                mem::size_of_val(&opt_val) as socklen_t,
            )
        } {
            0 => Ok(()),
            _ => Err(io::Error::last_os_error()),
        }
    }

    pub fn getsockopt(&mut self, opt: c_int, opt_val: &*mut c_void) -> io::Result<()> {
        get_sock_opt(self.fd, opt, opt_val)
    }
}

pub fn get_sock_opt(fd: i32, opt: c_int, opt_val: &*mut c_void) -> io::Result<()> {
    let mut optlen = mem::size_of_val(opt_val) as socklen_t;
    match unsafe { getsockopt(fd, SOL_PACKET, opt, *opt_val, &mut optlen) } {
        0 => Ok(()),
        _ => Err(io::Error::last_os_error()),
    }
}

pub fn get_if_index(name: &str) -> io::Result<c_uint> {
    let name = CString::new(name)?;
    let index = unsafe { if_nametoindex(name.as_ptr()) };
    Ok(index)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ifreq_default() {
        let ifreq = IfReq::default();
        assert_eq!(ifreq.ifr_name.len(), IF_NAMESIZE);
        assert_eq!(ifreq.data.len(), IFREQUNIONSIZE);
    }

    #[test]
    fn test_ifreq_with_if_name() {
        let result = IfReq::with_if_name("eth0");
        assert!(result.is_ok());
        let ifreq = result.unwrap();
        assert_eq!(ifreq.ifr_name[0], b'e' as i8);
        assert_eq!(ifreq.ifr_name[1], b't' as i8);
        assert_eq!(ifreq.ifr_name[2], b'h' as i8);
        assert_eq!(ifreq.ifr_name[3], b'0' as i8);
    }

    #[test]
    fn test_ifreq_with_long_if_name() {
        let long_name = "a".repeat(IF_NAMESIZE);
        let result = IfReq::with_if_name(&long_name);
        assert!(result.is_err());
    }

    #[test]
    fn test_ifreq_from_short() {
        let value: c_short = 0x1234;
        let ifreq = IfReq::from_short(value);
        // Check that the bytes are stored correctly
        assert!(ifreq.data[0] != 0 || ifreq.data[1] != 0);
    }

    #[test]
    fn test_get_if_index_invalid() {
        // Test with an invalid interface name
        let result = get_if_index("invalid_interface_name_12345");
        // This should return Ok(0) for non-existent interfaces
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), 0);
    }

    #[test]
    fn test_get_if_index_with_null_byte() {
        // CString::new should fail if the name contains null bytes
        let result = get_if_index("eth\0bad");
        assert!(result.is_err());
    }
}

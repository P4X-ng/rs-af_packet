# Security Considerations

## Unsafe Code Review

This library uses unsafe code to interface with Linux kernel APIs. All unsafe blocks have been reviewed for memory safety.

### Unsafe Code Locations and Justification

#### src/rx.rs

1. **`getpid()` calls (lines 67, 164)**: Safe - Simple FFI call to get process ID for fanout group ID generation
2. **`mmap()` call (line 209)**: Reviewed - Creates memory-mapped region for ring buffer. Pointer validity checked before use.
3. **`mem::transmute` for sockaddr (line 247)**: Reviewed - Required for socket API compatibility. Transmutes between sockaddr_ll and sockaddr, which is the standard pattern for BSD socket APIs.
4. **`bind()` call (line 249)**: Safe - Standard socket binding operation with properly initialized sockaddr structure.
5. **`poll()` call (line 263)**: Safe - Standard I/O polling operation.
6. **`std::slice::from_raw_parts_mut()` (line 273)**: Critical - Creates mutable slice from mmap'd memory. Safety relies on:
   - Valid pointer from successful mmap
   - Correct size calculation
   - No aliasing (enforced by Ring's &mut self methods)
7. **`unsafe impl Send for Ring` (line 297)**: Reviewed - Safe because Ring owns its resources and file descriptors are thread-safe in Linux.

#### src/socket.rs

1. **`socket()` call (line 88)**: Safe - Standard socket creation. Error handling in place.
2. **`ioctl()` call (line 103)**: Safe - Standard ioctl operation with properly boxed IfReq structure.
3. **`setsockopt()` call (line 123)**: Safe - Standard socket option setting with correct size calculation.
4. **`getsockopt()` call (line 144)**: Safe - Standard socket option retrieval with proper pointer handling.
5. **`if_nametoindex()` call (line 152)**: Safe - Standard interface name lookup with CString validation.

#### src/tx.rs

1. **`mem::transmute` for sockaddr (line 37)**: Same as rx.rs - standard pattern for socket APIs.
2. **`sendto()` call (line 39)**: Reviewed - Standard packet transmission. Note: size calculation uses `mem::size_of_val(frame)` which correctly gets slice length.

## Required Privileges

This library requires the following Linux capabilities:
- `CAP_NET_RAW` - Required for raw packet capture
- `CAP_NET_ADMIN` - May be required for setting promiscuous mode

## Known Limitations

1. **No bounds checking on packet data**: Users must validate packet lengths before parsing.
2. **File descriptor leaks**: Ring buffers should be properly dropped to avoid FD leaks.
3. **Memory mapping**: Failed mmap operations are properly handled, but long-running applications should monitor memory usage.

## Recommendations for SDK Integration

1. **Input Validation**: Always validate interface names and configuration parameters before creating Ring instances.
2. **Error Handling**: Check all Result types, especially when creating Ring instances.
3. **Resource Cleanup**: Ensure Ring instances are properly dropped or use RAII patterns.
4. **Testing**: Test with various network conditions and interface states.
5. **Monitoring**: Monitor for packet drops using `get_rx_statistics()`.

## Reporting Security Issues

Security issues should be reported to the repository maintainers at: https://github.com/P4X-ng/rs-af_packet/security/advisories

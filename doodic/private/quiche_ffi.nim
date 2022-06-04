import std/nativesockets

when defined(windows):
  import winlean
  const libName = "quiche.dll"

  type Timespec*{.final, pure.} = object
    tv_sec: int
    tv_nsec: int
elif defined(macosx):
  import posix
  const libName = "quiche.dylib"
else:
  import posix
  const libName = "quiche.so"

const
  qProtocolVersion* = 0x00000001
  qMaxConnIdLen* = 20
  qMinClientInitialLen* = 1200

type
  QError* = enum
    qErrStreamReset = -16,
    qErrStreamStopped = -15,
    qErrCongestionControl = -14, qErrFinalSize = -13,
    qErrStreamLimit = -12,
    qErrFlowControl = -11,
    qErrTLSFail = -10,
    qErrCryptoFail = -9,
    qErrInvalidTransportParam = -8,
    qErrInvalidStreamState = -7,
    qErrInvalidState = -6,
    qErrInvalidPacket = -5,
    qErrInvalidFrame = -4,
    qErrUnknownVersion = -3,
    qErrBufferTooShort = -2,
    qErrDone = -1

  QShutdown* {.size: sizeof(cint).} = enum
    qShutdownRead = 0, qShutdownWrite = 1

  QConfig* = object
  QConfigPtr* = ptr QConfig

  QConnection* = object
  QConnectionPtr* = ptr QConnection

  QStreamIter* = object
  QStreamIterPtr* = ptr QStreamIter

  QCCAlgorithm* {.size: sizeof(cint).} = enum
    qccReno = 0, qccCubic

  QRecvInfo* {.bycopy.} = object
    `from`*: ptr SockAddr
    from_len*: SockLen

  QSendInfo* {.bycopy.} = object
    to*: Sockaddr_storage
    to_len*: SockLen
    at*: Timespec

  QStats* {.bycopy.} = object
    recv*: csize_t
    sent*: csize_t
    lost*: csize_t
    retrans*: csize_t
    rtt*: uint64
    cwnd*: csize_t
    sent_bytes*: uint64
    recv_bytes*: uint64
    lost_bytes*: uint64
    stream_retrans_bytes*: uint64
    pmtu*: csize_t
    delivery_rate*: uint64
    peer_max_idle_timeout*: uint64
    peer_max_udp_payload_size*: uint64
    peer_initial_max_data*: uint64
    peer_initial_max_stream_data_bidi_local * : uint64
    peer_initial_max_stream_data_bidi_remote * : uint64
    peer_initial_max_stream_data_uni*: uint64
    peer_initial_max_streams_bidi*: uint64
    peer_initial_max_streams_uni*: uint64
    peer_ack_delay_exponent*: uint64
    peer_max_ack_delay*: uint64
    peer_disable_active_migration*: bool
    peer_active_conn_id_limit*: uint64
    peer_max_datagram_frame_size*: csize_t

proc quiche_version*(): cstring {.cdecl, importc: "quiche_version",
    dynlib: libName.}

proc quiche_enable_debug_logging*(cb: proc (line: cstring; argp: pointer) {.cdecl.};
                                 argp: pointer): cint {.cdecl,
    importc: "quiche_enable_debug_logging", dynlib: libName.}

proc quiche_config_new*(version: uint32): QConfigPtr {.cdecl,
    importc: "quiche_config_new", dynlib: libName.}

proc quiche_config_load_cert_chain_from_pem_file*(config: QConfigPtr;
    path: cstring): cint {.cdecl,
                        importc: "quiche_config_load_cert_chain_from_pem_file",
                        dynlib: libName.}

proc quiche_config_load_priv_key_from_pem_file*(config: QConfigPtr;
    path: cstring): cint {.cdecl,
                        importc: "quiche_config_load_priv_key_from_pem_file",
                        dynlib: libName.}

proc quiche_config_load_verify_locations_from_file*(config: QConfigPtr;
    path: cstring): cint {.cdecl, importc: "quiche_config_load_verify_locations_from_file",
                        dynlib: libName.}

proc quiche_config_load_verify_locations_from_directory*(
    config: QConfigPtr; path: cstring): cint {.cdecl,
    importc: "quiche_config_load_verify_locations_from_directory",
        dynlib: libName.}

proc quiche_config_verify_peer*(config: QConfigPtr; v: bool) {.cdecl,
    importc: "quiche_config_verify_peer", dynlib: libName.}

proc quiche_config_grease*(config: QConfigPtr; v: bool) {.cdecl,
    importc: "quiche_config_grease", dynlib: libName.}

proc quiche_config_log_keys*(config: QConfigPtr) {.cdecl,
    importc: "quiche_config_log_keys", dynlib: libName.}

proc quiche_config_enable_early_data*(config: QConfigPtr) {.cdecl,
    importc: "quiche_config_enable_early_data", dynlib: libName.}

proc quiche_config_set_application_protos*(config: QConfigPtr;
    protos: cstring; protos_len: csize_t): cint {.cdecl,
    importc: "quiche_config_set_application_protos", dynlib: libName.}

proc quiche_config_set_max_idle_timeout*(config: QConfigPtr; v: uint64) {.
    cdecl, importc: "quiche_config_set_max_idle_timeout", dynlib: libName.}

proc quiche_config_set_max_recv_udp_payload_size*(config: QConfigPtr;
    v: csize_t) {.cdecl, importc: "quiche_config_set_max_recv_udp_payload_size",
                dynlib: libName.}

proc quiche_config_set_max_send_udp_payload_size*(config: QConfigPtr;
    v: csize_t) {.cdecl, importc: "quiche_config_set_max_send_udp_payload_size",
                dynlib: libName.}

proc quiche_config_set_initial_max_data*(config: QConfigPtr; v: uint64) {.
    cdecl, importc: "quiche_config_set_initial_max_data", dynlib: libName.}

proc quiche_config_set_initial_max_stream_data_bidi_local*(
    config: QConfigPtr; v: uint64) {.cdecl,
    importc: "quiche_config_set_initial_max_stream_data_bidi_local",
    dynlib: libName.}

proc quiche_config_set_initial_max_stream_data_bidi_remote*(
    config: QConfigPtr; v: uint64) {.cdecl,
    importc: "quiche_config_set_initial_max_stream_data_bidi_remote",
    dynlib: libName.}

proc quiche_config_set_initial_max_stream_data_uni*(config: QConfigPtr;
    v: uint64) {.cdecl, importc: "quiche_config_set_initial_max_stream_data_uni",
                 dynlib: libName.}

proc quiche_config_set_initial_max_streams_bidi*(config: QConfigPtr;
    v: uint64) {.cdecl, importc: "quiche_config_set_initial_max_streams_bidi",
                 dynlib: libName.}

proc quiche_config_set_initial_max_streams_uni*(config: QConfigPtr;
    v: uint64) {.cdecl, importc: "quiche_config_set_initial_max_streams_uni",
                 dynlib: libName.}

proc quiche_config_set_ack_delay_exponent*(config: QConfigPtr; v: uint64) {.
    cdecl, importc: "quiche_config_set_ack_delay_exponent", dynlib: libName.}

proc quiche_config_set_max_ack_delay*(config: QConfigPtr; v: uint64) {.cdecl,
    importc: "quiche_config_set_max_ack_delay", dynlib: libName.}

proc quiche_config_set_disable_active_migration*(config: QConfigPtr; v: bool) {.
    cdecl, importc: "quiche_config_set_disable_active_migration",
        dynlib: libName.}

proc quiche_config_set_cc_algorithm*(config: QConfigPtr;
                                    algo: QCCAlgorithm) {.cdecl,
    importc: "quiche_config_set_cc_algorithm", dynlib: libName.}

proc quiche_config_enable_hystart*(config: QConfigPtr; v: bool) {.cdecl,
    importc: "quiche_config_enable_hystart", dynlib: libName.}

proc quiche_config_enable_dgram*(config: QConfigPtr; enabled: bool;
                                recv_queue_len: csize_t;
                                    send_queue_len: csize_t) {.
    cdecl, importc: "quiche_config_enable_dgram", dynlib: libName.}

proc quiche_config_set_max_connection_window*(config: QConfigPtr; v: uint64) {.
    cdecl, importc: "quiche_config_set_max_connection_window", dynlib: libName.}

proc quiche_config_set_max_stream_window*(config: QConfigPtr; v: uint64) {.
    cdecl, importc: "quiche_config_set_max_stream_window", dynlib: libName.}

proc quiche_config_free*(config: QConfigPtr) {.cdecl,
    importc: "quiche_config_free", dynlib: libName.}

proc quiche_header_info*(buf: cstring; buf_len: csize_t; dcil: csize_t;
                        version: ptr uint32; `type`: ptr uint8; scid: ptr UncheckedArray[uint8];
                        scid_len: ptr csize_t; dcid: ptr UncheckedArray[uint8];
                        dcid_len: ptr csize_t; token: ptr UncheckedArray[uint8];
                        token_len: ptr csize_t): cint {.cdecl,
    importc: "quiche_header_info", dynlib: libName.}

proc quiche_accept*(scid: cstring; scid_len: csize_t; odcid: cstring;
                   odcid_len: csize_t; `from`: ptr SockAddr; from_len: SockLen;
                   config: QConfigPtr): QConnectionPtr {.cdecl,
    importc: "quiche_accept", dynlib: libName.}

proc quiche_connect*(server_name: cstring; scid: cstring; scid_len: csize_t;
                    to: ptr SockAddr; to_len: SockLen;
                        config: QConfigPtr): QConnectionPtr {.
    cdecl, importc: "quiche_connect", dynlib: libName.}

proc quiche_negotiate_version*(scid: cstring; scid_len: csize_t;
                              dcid: cstring; dcid_len: csize_t;
                              `out`: cstring;
                                  out_len: csize_t): csize_t {.cdecl,
    importc: "quiche_negotiate_version", dynlib: libName.}

proc quiche_retry*(scid: cstring; scid_len: csize_t; dcid: cstring;
                  dcid_len: csize_t; new_scid: cstring; new_scid_len: csize_t;
                  token: cstring; token_len: csize_t; version: uint32;
                  `out`: cstring; out_len: csize_t): csize_t {.cdecl,
    importc: "quiche_retry", dynlib: libName.}

proc quiche_version_is_supported*(version: uint32): bool {.cdecl,
    importc: "quiche_version_is_supported", dynlib: libName.}
proc quiche_conn_new_with_tls*(scid: cstring; scid_len: csize_t;
                              odcid: cstring; odcid_len: csize_t;
                              peer: ptr SockAddr; peer_len: SockLen;
                              config: QConfigPtr; ssl: pointer;
                              is_server: bool): QConnectionPtr {.cdecl,
    importc: "quiche_conn_new_with_tls", dynlib: libName.}

proc quiche_conn_set_keylog_path*(conn: QConnectionPtr;
    path: cstring): bool {.cdecl, importc: "quiche_conn_set_keylog_path",
        dynlib: libName.}

proc quiche_conn_set_keylog_fd*(conn: QConnectionPtr; fd: cint) {.cdecl,
    importc: "quiche_conn_set_keylog_fd", dynlib: libName.}

proc quiche_conn_set_qlog_path*(conn: QConnectionPtr; path: cstring;
                               log_title: cstring;
                                   log_desc: cstring): bool {.cdecl,
    importc: "quiche_conn_set_qlog_path", dynlib: libName.}

proc quiche_conn_set_qlog_fd*(conn: QConnectionPtr; fd: cint; log_title: cstring;
                             log_desc: cstring) {.cdecl,
    importc: "quiche_conn_set_qlog_fd", dynlib: libName.}

proc quiche_conn_set_session*(conn: QConnectionPtr; buf: cstring;
    buf_len: csize_t): cint {.
    cdecl, importc: "quiche_conn_set_session", dynlib: libName.}

proc quiche_conn_recv*(conn: QConnectionPtr; buf: cstring; buf_len: csize_t;
                      info: ptr QRecvInfo): csize_t {.cdecl,
    importc: "quiche_conn_recv", dynlib: libName.}

proc quiche_conn_send*(conn: QConnectionPtr; `out`: cstring; out_len: csize_t;
                      out_info: ptr QSendInfo): csize_t {.cdecl,
    importc: "quiche_conn_send", dynlib: libName.}

proc quiche_conn_send_quantum*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_send_quantum", dynlib: libName.}

proc quiche_conn_stream_recv*(conn: QConnectionPtr; stream_id: uint64;
                             `out`: cstring; buf_len: csize_t;
                                 fin: ptr bool): csize_t {.
    cdecl, importc: "quiche_conn_stream_recv", dynlib: libName.}

proc quiche_conn_stream_send*(conn: QConnectionPtr; stream_id: uint64;
                             buf: cstring; buf_len: csize_t;
                                 fin: bool): csize_t {.
    cdecl, importc: "quiche_conn_stream_send", dynlib: libName.}

proc quiche_conn_stream_priority*(conn: QConnectionPtr; stream_id: uint64;
                                 urgency: uint8;
                                     incremental: bool): cint {.cdecl,
    importc: "quiche_conn_stream_priority", dynlib: libName.}

proc quiche_conn_stream_shutdown*(conn: QConnectionPtr; stream_id: uint64;
                                 direction: QShutdown; err: uint64): cint {.
    cdecl, importc: "quiche_conn_stream_shutdown", dynlib: libName.}
proc quiche_conn_stream_capacity*(conn: QConnectionPtr;
    stream_id: uint64): csize_t {.
    cdecl, importc: "quiche_conn_stream_capacity", dynlib: libName.}
proc quiche_conn_stream_readable*(conn: QConnectionPtr;
    stream_id: uint64): bool {.
    cdecl, importc: "quiche_conn_stream_readable", dynlib: libName.}

proc quiche_conn_stream_finished*(conn: QConnectionPtr;
    stream_id: uint64): bool {.
    cdecl, importc: "quiche_conn_stream_finished", dynlib: libName.}

proc quiche_conn_readable*(conn: QConnectionPtr): QStreamIterPtr {.cdecl,
    importc: "quiche_conn_readable", dynlib: libName.}

proc quiche_conn_writable*(conn: QConnectionPtr): QStreamIterPtr {.cdecl,
    importc: "quiche_conn_writable", dynlib: libName.}

proc quiche_conn_max_send_udp_payload_size*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_max_send_udp_payload_size", dynlib: libName.}

proc quiche_conn_timeout_as_nanos*(conn: QConnectionPtr): uint64 {.cdecl,
    importc: "quiche_conn_timeout_as_nanos", dynlib: libName.}

proc quiche_conn_timeout_as_millis*(conn: QConnectionPtr): uint64 {.cdecl,
    importc: "quiche_conn_timeout_as_millis", dynlib: libName.}

proc quiche_conn_on_timeout*(conn: QConnectionPtr) {.cdecl,
    importc: "quiche_conn_on_timeout", dynlib: libName.}

proc quiche_conn_close*(conn: QConnectionPtr; app: bool; err: uint64;
                       reason: cstring; reason_len: csize_t): cint {.cdecl,
    importc: "quiche_conn_close", dynlib: libName.}

proc quiche_conn_trace_id*(conn: QConnectionPtr; `out`: ptr cstring;
                          out_len: ptr csize_t) {.cdecl,
    importc: "quiche_conn_trace_id", dynlib: libName.}

proc quiche_conn_source_id*(conn: QConnectionPtr; `out`: ptr cstring;
                           out_len: ptr csize_t) {.cdecl,
    importc: "quiche_conn_source_id", dynlib: libName.}

proc quiche_conn_destination_id*(conn: QConnectionPtr; `out`: ptr cstring;
                                out_len: ptr csize_t) {.cdecl,
    importc: "quiche_conn_destination_id", dynlib: libName.}

proc quiche_conn_application_proto*(conn: QConnectionPtr; `out`: ptr cstring;
                                   out_len: ptr csize_t) {.cdecl,
    importc: "quiche_conn_application_proto", dynlib: libName.}

proc quiche_conn_peer_cert*(conn: QConnectionPtr; `out`: ptr cstring;
                           out_len: ptr csize_t) {.cdecl,
    importc: "quiche_conn_peer_cert", dynlib: libName.}

proc quiche_conn_session*(conn: QConnectionPtr; `out`: ptr cstring;
                         out_len: ptr csize_t) {.cdecl,
    importc: "quiche_conn_session", dynlib: libName.}

proc quiche_conn_is_established*(conn: QConnectionPtr): bool {.cdecl,
    importc: "quiche_conn_is_established", dynlib: libName.}

proc quiche_conn_is_in_early_data*(conn: QConnectionPtr): bool {.cdecl,
    importc: "quiche_conn_is_in_early_data", dynlib: libName.}

proc quiche_conn_is_readable*(conn: QConnectionPtr): bool {.cdecl,
    importc: "quiche_conn_is_readable", dynlib: libName.}

proc quiche_conn_is_draining*(conn: QConnectionPtr): bool {.cdecl,
    importc: "quiche_conn_is_draining", dynlib: libName.}

proc quiche_conn_peer_streams_left_bidi*(conn: QConnectionPtr): uint64 {.cdecl,
    importc: "quiche_conn_peer_streams_left_bidi", dynlib: libName.}

proc quiche_conn_peer_streams_left_uni*(conn: QConnectionPtr): uint64 {.cdecl,
    importc: "quiche_conn_peer_streams_left_uni", dynlib: libName.}

proc quiche_conn_is_closed*(conn: QConnectionPtr): bool {.cdecl,
    importc: "quiche_conn_is_closed", dynlib: libName.}

proc quiche_conn_is_timed_out*(conn: QConnectionPtr): bool {.cdecl,
    importc: "quiche_conn_is_timed_out", dynlib: libName.}

proc quiche_conn_peer_error*(conn: QConnectionPtr; is_app: ptr bool;
                            error_code: ptr uint64; reason: ptr cstring;
                            reason_len: ptr csize_t): bool {.cdecl,
    importc: "quiche_conn_peer_error", dynlib: libName.}

proc quiche_conn_local_error*(conn: QConnectionPtr; is_app: ptr bool;
                             error_code: ptr uint64; reason: ptr cstring;
                             reason_len: ptr csize_t): bool {.cdecl,
    importc: "quiche_conn_local_error", dynlib: libName.}

proc quiche_conn_stream_init_application_data*(conn: QConnectionPtr;
    stream_id: uint64; data: pointer): cint {.cdecl,
    importc: "quiche_conn_stream_init_application_data", dynlib: libName.}

proc quiche_conn_stream_application_data*(conn: QConnectionPtr;
    stream_id: uint64): pointer {.
    cdecl, importc: "quiche_conn_stream_application_data", dynlib: libName.}

proc quiche_stream_iter_next*(iter: QStreamIterPtr;
    stream_id: ptr uint64): bool {.
    cdecl, importc: "quiche_stream_iter_next", dynlib: libName.}

proc quiche_stream_iter_free*(iter: QStreamIterPtr) {.cdecl,
    importc: "quiche_stream_iter_free", dynlib: libName.}

proc quiche_conn_stats*(conn: QConnectionPtr; `out`: ptr QStats) {.cdecl,
    importc: "quiche_conn_stats", dynlib: libName.}

proc quiche_conn_dgram_max_writable_len*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_dgram_max_writable_len", dynlib: libName.}

proc quiche_conn_dgram_recv_front_len*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_dgram_recv_front_len", dynlib: libName.}

proc quiche_conn_dgram_recv_queue_len*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_dgram_recv_queue_len", dynlib: libName.}

proc quiche_conn_dgram_recv_queue_byte_size*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_dgram_recv_queue_byte_size", dynlib: libName.}

proc quiche_conn_dgram_send_queue_len*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_dgram_send_queue_len", dynlib: libName.}

proc quiche_conn_dgram_send_queue_byte_size*(conn: QConnectionPtr): csize_t {.cdecl,
    importc: "quiche_conn_dgram_send_queue_byte_size", dynlib: libName.}

proc quiche_conn_dgram_recv*(conn: QConnectionPtr; buf: cstring;
    buf_len: csize_t): csize_t {.
    cdecl, importc: "quiche_conn_dgram_recv", dynlib: libName.}

proc quiche_conn_dgram_send*(conn: QConnectionPtr; buf: cstring;
    buf_len: csize_t): csize_t {.
    cdecl, importc: "quiche_conn_dgram_send", dynlib: libName.}

proc quiche_conn_dgram_purge_outgoing*(conn: QConnectionPtr; f: proc (
    a1: cstring; a2: csize_t): bool {.cdecl.}) {.cdecl,
    importc: "quiche_conn_dgram_purge_outgoing", dynlib: libName.}

proc quiche_conn_free*(conn: QConnectionPtr) {.cdecl,
    importc: "quiche_conn_free", dynlib: libName.}

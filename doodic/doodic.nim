import private/quiche_ffi
import asyncnet, nativesockets, asyncdispatch, options, sequtils

const
  MAX_DATAGRAM_SIZE = 1350
  LOCAL_CONN_ID_LEN = 16
  MAX_TOKEN_LEN* = sizeof(("quiche")) - 1 +
      sizeof(cast[Sockaddr_storage](+qMaxConnIdLen))


type
  Address* = object
    host: string
    port: Port
  DoodicMessage* = object
  DoodicHandleCallback* = proc(msg: DoodicMessage)
  Client* = ref object
    socket: AsyncSocket
    netAddr: string
    connected: bool
    id: int
  DoodicServer* = object
    listening: bool
    quicConfig: QConfigPtr
    address: Address
    socket: AsyncSocket
    handler: Option[DoodicHandleCallback]
    clients: seq[Client]

type
  HeaderType* = enum
    qhInitial,
    qhRetry,
    qhHandshake,
    qhZeroRTT,
    qhVersionNegotiation,
    qhShort
  Header* = object
    version*: uint32
    ty*: HeaderType
    scid*: seq[uint8]
    dcid*: seq[uint8]
    token*: Option[seq[uint8]]

proc getSocket*(server: DoodicServer): AsyncSocket = server.socket

proc newDoodicServer*(port: Port, host: string = ""; idleTimeout: uint64 = 5000): DoodicServer =
  let config = quiche_config_new(qProtocolVersion)
  # discard config.quiche_config_set_application_protos("\x0ahq-interop\x05hq-29\x05hq-28\x05hq-27\x08http/0.9", 38)
  config.quiche_config_set_max_idle_timeout(idleTimeout)
  config.quiche_config_set_max_recv_udp_payload_size(MAX_DATAGRAM_SIZE)
  config.quiche_config_set_max_send_udp_payload_size(MAX_DATAGRAM_SIZE)
  config.quiche_config_set_initial_max_data(10000000)
  config.quiche_config_set_initial_max_stream_data_bidi_local(1000000)
  config.quiche_config_set_initial_max_stream_data_bidi_remote(1000000)
  config.quiche_config_set_initial_max_streams_bidi(100)
  config.quiche_config_set_cc_algorithm(qccReno)
  # config.quiche_config_load_cert_chain_from_pem_file(result.crtPath)
  # config.quiche_config_load_priv_key_from_pem_file(result.keyPath)

  let address = Address(port: port, host: host)
  result = DoodicServer(quicConfig: config, address: address)
  result.listening = false
  result.quicConfig = config
  result.address = address
  result.socket = newAsyncSocket(protocol = IPPROTO_UDP)

  result.socket.bindAddr(result.address.port, result.address.host)

proc newDoodicServer*(port: Port, idleTimeout: uint64 = 5000): DoodicServer =
  newDoodicServer(port, "", idleTimeout)


proc setHandler*(server: var DoodicServer, cb: DoodicHandleCallback) =
  server.handler = some cb

proc parseHeader*(line: string): Header =
  var
    version: uint32
    versionPtr = unsafeAddr version

    tp: uint8
    typePtr = unsafeAddr tp

    scid: array[qMaxConnIdLen, uint8]
    scidPtr = unsafeAddr scid
    scidLen = sizeof(scid)
    scidLenPtr = unsafeAddr scidLen

    dcid: array[qMaxConnIdLen, uint8]
    dcidPtr = unsafeAddr dcid
    dcidLen = sizeof(dcid)
    dcidLenPtr = unsafeAddr dcidLen

    token = array[MAX_TOKEN_LEN, uint8]
    tokenPtr = unsafeAddr token
    tokenLen = sizeof(token)
    tokenLenPtr = unsafeAddr tokenLen

  let rc = quiche_header_info(
    cstring(line), csize_t(line.len),
    csize_t(LOCAL_CONN_ID_LEN),
    versionPtr,
    typePtr,
    scidPtr, scidLenPtr,
    dcidPtr, dcidLenPtr,
    tokenPtr, tokenLenPtr
  )

  if rc < 0: raise newException(ValueError, "Failed to parse header: " & $rc)

  result = Header(
    version: versionPtr[],
    ty: HeaderType(typePtr[]),
    scid: toSeq(scidPtr[]),
    dcid: toSeq(dcidPtr[]),
    token: some toSeq(tokenPtr[])
  )

proc processMessages*(server: DoodicServer, client: Client) {.async.} =
  while true:
    let line = await client.socket.recvLine()
    if line.len == 0: continue

    let header = parseHeader(line)


proc listen*(server: var DoodicServer) {.async.} =
  server.socket.listen()
  server.listening = true
  
  while server.listening:
    let
      (netAddr, clientSocket) = await server.socket.acceptAddr()
      client = Client(
        socket: clientSocket,
        netAddr: netAddr,
        id: server.clients.len,
        connected: true
      )

    server.clients.add(client)
    asyncCheck processMessages(server, client)


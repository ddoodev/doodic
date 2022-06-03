# super pre post alpha, no api wrapping

import ../doodic/private/quiche_ffi

let config = quiche_config_new(qProtocolVersion)
discard config.quiche_config_load_cert_chain_from_pem_file("./cert.crt")
discard config.quiche_config_load_priv_key_from_pem_file("./cert.key")
discard config.quiche_config_set_application_protos("\x0ahq-interop\x05hq-29\x05hq-28\x05hq-27\x08http/0.9", 38)
config.quiche_config_set_max_idle_timeout(5000)
config.quiche_config_set_max_recv_udp_payload_size(1350)
config.quiche_config_set_max_send_udp_payload_size(1350)
config.quiche_config_set_initial_max_data(10000000)
config.quiche_config_set_initial_max_stream_data_bidi_local(1000000)
config.quiche_config_set_initial_max_stream_data_bidi_remote(1000000)
config.quiche_config_set_initial_max_streams_bidi(100)
config.quiche_config_set_cc_algorithm(qccReno)

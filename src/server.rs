use std::net::SocketAddr;
use std::net::UdpSocket;
use anyhow::Result;
use anyhow::anyhow;
use ring::rand::*;

/// QUIC server
pub struct Server<T> where T: Fn(usize) {
    /// Quiche configuration
    quiche_config: quiche::Config,
    /// Address to listen on
    address: String,
    /// Socket server will start on
    socket: Option<UdpSocket>,
    /// Handler for incoming packages
    handler: Option<T>
}

impl<T> Server<T> where T: Fn(usize) {
    /// Creates new server with given address
    pub fn new_with_address(address: String) -> Result<Server<T>> {
        Ok(Self::new(address, quiche::Config::new(quiche::PROTOCOL_VERSION)?))
    }

    /// Creates new server
    pub fn new(address: String, quiche_config: quiche::Config) -> Server<T> {
        Self {
            address,
            quiche_config,
            socket: None,
            handler: None
        }
    }

    /// Sets handler
    pub fn set_handler(&mut self, handler: T) {
        self.handler = Some(handler)
    }

    /// Starts server
    pub fn start(&mut self) -> Result<()> {
        self.socket = Some(UdpSocket::bind(self.address.to_owned())?);
        let addr: SocketAddr = self.address.parse()?;
        let mut scid = [0; quiche::MAX_CONN_ID_LEN];
        SystemRandom::new().fill(&mut scid[..]).unwrap();

        let scid = quiche::ConnectionId::from_ref(&scid[..]);
        let socket = self.socket.as_ref().unwrap();
        let mut conn = quiche::accept(&scid, None, addr, &mut self.quiche_config)?;

        loop {
            let mut buf = [0; 65535];
            let (read, from) = socket.recv_from(&mut buf)?; // worths unwrapping
            let recv_info = quiche::RecvInfo { from };

            let read = match conn.recv(&mut buf[..read], recv_info) {
                Ok(v) => v,
                Err(quiche::Error::Done) => {
                    break Ok(());
                },       
                Err(e) => {
                    break Err(anyhow!("{:?}", e));
                },
            };

            if let Some(i) = &self.handler {
                i(read);
            }
        }
    }
}
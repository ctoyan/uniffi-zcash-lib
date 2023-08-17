use std::io::Write;

use zcash_primitives::{consensus::MainNetwork, legacy::keys::AccountPrivKey};

use super::format_bytes;

#[rustfmt::skip]
pub fn write_for_secp256k1<W: Write>(mut file: W, seed: &[u8]) {
    let apk = AccountPrivKey::from_seed(&MainNetwork, seed, 0.into()).unwrap();
    let secp_secret_key = apk.derive_external_secret_key(0, String::from("kor")).unwrap();
    writeln!(file, "{}", format_bytes("secp_secret_key", secp_secret_key.as_ref())).unwrap();
}

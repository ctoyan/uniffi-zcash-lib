import backend_keys

var seed = Array(repeating: UInt8(0), count: 32)
seed[0] = UInt8(1)

let network = Network.main

let zusk = ZcashUnifiedSpendingKey(
    transparent: ZcashAccountPrivKey(data: [207, 174, 34, 199, 252, 227, 180, 123, 230, 0, 80, 146, 93, 219, 173, 12, 108, 17, 103, 102, 144, 226, 101, 143, 138, 175, 53, 52, 12, 34, 185, 103, 172, 47, 218, 133, 127, 111, 155, 112, 212, 44, 34, 186, 124, 174, 31, 169, 99, 123, 229, 175, 141, 181, 225, 250, 107, 144, 184, 248, 64, 255, 239, 143]),
    sapling: ZcashExtendedSpendingKey(data: [3, 240, 68, 53, 97, 0, 0, 0, 128, 234, 206, 224, 230, 180, 69, 172, 115, 57, 184, 221, 212, 204, 73, 161, 165, 210, 199, 46, 10, 200, 142, 73, 167, 9, 104, 89, 58, 200, 121, 136, 69, 228, 111, 114, 225, 87, 227, 210, 233, 213, 86, 13, 107, 118, 27, 114, 52, 191, 0, 154, 130, 192, 9, 11, 6, 220, 168, 246, 77, 183, 221, 52, 14, 198, 139, 75, 203, 159, 201, 17, 117, 90, 15, 68, 49, 79, 15, 95, 118, 205, 210, 120, 134, 40, 80, 122, 89, 82, 180, 159, 230, 35, 232, 105, 9, 144, 208, 234, 146, 137, 215, 60, 50, 183, 254, 149, 253, 137, 42, 232, 60, 251, 179, 135, 99, 159, 238, 119, 130, 4, 75, 67, 113, 67, 10, 191, 0, 1, 188, 15, 115, 131, 15, 198, 187, 156, 71, 47, 94, 152, 220, 110, 161, 168, 50, 123, 203, 190, 135, 6, 11, 110, 180, 235, 248, 125, 93, 89, 193]),
    orchard: ZcashSpendingKey(data: [166, 3, 186, 151, 20, 139, 99, 33, 212, 134, 101, 192, 119, 208, 167, 21, 119, 228, 7, 152, 74, 140, 84, 209, 236, 235, 53, 57, 109, 65, 44, 178]),
    binary: [180, 208, 214, 194, 3, 32, 166, 3, 186, 151, 20, 139, 99, 33, 212, 134, 101, 192, 119, 208, 167, 21, 119, 228, 7, 152, 74, 140, 84, 209, 236, 235, 53, 57, 109, 65, 44, 178, 2, 169, 3, 240, 68, 53, 97, 0, 0, 0, 128, 234, 206, 224, 230, 180, 69, 172, 115, 57, 184, 221, 212, 204, 73, 161, 165, 210, 199, 46, 10, 200, 142, 73, 167, 9, 104, 89, 58, 200, 121, 136, 69, 228, 111, 114, 225, 87, 227, 210, 233, 213, 86, 13, 107, 118, 27, 114, 52, 191, 0, 154, 130, 192, 9, 11, 6, 220, 168, 246, 77, 183, 221, 52, 14, 198, 139, 75, 203, 159, 201, 17, 117, 90, 15, 68, 49, 79, 15, 95, 118, 205, 210, 120, 134, 40, 80, 122, 89, 82, 180, 159, 230, 35, 232, 105, 9, 144, 208, 234, 146, 137, 215, 60, 50, 183, 254, 149, 253, 137, 42, 232, 60, 251, 179, 135, 99, 159, 238, 119, 130, 4, 75, 67, 113, 67, 10, 191, 0, 1, 188, 15, 115, 131, 15, 198, 187, 156, 71, 47, 94, 152, 220, 110, 161, 168, 50, 123, 203, 190, 135, 6, 11, 110, 180, 235, 248, 125, 93, 89, 193, 0, 64, 207, 174, 34, 199, 252, 227, 180, 123, 230, 0, 80, 146, 93, 219, 173, 12, 108, 17, 103, 102, 144, 226, 101, 143, 138, 175, 53, 52, 12, 34, 185, 103, 172, 47, 218, 133, 127, 111, 155, 112, 212, 44, 34, 186, 124, 174, 31, 169, 99, 123, 229, 175, 141, 181, 225, 250, 107, 144, 184, 248, 64, 255, 239, 143],
    network: Network.main
)

assert(unifiedSkFromSeed(network: network, seed: seed, accountId: 0) == zusk)

let ufvk = ZcashUnifiedFullViewingKey(
    transparent: ZcashAccountPubKey(data: [172, 47, 218, 133, 127, 111, 155, 112, 212, 44, 34, 186, 124, 174, 31, 169, 99, 123, 229, 175, 141, 181, 225, 250, 107, 144, 184, 248, 64, 255, 239, 143, 3, 111, 37, 170, 229, 124, 18, 76, 113, 36, 56, 195, 139, 128, 159, 3, 85, 157, 108, 123, 169, 41, 162, 114, 164, 52, 10, 223, 248, 52, 108, 205, 229]),
    sapling: ZcashDiversifiableFullViewingKey(data: [104, 119, 78, 174, 92, 136, 149, 198, 96, 227, 105, 161, 53, 107, 19, 188, 102, 74, 74, 25, 10, 176, 247, 215, 107, 151, 114, 81, 219, 102, 69, 130, 133, 79, 204, 59, 27, 255, 22, 230, 174, 141, 22, 124, 161, 209, 133, 134, 135, 246, 48, 57, 124, 253, 178, 67, 153, 122, 83, 18, 255, 107, 237, 5, 144, 208, 234, 146, 137, 215, 60, 50, 183, 254, 149, 253, 137, 42, 232, 60, 251, 179, 135, 99, 159, 238, 119, 130, 4, 75, 67, 113, 67, 10, 191, 0, 1, 188, 15, 115, 131, 15, 198, 187, 156, 71, 47, 94, 152, 220, 110, 161, 168, 50, 123, 203, 190, 135, 6, 11, 110, 180, 235, 248, 125, 93, 89, 193]),
    orchard: ZcashFullViewingKey(data: [217, 18, 30, 164, 50, 177, 77, 168, 203, 62, 31, 194, 233, 92, 142, 202, 116, 169, 65, 20, 233, 254, 226, 49, 182, 95, 128, 83, 139, 57, 113, 26, 81, 152, 72, 233, 206, 149, 236, 131, 88, 163, 120, 203, 217, 162, 129, 78, 77, 130, 234, 90, 171, 214, 164, 122, 98, 230, 241, 122, 211, 53, 76, 56, 237, 144, 10, 210, 117, 240, 245, 128, 179, 253, 215, 103, 53, 60, 171, 109, 84, 132, 71, 89, 119, 27, 143, 153, 167, 186, 160, 224, 98, 87, 142, 57]),
    encoded: "uview1ac6swpuurz2cgr8ktk630exjrz45fsuc4jeqwgg4dm33stl8awhcju0kyaxvw58405jla4k7rqfcw35l4rsj3ta74a2me8p9hh52uxp5zm5wk60pkpy7242wdhdgm265ah3pjqe03m0vax0wa2k4yqnu0gzmnnkt2sjmxeg7s3v8j55mnrzwqznttkaj86ghs2hzp0pstlvw4zlc7kqc2n98h6xluat24829f5fvgue0w8m9r2fwtyzrdvxf7vwu67fd0wdtc0m3m952prz3w7sc8s42v48u9nsd4gld2pgjfzu9qxxxs06mdtkz2dcda0926wulk0t564k3gs6mjm04qmj6e2yrj8vmjh3flh6fg7y4k5fjj09xmv2ffv6ua7e97fszgfpp94uytsq0cu35dd53n45ua4m43gha3dquw60as4xrynllveyjczyffsd8fm6npe88pmg6j6kpjfapuurnrwjya3gz2xfvmyv5r433rsnkra8h"
)

assert(unifiedFvkFromUsk(zusk: zusk) == ufvk)

assert(deserializeUfvk(encoded: ufvk.encoded, network: network) == ufvk)

var byttes = Array(repeating: UInt8(0), count: 32)
byttes[0] = UInt8(1)

let apks = ZcashAccountPrivKey(data: byttes)
assert(fromBytes(data: byttes) == apks, "from bytes")

// test fromSeed for seed = [1, 0, 0, 0, 0, ... ]
let from_seed_above: [UInt8] = [207, 174, 34, 199, 252, 227, 180, 123, 230, 0, 80, 146, 93, 219, 173, 12, 108, 17, 103, 102, 144, 226,
                                101, 143, 138, 175, 53, 52, 12, 34, 185, 103, 172, 47, 218, 133, 127, 111, 155, 112, 212, 44, 34, 186,
                                124, 174, 31, 169, 99, 123, 229, 175, 141, 181, 225, 250, 107, 144, 184, 248, 64, 255, 239, 143]

assert(fromSeed(seed: byttes, accountId: UInt32(0)) == ZcashAccountPrivKey(data: from_seed_above), "from seed")
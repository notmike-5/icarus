# icarus

icarus is a hardware accelerator for the Edwards Digital Signature Algorithm (EdDSA) targeting a Field Programmable Gate Array (FPGA). Also included are functional software examples of EdDSA which are helpful to get a feel for the signature scheme and its moving parts and for examining the group operation and modular exponentiation in particular.


## How is this project organized?

In the root directory you will find three directories `docs/`, `rtl/`, and `src/`.

The `docs/` directory contains documentation about the project including source documents for EdDSA and the cryptographic primitives used therein.

The `rtl/` directory contains the synthesizeable register-transfer level (RTL) descriptions of the design, written (mostly) in SystemVerilog.

Inside this directory you will also find `rtl/tb/` which is where the tests are found. Every module in `rtl/` targets a test file in `rtl/tb/`. Those test files provide synthesis to the module(s) that will take each through its paces and test things like illegal values, boundary conditions, etc. Waveforms and other auxiliary data are also generated in this directory to facilitate more in-depth debugging, testing, and verification.

The `src/` directory contains all relevant software in the project.


## Obtaining / Building

A great way to get a feel for the design is just to build the modules and run the tests. Luckily, this is easy to do and assumes very few dependencies other than `iverilog`.

This repository can be acquired using git:

``` shell
git clone https://github.com/notmike-5/icarus
```

The HDL modules and testbenches can be built by invoking the included Makefile:

``` shell
cd rtl/
make
```

Once built, the simulations and waveforms can be found in `build/` and `build/waves`.

## Running the Tests

To run all tests: `make test`

To run an individual test: `make run/<testbench>`  (e.g. `make run/cla_tb`)


## What is EdDSA?

EdDSA is a modern, public-key digital signature scheme that uses a variant of Schnorr signature based on twisted Edwards curves. EdDSA was created by Daniel Bernstein, Niels Duif, Tanja Lange, Peter Schwabe, and Bo-Yin Yang. They described the scheme in 2011 in "High-speed high-security signatures" (ed25519). It was designed to be extremely fast without sacrificing security. The reference implementation is public-domain software (https://ed25519.cr.yp.to/software.html).

There are several variants of EdDSA. Ed25519 is the version of EdDSA instantiated with the elliptic curve edwards25519.


## Why use EdDSA or Ed25519?

- Fast single-signature verification.
  - 273,364 cycles on authors' device.
- Even faster batch verification.
  - 8.55 million cycles (~134000 cycles per signat6ure) on authors' device.
  - Verifying 64 signatures on 64 messages by 64 keys.
- Very fast signing.
  - 87,548 cycles (109000 msg/s) on authors' device.
- Fast key generation.
  - Key generation almost as fast as signing.
- High security level.
  - Ed25519 has a 2^128 security target
  - similar difficulty to break as NIST P-256, RSA w/ ~ 3000-bit keys, strong 128-bit block ciphers (e.g. AES-128), etc.

[ed25519] Daniel J. Bernstein, Niels Duif, Tanja Lange, Peter Schwabe, Bo-Yin Yang. High-speed high-security signatures. Journal of Cryptographic Engineering 2 (2012), 77–89. URL: https://ed25519.cr.yp.to/ed25519-20110926.pdf Date: 2011.09.26.

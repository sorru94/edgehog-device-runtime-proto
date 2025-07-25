# Copyright 2025 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0


.PHONY: all rust

all: rust

rust:
	cargo run --manifest-path ./rust/Cargo.toml -p codegen -- -p ./proto -o ./output
	cp -v output/edgehog.deviceruntime.containers.v1.rs rust/edgehog-device-runtime-proto/src/containers/v1.rs
	cd rust && cargo fmt


.PHONY: clean

clean:
	test -f ./output && rm -rf ./output

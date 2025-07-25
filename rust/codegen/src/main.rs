// Copyright 2025 SECO Mind Srl
//
// SPDX-License-Identifier: Apache-2.0

use std::io::{stdout, IsTerminal};
use std::path::{Path, PathBuf};

use clap::Parser;
use eyre::WrapErr;
use tracing::{debug, info, instrument, trace};
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;
use tracing_subscriber::EnvFilter;
use walkdir::{DirEntry, WalkDir};

#[derive(Debug, Parser)]
struct Cli {
    /// Directory of the Protobuf definitions.
    #[arg(short, long)]
    protos: PathBuf,
    /// Output directory for the generated files.
    #[arg(short, long)]
    output: PathBuf,
}

fn main() -> eyre::Result<()> {
    color_eyre::install()?;

    tracing_subscriber::registry()
        .with(tracing_subscriber::fmt::layer().with_ansi(stdout().is_terminal()))
        .with(
            EnvFilter::builder()
                .with_default_directive("codegen=DEBUG".parse()?)
                .from_env()?,
        )
        .try_init()?;

    let cli = Cli::parse();

    let protos_path = cli
        .protos
        .canonicalize()
        .wrap_err_with(|| format!("couldn't resolve path {}", cli.protos.display()))?;

    debug!(protos = %protos_path.display(), "using proto directory");

    let protos = find_protos(&protos_path)?;

    debug!(output = %cli.output.display(), "using output directory");

    if !cli.output.exists() {
        debug!(output = %cli.output.display(), "output dir doesn't exists, creating it");

        std::fs::create_dir_all(&cli.output).wrap_err_with(|| {
            format!("couldn't create output directory {}", cli.output.display())
        })?;
    }

    tonic_prost_build::configure()
        .emit_rerun_if_changed(false)
        .out_dir(&cli.output)
        .compile_protos(&protos, &[protos_path])
        .wrap_err("couldn't compile proto definitions")?;

    info!("gRPC and Protobuf file compiled");

    Ok(())
}

#[instrument]
fn filter_entry(entry: &DirEntry) -> bool {
    if entry.file_type().is_file() {
        trace!("checking file extension");

        entry.path().extension().is_some_and(|ext| ext == "proto")
    } else {
        trace!("entry is not a file");

        true
    }
}

#[instrument]
fn find_protos(path: &Path) -> eyre::Result<Vec<PathBuf>> {
    WalkDir::new(path)
        .into_iter()
        .filter_entry(filter_entry)
        .filter(|res| {
            let Ok(entry) = res else { return true };

            entry.file_type().is_file()
        })
        .map(|res| {
            res.map(|entry| entry.into_path())
                .inspect(|path| trace!(proto = %path.display(), "found proto"))
                .wrap_err("coudln't find protos")
        })
        .collect()
}

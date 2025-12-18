#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------
# CONFIG
# ------------------------------------------
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LINUX_ARCHIVE="cpython-3.13.7linux.tar.xz"
RPI_ARCHIVE="cpython-3.13.7rpi.tar.gz"

OUTDIR="${BASE_DIR}/linux"
PYDIR="${OUTDIR}/python"
PYPATH="${PYDIR}/bin/python3"
VENV_DIR="${OUTDIR}/venv"
VENV_PY="${VENV_DIR}/bin/python"

# ------------------------------------------
# FLAG HANDLING (-x = wipe)
# ------------------------------------------
WIPE=0
if [[ "${1:-}" == "-x" ]]; then
    WIPE=1
fi

if [[ "$WIPE" == "1" ]]; then
    echo "[*] Wipe mode enabled: resetting linux..."
    rm -rf "$OUTDIR"
fi

# ------------------------------------------
# ARCH DETECTION
# ------------------------------------------
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        ARCHIVE="$LINUX_ARCHIVE"
        ;;
    aarch64|arm64|armv7l)
        ARCHIVE="$RPI_ARCHIVE"
        ;;
    *)
        echo "[!] ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# ------------------------------------------
# VALIDATE ARCHIVE
# ------------------------------------------
if [[ ! -f "$ARCHIVE" ]]; then
    echo "[!] ERROR: Missing archive: $ARCHIVE"
    exit 1
fi

# ------------------------------------------
# EXTRACT PYTHON (only if missing)
# ------------------------------------------
if [[ ! -f "$PYPATH" ]]; then
    echo "[*] Extracting portable Python ($ARCH)..."
    mkdir -p "$OUTDIR"

    case "$ARCHIVE" in
        *.tar.xz)
            tar -xJf "$ARCHIVE" -C "$OUTDIR"
            ;;
        *.tar.gz)
            tar -xzf "$ARCHIVE" -C "$OUTDIR"
            ;;
    esac

    echo "[*] Extraction complete."
fi

# ------------------------------------------
# VERIFY python
# ------------------------------------------
if [[ ! -f "$PYPATH" ]]; then
    echo "[!] ERROR: python not found at:"
    echo "    $PYPATH"
    exit 1
fi

echo "[OK] Found python:"
echo "    $PYPATH"

# ------------------------------------------
# CREATE VENV (only if missing)
# ------------------------------------------
if [[ ! -f "$VENV_PY" ]]; then
    echo "[*] Creating virtual environment..."
    "$PYPATH" -m venv "$VENV_DIR"
fi

if [[ ! -f "$VENV_PY" ]]; then
    echo "[!] ERROR: Failed to create venv:"
    echo "    $VENV_DIR"
    exit 1
fi

echo "[OK] Virtual environment ready."
echo "[*] Initialization complete."
exit 0

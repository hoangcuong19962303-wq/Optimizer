#!/bin/bash
# Auto Optimizer Ultimate - Simple Installer
# Usage:
#   curl -fsSL "https://raw.githubusercontent.com/hoangcuong19962303-wq/Optimizer/main/setup.sh" | bash
#   cynx

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

APP_NAME="Auto Optimizer Ultimate"
REPO_RAW="https://raw.githubusercontent.com/hoangcuong19962303-wq/Optimizer/main"
INSTALL_DIR="$HOME/.auto-optimizer"
BIN_DIR="${PREFIX:-/usr/local}/bin"
PY_FILE="$INSTALL_DIR/optimizer.py"
CYNX_BIN="$BIN_DIR/cynx"
PY_BIN="${PREFIX:-/data/data/com.termux/files/usr}/bin/python"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_ok() { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
log_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_err() { printf "${RED}[ERR]${NC}  %s\n" "$1"; }

printf '\n╔══════════════════════════════════════════════╗\n'
printf '║  %s          ║\n' "$APP_NAME"
printf '║  DeepClean | FPS Lock | RAM OC | Purge      ║\n'
printf '╚══════════════════════════════════════════════╝\n\n'

log_info "Chuẩn bị thư mục cài đặt..."
rm -rf "$INSTALL_DIR"
rm -f "$CYNX_BIN"
mkdir -p "$INSTALL_DIR"

log_info "Cài dependencies..."
pkg update -y >/dev/null 2>&1 || true
pkg install -y python curl procps >/dev/null 2>&1 || true

# Tự tìm python phù hợp hơn nếu có
if command -v python >/dev/null 2>&1; then
    PY_BIN="$(command -v python)"
fi
if command -v python3 >/dev/null 2>&1; then
    PY_BIN="$(command -v python3)"
fi

log_info "Tải optimizer.py..."
URL="${REPO_RAW}/optimizer.py?v=$(date +%s)"
if ! curl -fsSL --retry 3 --retry-delay 2 "$URL" -o "$PY_FILE"; then
    log_err "Không tải được optimizer.py"
    exit 1
fi
chmod 755 "$PY_FILE"

log_info "Tạo lệnh cynx..."
cat > "$CYNX_BIN" <<'EOF'
#!/bin/sh
set -eu
PY_BIN="__PY_BIN__"
PY_FILE="__PY_FILE__"
INSTALL_DIR="__INSTALL_DIR__"
CYNX_BIN="__CYNX_BIN__"

if [ "${1:-}" = "--reinstall" ]; then
    rm -rf "$INSTALL_DIR"
    rm -f "$CYNX_BIN"
    sed -i '/auto-optimizer/d' "$HOME/.bashrc" 2>/dev/null || true
    echo "✅ Đã gỡ cài đặt"
    exit 0
fi

if [ ! -f "$PY_FILE" ]; then
    echo "❌ Không tìm thấy $PY_FILE"
    exit 1
fi

exec "$PY_BIN" "$PY_FILE" "$@"
EOF
sed -i "s|__PY_BIN__|$PY_BIN|g; s|__PY_FILE__|$PY_FILE|g; s|__INSTALL_DIR__|$INSTALL_DIR|g; s|__CYNX_BIN__|$CYNX_BIN|g" "$CYNX_BIN"
chmod +x "$CYNX_BIN"

# Thêm PATH nếu cần
if [ -n "${PREFIX:-}" ] && [ -d "$BIN_DIR" ]; then
    if ! grep -q "$BIN_DIR" "$HOME/.bashrc" 2>/dev/null; then
        printf '\nexport PATH="%s:\$PATH"\n' "$BIN_DIR" >> "$HOME/.bashrc"
    fi
    export PATH="$BIN_DIR:$PATH"
fi

log_ok "Cài đặt thành công"
printf '\n▶  Chạy:  cynx\n'

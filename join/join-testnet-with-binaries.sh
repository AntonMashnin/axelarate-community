#!/usr/bin/env bash
set -e

AXELAR_CORE_VERSION="$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep axelar-core | cut -d \` -f 4)"
RESET_CHAIN=false
STOP_ME=true
ROOT_DIRECTORY="$HOME/.axelar_testnet"
TOFND_DIRECTORY="$HOME/.tofnd"
GIT_ROOT="$(git rev-parse --show-toplevel)"
TENDERMINT_KEY_PATH=""
AXELAR_MNEMONIC_PATH=""
BIN_DIRECTORY="$ROOT_DIRECTORY/bin"
AXELARD="$BIN_DIRECTORY/axelard"
OS="$(uname | awk '{print tolower($0)}')"
ARCH="$(uname -m)"

for arg in "$@"; do
  case $arg in
    --dev)
    STOP_ME=false
    shift
    ;;
    --validator-mnemonic)
    AXELAR_MNEMONIC_PATH="$2"
    shift
    ;;
    --tendermint-key)
    TENDERMINT_KEY_PATH="$2"
    shift
    ;;
    --reset-chain)
    RESET_CHAIN=true
    shift
    ;;
    -r|--root)
    ROOT_DIRECTORY="$2"
    shift
    ;;
    --axelar-core)
    AXELAR_CORE_VERSION="$2"
    shift
    ;;
    --bin-directory)
    BIN_DIRECTORY="$2"
    shift
    ;;
    *)
    shift
    ;;
  esac
done

addSeeds() {
  seeds="$(cat "$CONFIG_DIRECTORY"/seeds.txt)"
  sed "s/^seeds =.*/seeds = \"$seeds\"/g" "$CONFIG_DIRECTORY/config.toml" >"$CONFIG_DIRECTORY/config.toml.tmp"
  mv "$CONFIG_DIRECTORY/config.toml.tmp" "$CONFIG_DIRECTORY/config.toml"
}

# override ARCH with amd64 for x86 arch
if [ "x86_64" = "$ARCH" ]; then
  ARCH=amd64
fi

echo "Axelar Core Version: ${AXELAR_CORE_VERSION}"
echo "OS: ${OS}"
echo "Architecture: ${ARCH}"
echo "Root Directory: ${ROOT_DIRECTORY}"

if [ "$(git rev-parse --abbrev-ref HEAD)" = "main" ] && $STOP_ME; then
  echo "Please checkout the correct version tag. See README for instructions."
  exit 1
fi

if [ "$(pgrep -f 'axelard start')" != "" ]; then
  echo 'Node already running. Run "kill -9 $(pgrep -f "axelard start")" to kill node.';
  exit 1;
fi

if [ -z "$AXELAR_CORE_VERSION" ]; then
  echo "'--axelar-core vX.Y.Z' is required"
  exit 1
fi

if $RESET_CHAIN; then
  echo
  echo "WARNING! This will erase all previously stored data. Your node will catch up from the beginning"
  printf "Do you wish to proceed \"y/n\" ?  "
  read -r REPLY
  if [ "$REPLY" = "y" ]; then
    echo "Resetting state"
    rm -rf "$ROOT_DIRECTORY"
    rm -rf "$TOFND_DIRECTORY"
    rm -rf ~/.axelar
  else
    echo "Proceeding without resetting state"
  fi
fi

mkdir -p "$ROOT_DIRECTORY"
mkdir -p "$BIN_DIRECTORY"

LOGS_DIRECTORY="${ROOT_DIRECTORY}/logs"
mkdir -p "$LOGS_DIRECTORY"

CORE_DIRECTORY="${ROOT_DIRECTORY}/.core"
mkdir -p "$CORE_DIRECTORY"

CONFIG_DIRECTORY="${CORE_DIRECTORY}/config"
mkdir -p "$CONFIG_DIRECTORY"

AXELARD_BINARY="axelard-${OS}-${ARCH}-${AXELAR_CORE_VERSION}"
echo "Downloading axelard binary $AXELARD_BINARY"
curl -s --fail "https://axelar-releases.s3.us-east-2.amazonaws.com/axelard/${AXELAR_CORE_VERSION}/${AXELARD_BINARY}" -o "${AXELARD}" && chmod +x "${AXELARD}"

if [ ! -f "${CONFIG_DIRECTORY}/genesis.json" ]; then
  echo "Downloading genesis.json"
  curl -s --fail https://axelar-testnet.s3.us-east-2.amazonaws.com/genesis.json -o "${CONFIG_DIRECTORY}/genesis.json"
fi

echo "Downloading seeds.txt (and overwriting if it already exists)"
curl -s --fail https://axelar-testnet.s3.us-east-2.amazonaws.com/seeds.txt -o "${CONFIG_DIRECTORY}/seeds.txt"

echo "Overwriting stale config.toml to config directory with latest seeds"
cp "${GIT_ROOT}/join/config.toml" "${CONFIG_DIRECTORY}/config.toml"
addSeeds

if [ ! -f "${CONFIG_DIRECTORY}/app.toml" ]; then
  echo "Moving app.toml to config directory"
  cp "${GIT_ROOT}/join/app.toml" "${CONFIG_DIRECTORY}/app.toml"
fi

export NODE_MONIKER=${NODE_MONIKER:-"$(hostname)"}
export AXELARD_CHAIN_ID=${AXELARD_CHAIN_ID:-"axelar-testnet-barcelona"}

echo "Node moniker: $NODE_MONIKER"
echo "Axelar Chain ID: $AXELARD_CHAIN_ID"
# For some reason Cosmos is outputs to stderr
ACCOUNTS="$($AXELARD keys list -n --home "$CORE_DIRECTORY" 2>&1)"
echo "Accounts: $ACCOUNTS"
for ACCOUNT in $ACCOUNTS; do
    if [ "$ACCOUNT" = "validator" ]; then
        HAS_VALIDATOR=true
    fi
done

touch "$ROOT_DIRECTORY/validator.txt"
if [ -z "$HAS_VALIDATOR" ]; then
  if [ -f "$AXELAR_MNEMONIC_PATH" ]; then
    "$AXELARD" keys add validator --recover --home "$CORE_DIRECTORY" <"$AXELAR_MNEMONIC_PATH"
  else
    "$AXELARD" keys add validator --home "$CORE_DIRECTORY" > "$ROOT_DIRECTORY/validator.txt" 2>&1
  fi
fi

"$AXELARD" keys show validator -a --bech val --home "$CORE_DIRECTORY" > "$ROOT_DIRECTORY/validator.bech"

if [ ! -f "$CONFIG_DIRECTORY/genesis.json" ]; then
  "$AXELARD" init "$NODE_MONIKER" --chain-id "$AXELARD_CHAIN_ID" --home "$CORE_DIRECTORY"
  if [ -f "$TENDERMINT_KEY_PATH" ]; then
    cp -f "$TENDERMINT_KEY_PATH" "$CONFIG_DIRECTORY/priv_validator_key.json"
  fi
fi

export START_REST=true

"$AXELARD" start --home "$CORE_DIRECTORY" > "$LOGS_DIRECTORY/axelard.log" 2>&1 &

VALIDATOR=$("$AXELARD" keys show validator -a --bech val --home "$CORE_DIRECTORY")
echo
echo "Axelar node running."
echo
echo "Validator address: $VALIDATOR"
echo
cat "$ROOT_DIRECTORY/validator.txt"
rm "$ROOT_DIRECTORY/validator.txt"
echo
echo "Do not forget to also backup the tendermint key (${CONFIG_DIRECTORY}/priv_validator_key.json)"
echo
echo "To follow execution, run 'tail -f ${LOGS_DIRECTORY}/axelard.log'"
echo 'To stop the node, run "kill -9 $(pgrep -f "axelard start")"'
echo

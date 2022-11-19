# parse with system protoc and sent to zig-out/bin/protoc-gen-zig

set -e
PATH=zig-out/bin/:$PATH protoc --zig_out=gen $1 $2
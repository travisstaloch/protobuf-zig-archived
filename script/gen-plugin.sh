# use protozig to generate .proto.zig files from
# examples/google/protobuf/{descriptor.proto,compiler/plugin.proto}

set -e
pushd ../protozig
zig build
popd
PROTOZIG=../protozig/zig-out/bin/protozig

mkdir -p src/gen/examples/google/protobuf/compiler
$PROTOZIG -I examples/ examples/google/protobuf/compiler/plugin.proto > src/gen/examples/google/protobuf/compiler/plugin.proto.zig
$PROTOZIG -I examples/ examples/google/protobuf/descriptor.proto > src/gen/examples/google/protobuf/descriptor.proto.zig
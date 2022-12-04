set -e
flags=""
# parent_dir=../protozig
parent_dir=.
files=$(ls $parent_dir/examples/*.proto)
keep=false
if [ "$1" == "stage1" ] ; then
  shift
  flags="-fstage1"
fi
if [ "$1" == "keep" ] ; then
  shift
  keep=true
fi
if
  [ "$1" == "google" ] ; then
  shift
  files=$(ls $parent_dir/examples/google/protobuf/{any,duration,field_mask,struct,timestamp,wrappers}*)
  files+=" $parent_dir/examples/google/protobuf/test_messages_proto3.proto"
fi
if [ $# -gt 0 ] ; then
  files="$@"
fi

zig build $flags -Dlog-level=debug

OUT_DIR=/tmp/protozig/gen
mkdir -p $OUT_DIR

for file in $files; do
  base=${file%.*} # remove file extension (assumed to be '.proto')
  proto="$base.proto"
  echo "compiling and testing $proto"
  # gen/protoc.exe -Iexamples --js_out=gen/js $proto
  DIR=$(dirname $file)
  mkdir -p $OUT_DIR/$DIR

  # zig-out/bin/protoc-zig -I$DIR $proto |& script/protoc-decode-text.sh #> $OUT_DIR/$base.proto.zig
  # zig test $flags $OUT_DIR/$base.proto.zig --pkg-begin decoding src/decoding.zig --pkg-end -I$DIR
  zig-out/bin/protoc-zig -I$DIR $proto
done

# if [ keep == false ]; then
#   rm -rf $OUT_DIR/* 
# fi
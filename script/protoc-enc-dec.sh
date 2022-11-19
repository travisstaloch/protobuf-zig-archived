# use system protoc to parse a proto and then decode it to text format

set -e
script/protoc-capture.sh $1 $2 |& script/protoc-decode-text.sh
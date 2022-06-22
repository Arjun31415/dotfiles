DIR="$(cd "$(dirname "$0")" && pwd)"
var=$(ps -efj | grep -w ".*python src/main.py.*" |  grep -v "grep" | awk '{print kill $2}' | xargs kill -2 )

$DIR/comicStart.sh


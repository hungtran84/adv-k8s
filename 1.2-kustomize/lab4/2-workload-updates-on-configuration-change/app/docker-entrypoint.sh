#!/bin/sh

set -e

if [ -n "$NODE_ENV" ] && [ "$NODE_ENV" = 'development' ]; then
    exec env PATH="/app/node_modules/.bin:$PATH" nodemon src/index.js
fi

exec node src/index.js

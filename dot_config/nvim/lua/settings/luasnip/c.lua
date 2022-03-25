local ls = require 'luasnip'
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

return {
    inc = fmt([[#include <{}.h>{}]], { i(0), i(1) }),
    Inc = fmt([[#include "{}.h"{}]], { i(0), i(1) }),
    main = fmt(
        [[
          int main(int argc, const char *argv)
          {{
          	{}
          }}
        ]],
        { i(0) }
    ),
    mainn = fmt(
        [[
          int main(void)
          {{
          	{}
          }}
        ]],
        { i(0) }
    ),
}

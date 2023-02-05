local ls = require 'luasnip'
local i = ls.insert_node
local s = ls.s
local fmt = require('luasnip.extras.fmt').fmt

return {
    s('inc', fmt([[#include <{}.h>{}]], { i(0), i(1) })),
    s('Inc', fmt([[#include "{}.h"{}]], { i(0), i(1) })),
    s(
        'main',
        fmt(
            [[
          int main(int argc, const char *argv)
          {{
          	{}
          }}
        ]],
            { i(0) }
        )
    ),
    s(
        'mainn',
        fmt(
            [[
          int main(void)
          {{
          	{}
          }}
        ]],
            { i(0) }
        )
    ),
}

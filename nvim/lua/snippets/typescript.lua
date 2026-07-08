local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {

  s(
    "ac",
    fmt(
      [[
import {{ Component }} from '@angular/core';

@Component({{
  selector: 'app-{}',
  standalone: true,
  imports: [],
  template: `
    {}
  `,
}})
export class {} {{}}
]],
      {
        i(1, "feature"),
        i(0),
        i(2, "Feature"),
      }
    )
  ),

}

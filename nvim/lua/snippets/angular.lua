local ls = require("luasnip")

local s = ls.snippet
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- filename without extension
local function filename()
  return vim.fn.expand("%:t:r")
end

-- kebab-case -> PascalCase
local function pascal_case(name)
  local result = {}

  for part in name:gmatch("[^%-_]+") do
    table.insert(result, part:sub(1, 1):upper() .. part:sub(2))
  end

  return table.concat(result)
end

ls.add_snippets("typescript", {

  s(
    "ac",
    fmt(
      [[
import {{ Component }} from '@angular/core';

@Component({{
  selector: 'app-{}',
  imports: [],
  template: `
    <p>{} works</p>
  `,
}})
export class {} {{}}
]],
      {
        f(function()
          return filename()
        end),

        f(function()
          return filename()
        end),

        f(function()
          return pascal_case(filename())
        end),
      }
    )
  ),

})

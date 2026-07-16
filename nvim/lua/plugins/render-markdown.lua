return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    bullet = {
      right_pad = 1,
    },
    checkbox = {
      enabled = true,
      render_modes = false,
      bullet = false,
      left_pad = 0,
      right_pad = 1,
      unchecked = {
        -- icon = "󰄱",
        icon = "􀂒",
        highlight = "RenderMarkdownUnchecked",
        scope_highlight = nil,
      },
      checked = {
        icon = "􀃲",
        -- icon = "󰱒",
        -- rendered = "󰱒",
        highlight = "RenderMarkdownChecked",
        scope_highlight = nil,
      },
      custom = {
        todo = {
          left_pad = 1,
          right_pad = 0,
          raw = "[-]",
          rendered = "󰥔",
          highlight = "RenderMarkdownTodo",
          scope_highlight = nil,
        },
        inprogress = {
          left_pad = 1,
          right_pad = 0,
          raw = "[/]",
          rendered = "􀚔",
          highlight = "RenderMarkdownTodo",
          scope_highlight = nil,
        },
        question = {
          left_pad = 1,
          right_pad = 0,
          raw = "[?]",
          rendered = "󰘥",
          highlight = "RenderMarkdownTodo",
          scope_highlight = nil,
        },
        blocked = {
          left_pad = 1,
          right_pad = 0,
          raw = "[B]",
          rendered = "􁝊",
          highlight = "RenderMarkdownTodo",
          scope_highlight = nil,
        },
      },
      scope_priority = nil,
    },
  },
}

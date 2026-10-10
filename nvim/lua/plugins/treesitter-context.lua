-- Pin the enclosing function/class header to the top while scrolling its body
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'VeryLazy',
  opts = {
    max_lines = 3,
  },
}

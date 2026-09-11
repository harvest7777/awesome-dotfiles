-- LaTeX math snippets. Most of these are autosnippets: they expand the moment
-- the trigger is typed, with no Tab, because stopping to confirm every
-- \frac defeats the point when you're transcribing a problem set.
local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

-- vimtex knows whether the cursor sits inside $...$, \[...\] or an align body.
-- Everything below is scoped on this so `sr` still types the letters s and r
-- in a sentence.
local function math()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

local function text()
  return not math()
end

-- expands after a letter as well as after whitespace, so `x sr` -> `x^2`
local function auto(trig, opts)
  return vim.tbl_extend('force', {
    trig = trig,
    wordTrig = false,
    snippetType = 'autosnippet',
  }, opts or {})
end

local M = {
  -- entering and leaving math ------------------------------------------------
  s(auto('mk'), fmta('$<>$<>', { i(1), i(0) }), { condition = text }),
  s(auto('dm'), fmta('\\[\n  <>\n\\]\n<>', { i(1), i(0) }), { condition = text }),

  -- fractions, powers, subscripts --------------------------------------------
  s(auto('//'), fmta('\\frac{<>}{<>}', { i(1), i(2) }), { condition = math }),
  s(auto('sr'), t('^2'), { condition = math }),
  s(auto('cb'), t('^3'), { condition = math }),
  s(auto('td'), fmta('^{<>}', { i(1) }), { condition = math }),
  s(auto('__'), fmta('_{<>}', { i(1) }), { condition = math }),
  s(auto('sq'), fmta('\\sqrt{<>}', { i(1) }), { condition = math }),
  s(auto('ee'), fmta('e^{<>}', { i(1) }), { condition = math }),

  -- big operators ------------------------------------------------------------
  s(auto('sum'), fmta('\\sum_{<>}^{<>} ', { i(1, 'n=1'), i(2, '\\infty') }), { condition = math }),
  s(auto('prod'), fmta('\\prod_{<>}^{<>} ', { i(1, 'n=1'), i(2, '\\infty') }), { condition = math }),
  s(auto('int'), fmta('\\int_{<>}^{<>} <> \\, d<>', { i(1), i(2), i(3), i(4, 'x') }), { condition = math }),
  s(auto('lim'), fmta('\\lim_{<> \\to <>} ', { i(1, 'n'), i(2, '\\infty') }), { condition = math }),
  s(auto('part'), fmta('\\frac{\\partial <>}{\\partial <>}', { i(1), i(2, 'x') }), { condition = math }),
  s(auto('dv'), fmta('\\frac{d<>}{d<>}', { i(1), i(2, 'x') }), { condition = math }),

  -- relations and arrows -----------------------------------------------------
  s(auto('!='), t('\\neq '), { condition = math }),
  s(auto('<='), t('\\leq '), { condition = math }),
  s(auto('>='), t('\\geq '), { condition = math }),
  s(auto('~~'), t('\\approx '), { condition = math }),
  s(auto('->'), t('\\to '), { condition = math }),
  s(auto('|->'), t('\\mapsto '), { condition = math }),
  s(auto('=>'), t('\\implies '), { condition = math }),
  s(auto('iff'), t('\\iff '), { condition = math }),
  s(auto('xx'), t('\\times '), { condition = math }),
  s(auto('**'), t('\\cdot '), { condition = math }),
  s(auto('ooo'), t('\\infty'), { condition = math }),
  s(auto('inn'), t('\\in '), { condition = math }),
  s(auto('notin'), t('\\notin '), { condition = math }),
  s(auto('sub'), t('\\subseteq '), { condition = math }),
  s(auto('cup'), t('\\cup '), { condition = math }),
  s(auto('cap'), t('\\cap '), { condition = math }),
  s(auto('AA'), t('\\forall '), { condition = math }),
  s(auto('EE'), t('\\exists '), { condition = math }),

  -- number sets --------------------------------------------------------------
  s(auto('RR'), t('\\mathbb{R}'), { condition = math }),
  s(auto('NN'), t('\\mathbb{N}'), { condition = math }),
  s(auto('ZZ'), t('\\mathbb{Z}'), { condition = math }),
  s(auto('QQ'), t('\\mathbb{Q}'), { condition = math }),
  s(auto('CC'), t('\\mathbb{C}'), { condition = math }),

  -- delimiters ---------------------------------------------------------------
  s(auto('lr('), fmta('\\left( <> \\right)', { i(1) }), { condition = math }),
  s(auto('lr['), fmta('\\left[ <> \\right]', { i(1) }), { condition = math }),
  s(auto('lr{'), fmta('\\left\\{ <> \\right\\}', { i(1) }), { condition = math }),
  s(auto('lr|'), fmta('\\left| <> \\right|', { i(1) }), { condition = math }),
  s(auto('ceil'), fmta('\\left\\lceil <> \\right\\rceil', { i(1) }), { condition = math }),
  s(auto('floor'), fmta('\\left\\lfloor <> \\right\\rfloor', { i(1) }), { condition = math }),

  -- environments (Tab-expanded; these are deliberate, not reflexive) ----------
  s('beg', fmta('\\begin{<>}\n  <>\n\\end{<>}', { i(1), i(2), rep(1) })),
  s('ali', fmta('\\begin{align*}\n  <>\n\\end{align*}', { i(1) })),
  s('eqn', fmta('\\begin{equation}\n  <>\n\\end{equation}', { i(1) })),
  s('cases', fmta('\\begin{cases}\n  <>\n\\end{cases}', { i(1) })),
  s('mat', fmta('\\begin{pmatrix}\n  <>\n\\end{pmatrix}', { i(1) })),
  s('enum', fmta('\\begin{enumerate}\n  \\item <>\n\\end{enumerate}', { i(1) })),
  s('itm', fmta('\\begin{itemize}\n  \\item <>\n\\end{itemize}', { i(1) })),
}

-- greek letters, typed as ;a, ;b, ;g ... so they never collide with real words
local greek = {
  a = 'alpha', b = 'beta', g = 'gamma', G = 'Gamma', d = 'delta', D = 'Delta',
  e = 'epsilon', z = 'zeta', h = 'eta', th = 'theta', T = 'Theta', k = 'kappa',
  l = 'lambda', L = 'Lambda', m = 'mu', n = 'nu', x = 'xi', p = 'pi', P = 'Pi',
  r = 'rho', s = 'sigma', S = 'Sigma', ta = 'tau', ph = 'phi', F = 'Phi',
  c = 'chi', ps = 'psi', o = 'omega', O = 'Omega',
}

for key, name in pairs(greek) do
  table.insert(M, s(auto(';' .. key), t('\\' .. name), { condition = math }))
end

return M

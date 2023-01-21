local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local rec_ls
rec_ls = function()
	return sn(nil, {
		c(1, {
			-- important!! Having the sn(...) as the first choice will cause infinite recursion.
			t({ "" }),
			-- The same dynamicNode as in the snippet (also note: self reference).
			sn(nil, {
				t({ "", "\t\\item " }),
				i(1),
				d(2, rec_ls, {}),
			}),
		}),
	})
end

local M = {}
M = {
	s("doc", {
		t({ "\\documentclass{" }),
		i(1, "class"),
		t({ "}" }),
		i(0),
	}),
	s("package-basic", {
		t({
			"\\usepackage{float}",
			"\\usepackage{graphicx}",
			"\\usepackage{geometry}                % 页边距调整",
			"\\geometry{top=3.0cm,bottom=2.7cm,left=2.5cm,right=2.5cm}",
		}),
	}),
	s("package-math", {
		t({
			"%==================== 数学符号公式 ============",
			"\\usepackage{amsmath}                 % AMS LaTeX宏包",
			"\\usepackage[style=1]{mdframed}",
			"\\usepackage{amsthm}",
			"\\usepackage{amsfonts}",
			"\\usepackage{makecell}",
			"\\usepackage{mathrsfs}                % 英文花体字 体",
			"\\usepackage{tabu,tikz} % 绘图",
		}),
	}),
	s("package-hyper", {
		t({
			"\\usepackage{hyperref}                % 交叉引用",
			"\\hypersetup{hidelinks}",
		}),
	}),
	s("package-hdr", {
		t({
			"\\usepackage{fancyhdr}",
			"\\pagestyle{fancy}",
			"\\fancyhf{}",
		}),
		t({
			"\\fancyhead[C]{\\zihao{5} \\kaishu ",
		}),
		i(1, { "合肥工业大学课程设计 LaTeX 模板" }),
		t({ "}", "\\fancyfoot[C]{~\\zihao{5} \\thepage~}", "\\renewcommand{\\headrulewidth}{0.65pt}" }),
	}),
	s("package-code", {
		t({
			"\\usepackage{listings}",
			"\\usepackage{color,xcolor}",
			"\\usepackage{pythonhighlight}",
			"\\definecolor{dkgreen}{rgb}{0,0.6,0}",
			"\\definecolor{gray}{rgb}{0.5,0.5,0.5}",
			"\\definecolor{mauve}{rgb}{0.58,0,0.82}",
			"\\lstset{",
			"frame=tb,",
			"aboveskip=3mm,",
			"belowskip=3mm,",
			"showstringspaces=false,",
			"columns=flexible,",
			"framerule=1pt,",
			"rulecolor=\\color{gray!35},",
			"backgroundcolor=\\color{gray!5},",
			"basicstyle={\\small\\ttfamily},",
			"numbers=none,",
			"numberstyle=\\tinycolor{gray},",
			"keywordstyle=\\color{blue},",
			"commentstyle=\\color{dkgreen},",
			"stringstyle=\\color{mauve},",
			"breaklines=true,",
			"breakatwhitespace=true,",
			"tabsize=3,",
			"}",
		}),
	}),
	s("package-advanced", {
		t({
			"\\usepackage{setspace}",
			"\\usepackage{subfigure} % 多子图",
			"\\usepackage{stfloats}",
			"\\usepackage{ifthen}",
			"\\usepackage{datetime}",
			"\\usepackage{caption} % 该宏包定义了多种命令，可以对浮动体标题的字体、宽度、位置和颜色等标题样式参数进行设置；它提供了很多选项，可以对标题的格式、字体、对齐方式、风格和边空等产生影响；它还可以将浮动体的标题移到浮动环境之外。",
			"\\usepackage{booktabs} % 三线表",
			"\\usepackage{shortlst} % 在 LaTeX 的列表环境中，每个条目最少要占据一行，如果条目的词句很短而条目的数量很多，如习题或考卷答案，版面看起来很空荡。该宏包定义了四种环境，专门用于排版词句很短的条目列表，它能在一行中排列多个短条目，以节省版面空间。",
			"\\usepackage{shorttoc} % 它可以在文稿总目录之前生成一个简略目录，主要用于排版大型书籍，以方便读者了解主题内容。 它提供一条命令：shorttoc{目录名称}{层次深度}，可直接生成文件目录，而无需  \tableofcontents 命令的支持；如需该命令来生成主目录，则应放在 shorttoc 命令之后，否则简略目录将成空白。",
			"\\usepackage{tabu,tikz} % 数学绘图",
			"\\usepackage{makecell} % 表格内换行",
			"\\usepackage{multirow,multicol} % 表格中合并多行",
		}),
	}),
	s("itemize", {
		t({ "\\begin{itemize}", "\t\\item " }),
		i(1),
		d(2, rec_ls, {}),
		t({ "", "\\end{itemize}" }),
		i(0),
	}),
	s("enum", {
		t({ "\\begin{enumerate}", "\t\\item " }),
		i(1),
		d(2, rec_ls, {}),
		t({ "", "\\end{enumerate}" }),
		i(0),
	}),
	s("par", {
		t({ "\\paragraph{" }),
		i(1),
		t({ "}", "" }),
		i(2),
		t({ "", "\\par" }),
		i(0),
	}),
}

return M

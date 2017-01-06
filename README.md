Overleaf Workflow for Physics Handouts
======================================

Overleaf is a real-time collaborative LaTeX editor.
It has many nice features like a live(ish) document preview.
However, each Overleaf project can only compile a single target .tex file into a single document, which makes managing course materials (dozens of handouts) a pain.
Also, it only stores a limited version history (24h unless a checkpoint is manually created) and the text editor interface is not always ideal.
Based on past quarters' experiences I've written some LaTeX packages to make handling multiple handouts with Overleaf a bit less annoying.

Creating Handouts
-----------------

The handouts for a given course are defined in the main.tex file.
There can be multiple types of handouts (e.g. lectures, problem sets, activity sheets) and each type is automatically numbered separately.
In our case, we have `lecture`, `activity`, and `pset` handout classes. These classes are created using `\inithandout{short_name}{Long Name}`, like `\inithandout{pset}{Problem Set}`.

To actually create a handout, use the following format in the main.tex file:

    \begin{<handout_class>}[<tag>]{<Title>}
        \input{<filename.tex>}
	\end{<handout_class>}

where `<handout_class>` is `lecture`, `activity`, `pset`, etc.;
`<tag>` is a short name for the handout which you can refer to elsewhere (e.g. to specific which handouts to generate, or reference the number of a handout);
`<Title>` is the title that will appear in the header of the handout;
and `<filename.tex>` is the file containing the LaTeX code for the handout.
(You don't necessarily have to use the `\input` line; you could put the code directly in the main.tex file.
However, as we get a large number of handouts going, it will be much cleaner to separate things out.)

In our Overleaf project, we have a subfolder for the .tex files for each type of handout, as well as one for figures.

Note that the numbering of the handouts is automatic and based on the order that their `\begin{}[]{}...\end{}` code appears in main.tex.
However, you can interleave (say) `activity`s and `lecture`s without affecting the numbering.
Basically, the idea should be to list the handouts in main.tex in chronological order, and the numbering should take care of itself.

Selecting Handouts to Compile
-----------------------------

You probably don't want to see every handout for the course at the same time, but rather just the one(s) currently under development.
For this purpose use the `\only...` macros, e.g.

    \onlylecture{time_dilation}

means that the only lecture output to PDF will be the one with `<tag>` `time_dilation`.
Multiple tags can be specified with commas.

If there is no `\only...` for a given type of handout, they will all be produced. So, generally main.tex will have a section like this:

    \onlylecture{current_lecture_tag}
	\onlyactivity{current_activity_tag}
	\onlypset{}

which means that the only handouts generated are the current lecture and activity (specified by their tags), and no problem sets.

This seems a bit complicated at first, but it addresses an issue with Overleaf so that multiple people can be working on multiple handouts at the same time, in the same project.

The handouts are added to the LaTeX table of contents, so you can generate a list of the handouts in a given PDF file by using `\tableofcontents`. Since the `\only...` commands are global in scope, you can do some interesting tricks like creating a 'meta-handout' with a table of contents:

    \inithandout{meta}{Meta-Handout}
	...
	\onlymeta{sr_contents}
	
	\begin{meta}[sr_contents]{Special Relativity Unit}
        \onlylecture{time_dilation,len_con,spacetime,lorentz,causality,four_vectors,energy} % include all SR lectures
		\onlyactivity{longitudinal_light_clock,binomial,simultaneity,spacetime,lonely_photon,pion_decay} % include all SR activities
		\onlypset{} % no problem sets
		\onlymeta{} % we are already inside the relevant meta, so we don't need to include it here
	
		\handoutid{}
		\def\contentsname{List of Materials}
		\tableofcontents
	\end{misc}
	
	...definitions of the rest of the handouts...


Writing Solutions
-----------------

There are several ways to include solutions into the original .tex files.
Depending on the setting in main.tex, the solutions will either be completely hidden or show up.
`\usepackage{solution}` defines the solution macros but hides the contents (in various ways);
`\usepackage[show]{solution}` shows the solutions.

There are FOUR different ways to include solutions, depending on the context:

* `\begin{solution}...\end{solution}` is for long solutions (e.g. to pset problems).
  They are completely ignored when hidden and decorated with some horizontal rules and **Solution.** at the beginning when unhidden.
  **The `\begin` and `\end` commands MUST appear at the beginning of the line with no leading whitespace and nothing else on the line.**
  (This is a quirk of the `comment` package which handles the showing/hiding of the solutions. It can lead to very very non-obvious, sometimes silent, failures, like missing part of your document in the generated PDF file.)
* `\soln{...}` is for short, inline solutions (e.g. in lecture exercises) that leave a space for the student to write the solution in.
  This works inside math environments, etc. There can be no paragraph breaks, or anything equivalent to a paragraph break (such as a `$$display-mode equation$$` or `align` environment.) LaTeX will tell you that it can't find a closing brace if you try to put in a paragraph break.
* `\solnx{...}` is the same as `\soln` except it doesn't leave a space for the student to write in.
* `\bigsoln{...}` allows longer inline solutions which include paragraph breaks, etc.
  Some space is left for writing in an answer, but it's not always as big as the solution itself. It's often better to use `\solnx` + `\workspace` (see below) for more control.

There is a nice way to include some space in the original document that disappears in the solution: `\workspace` (or `\workspace[<length>]`).

Finally, you may want to selectively show/hide solutions in parts of a document. For this you can use `\showsolution` and `\hidesolution` which show/hide the solutions after that point, up through the end of the scope (usually the current handout).

Working Locally with git
------------------------

If you prefer to use your favorite TeX editor, work offline, or just don't like Overleaf, it's possible to grab a local copy of the Overleaf repository using git and push your changes back to the cloud. A Makefile is included which will (re)compile each handout to its own PDF file, both with and without solutions included.

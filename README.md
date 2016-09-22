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
In our case, we have `lecture`, `activity`, and `pset` handout classes.

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

Writing Solutions
-----------------

There are several ways to include solutions into the original .tex files.
Depending on the setting in main.tex, the solutions will either be completely hidden or show up.
`\usepackage{solution}` defines the solution macros but hides the contents (in various ways);
`\usepackage[show]{solution}` shows the solutions.
(I'm working on a way to turn solutions on/off for handouts independently, rather than for the whole document, but this is in progress.)

There are FOUR different ways to include solutions, depending on the context:

* `\begin{solution}...\end{solution}` is for long solutions (e.g. to pset problems).
  They are completely ignored when hidden and decorated with some horizontal rules and **Solution.** at the beginning when unhidden.
* `\soln{...}` is for short, inline solutions (e.g. in lecture exercises) that leave a space for the student to write the solution in.
  This works inside math environments, etc.
* `\solnx{...}` is the same as `\soln` except it doesn't leave a space for the student to write in.
* `\bigsoln{...}` allows longer inline solutions which include paragraph breaks, etc.
  Some space is left for writing in an answer, but it's not as big as the solution itself.

Also, there is a nice way to include some space in the original document that disappears in the solution: `\workspace` (or `\workspace[<length>]`).

Working Locally with git
------------------------

If you prefer to use your favorite TeX editor, work offline, or just don't like Overleaf, it's possible to grab a local copy of the Overleaf repository using git and push your changes back to the cloud.

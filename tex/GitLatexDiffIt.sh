

if [ $# -ne 1 ]; then
    echo " Syntax: GitLatexDiffIt.sh  ref "; echo
    echo "   where ref is a hash of tag for the starting commit you want.  "; echo
    echo "  It will then be compared to the current working copy (even if uncommitted) "
    echo
    echo
    echo " Example: GitLatexDiffIt.sh toCoauthors "
    echo
fi


mkdir -p diffs

M="diffs/main-diff-to-$1.pdf"
S="diffs/supplement-diff-to-$1.pdf"

# get the main document (note we have to latex supplement.tex first for xr)
git-latexdiff \
    --prepare 'pdflatex supplement.tex' \
    --bibtex \
    --main main.tex \
    --output  $M \
    $1  -- && \
    open $M;



# get the supplement
git-latexdiff \
    --prepare 'pdflatex main.tex' \
    --bibtex \
    --main supplement.tex \
    --output  $S \
    $1 -- &&
    open $S


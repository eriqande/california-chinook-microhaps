

# A quick shell script to compile all the input files, to
# the main manuscript so that we can typset it.


# run this and then pdflatex blinded.tex to get a PDF to submit with
# no author names or acknowedgements.  Then zip up the LateX distro folder
# and try to be done with it. 


# Note, it looks like we should be able to submit using
# LaTeX because Wiley at:
#
# https://authorservices.wiley.com/author-resources/Journal-Authors/Prepare/new-journal-design.html
#
# states:
#
# If the journal to which you would like to submit your manuscript is not using NJD, please check with the Editorial Office of that journal if they have their own journal-specific template. It is possible to use this NJD LaTeX template for journals not using NJD even though the manuscript might not simulate completely that journal’s typesetting specifications.
#
# Many journals at Wiley accept LaTeX files at submission, while others will require you to upload a PDF at submission and supply the native LaTeX files at a later date.
#
### Post-acceptance files

# Please provide your article’s references in bibtex format, if possible, because this will help during the conversion process of accepted manuscripts into typeset specifications if references need to be reformatted to a specific journal’s reference style. Embedded references in the TeX file will require the typesetter to do a manual process to reformat them into the journal’s required style if the references are provided in a different style.

# Please check that you have supplied the following files for typesetting post-acceptance:
# (i) PDF created from the finalized source manuscript files compiled without any errors.
# (ii) The LaTeX source code files (text, figure captions, and tables, preferably in a single file), BibTeX format files (if used), and any associated packages/files along with all other files needed for compiling without any errors. This is particularly important if you have used any LaTeX style or class files, bibliography files (.bib, .bbl, .bst) or packages apart from those used in the NJD LaTeX template class file.
# (iii) Electronic graphics files for the figures/illustrations in Encapsulated PostScript (EPS), PDF or TIFF format. Authors are requested not to create figures using LaTeX codes.
#
#


# All of which makes it sound like all Wiley journals can take LaTeX, it is just
# that some of them don't have a template.




# make a directory to put all this stuff
OUTDIR="LatexSourcesForSubmission-$(date +'%Y-%m-%d_%H-%M-%S')"


# Here we get the main document. 
MAIN="main-one-col.tex"


# This gets all .tex files inputted into main-one-col.tex.  But we will
# flatten it, so we don't really need this.
SECTIONS=$(awk -F"[{}]" '/\\input/ {print $2 ".tex"}' main-one-col.tex)

# this gets all the tables that are input throughout the main body.  Once again,
# because we are flattening the document with latexpand, we don't need this
TABLES=$(awk -F"[{}]" '/\\input/ {print $2}' body-text-of-paper.tex)


# here are all the main figures that are inserted into it
MAIN_FIGURES=$(awk -F"[{}]" '/\\includegraphics/ {print $2}' body-text-of-paper.tex)


# here are the little point shapes that go into the caption
# for the map
MAP_BALLS=$(awk -F"[{}]" '/\\includegraphics/ {print}' newcomms.tex | sed 's/^.*\]{//g;' | sed s'/}//g;')


# There are the little sparklines in the samples table
SPARKLINES=$(awk -F"[{}]" '/\\includegraphics/ {print}' inputs/samples-table.tex  | sed 's/^.*\]{//g;' | sed s'/}//g;' | sed 's/..\/tex\///g;' | awk -F'&' '{print $1}')


# here is a string of other special files (and the main file!) that must be included
SPECIALS="citation.bib main-one-col.bbl eca_molecolres.sty supplement.aux men.bst"


# here are the new directories we must create inside OUTDIR
NEWDIRS=$(dirname $MAIN_FIGURES $MAP_BALLS  $SPARKLINES | uniq)

# Make the needed directories
for i in $NEWDIRS; do mkdir -p $OUTDIR/$i; done

# now copy everything over
for i in $SPECIALS $MAIN_FIGURES $MAP_BALLS  $SPARKLINES; do
    cp $i $OUTDIR/$i
done

# Then latexpand the main document and redirect it into something called
# main-one-col.pdf in the outdir
latexpand $MAIN > "$OUTDIR/main-one-col.tex"


# now, we also want to make a blinded version
awk '
    /\\maketitle/ {next}
    /^\\input.acknowledgements./ {next}
    {print}
' main-one-col.tex > blinded.tex

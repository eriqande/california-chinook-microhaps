

# A quick shell script to compile all the input files, to
# the main manuscript so that we can typset it.



# make a directory to put all this stuff
OUTDIR="LatexSourcesForSubmission-$(date +'%Y-%m-%d_%H-%M-%S')"


# This gets all .tex files inputted into main-one-col.tex
SECTIONS=$(awk -F"[{}]" '/\\input/ {print $2 ".tex"}' main-one-col.tex)

# this gets all the tables that are input throughout the main body
TABLES=$(awk -F"[{}]" '/\\input/ {print $2}' body-text-of-paper.tex)

# here are all the main figures that are inserted into it
MAIN_FIGURES=$(awk -F"[{}]" '/\\includegraphics/ {print $2}' body-text-of-paper.tex)


# here are the little point shapes that go into the caption
# for the map
MAP_BALLS=$(awk -F"[{}]" '/\\includegraphics/ {print}' newcomms.tex | sed 's/^.*\]{//g;' | sed s'/}//g;')


# There are the little sparklines in the samples table
SPARKLINES=$(awk -F"[{}]" '/\\includegraphics/ {print}' inputs/samples-table.tex  | sed 's/^.*\]{//g;' | sed s'/}//g;' | sed 's/..\/tex\///g;' | awk -F'&' '{print $1}')


# here is a string of other special files (and the main file!) that must be included
SPECIALS="main-one-col.tex main-one-col.bbl eca_molecolres.sty supplement.aux"


# here are the new directories we must create inside OUTDIR
NEWDIRS=$(dirname $TABLES $MAIN_FIGURES $MAP_BALLS  $SPARKLINES | uniq)

# Make the needed directories
for i in $NEWDIRS; do mkdir -p $OUTDIR/$i; done

# now copy everything over
for i in $SPECIALS $SECTIONS $TABLES $MAIN_FIGURES $MAP_BALLS  $SPARKLINES; do
    cp $i $OUTDIR/$i
done

# then, a little special treatment for the file paths in the samples-table
sed 's/\.\.\/tex/../g;'  inputs/samples-table.tex > $OUTDIR/inputs/samples-table.tex


# and we will need to do some things down here to remove the title page, etc.

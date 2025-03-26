

# this is a simple script to pull the output_list and
# input_list names from the Rmd files and create a skeleton
# Snakefile to render them all via Snakemake.

# Basically, for each Rmd file it makes a snakemake rule
# to render it using my script in scripts/render-rmd-for-snakemake.R



make_rule () {
    filename=$1

    # first make a rule name by stripping the first four characters (numbers and dash)
    rulename=$(echo $filename | awk '{a = $1; print substr(a, 5)}' | sed 's/.Rmd$//g; s/-/_/g;')
    htmlname=$(echo $filename | sed 's/.Rmd$/.html/g;')


    # now, get the input list elements

    echo rule $rulename:
    echo "    input:"
    echo "        rmd=\"$filename\","
    awk '/input_list <- list\(/ {go = 1; next} go==1 && $1== ")" {exit} go==1 {printf("    %s\n", $0)}' $filename
    echo "    output:"
    echo "        html=\"docs/$htmlname\","
    awk '/output_list <- list\(/ {go = 1; next} go==1 && $1== ")" {exit} go==1 {printf("    %s\n", $0)}' $filename
    echo "    log:"
    echo "        \"results/logs/$rulename.log\""
    echo "    conda:"
    echo "        \"envs/pandoc.yaml\""
    echo "    script:"
    echo "        \"scripts/render-rmd-for-snakemake.R\""
    echo
    echo
    echo

    # then we also put all the output files there for rule all
    awk '/output_list <- list\(/ {go = 1; next} go==1 && $1== ")" {exit} go==1 {printf("    %s\n", $0)}' $filename >> xxx_temp_outs
}


echo "" > xxx_temp_outs
for i in 00*.Rmd; do
    make_rule $i
done
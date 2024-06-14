

# Notes for revamping names:

General pattern = `Ots_type00X-ChrNum-V2StartPos`, where:

- `Ots` is just `Ots`
- `type` is a brief descriptor (shoot for 4 characters) for example:
    + SNPtype = `scon`
    + Microhap = `mhap`
    + RoSA = `rosa`
    + SexID = `sexy`
    + LFAR = `lfar`
    + WRAP = `wrap`
    + VGLL = `vgll`
    + Six6 = `sixx`
- 00X is a three digit left zero-padded, base-1 number within type ordered by genome V2 location.
- ChrNum is a two digit left zero padded Chromosome number, except for sexy which is
  going to be just the scaffold name.
- V2StartPos is just where it maps in Otsh_V2.


To process these things in the snakemake mega-simple workflow, we will add a new
field that goes within `genome` or `target_fasta` in the config file which is called
`rename:` and that give tsv file with columns named `orig` and `new` which are the
original names and the desired new names, and we will make one extra rule in there
somehow to deal with it.  We will keep the VCFs with the original names, but we need
a rule that will make a renamed VCF, and we also need a renamed Microhaplot output.

So we won't change the target fastas.  This way we have a data set that is compatible
with old stuff, and we also have one that we can use with the new names.




# ToDo:

Let's be expedient:

- DONE! ~Basic pop-gen summaries, means +- 2 SD.  See if AC has this already.~
  * Numbers of alleles 
  * Average (over loci) heterozygosity (observed and expected)
  * Average (over loci) Sample Size
  * Proportion of polymorphic loci 


- RoSA analyses --- keep them separate for the GSI (show how similar FRH and TRH F/S are),
  and then we show how we can identify at least the spring in the FRH.  


- Working the LFAR in there.  There was something weird on one of the plates
  that Cassie ran where the LFAR didn't quite work.  


- Break the Eel and Russian into their own reporting units?

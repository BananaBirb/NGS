nextflow.enable.dsl=2

params.outdir=baseDir
params.tempdir = "${baseDir}/dloads"
params.downloadurl = null
params.infile = null

//comments like this, bigger comment blocks with /* */ this does not work in process blocks!
// url for practicing with inurl
process downloadFile {
    storeDir params.tempdir
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        val inurl
    output: 
        path "batch1.fasta"

    """
    wget ${inurl} -O batch1.fasta
    """
}

process countFiles {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path infile
    output:
        path 'seqcount.txt' 
    """
    grep ">" ${infile} | wc -l > seqcount.txt
    """
}

process splitfilesPY {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path infile
    output:
        path '*.txt'
    """
    python ${baseDir}/splitFasta.py ${infile} seq
    """
}


process splitfileslx {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path infasta
    output:
        path 'sequence_*'
    """
    split -l 2 --additional-suffix .fasta -d ${infasta} sequence_
    """
}


process countBases {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path infasta
    output:
        path "${infasta.getSimpleName()}_numbases.txt"
    """
    tail -1 ${infasta} | wc -m > ${infasta.getSimpleName()}_numbases.txt
    """
}

process countRepeats {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:  
        path infasta
    output:
        path "${infasta.getSimpleName()}_numreps.txt"
    """
    tail -1 ${infasta} | grep -o "GCCGCG" | wc -l > ${infasta.getSimpleName()}_numreps.txt
    # alternative with other patterns, e.g. occurence oc nugleotides
    # tail -1 ${infasta} | grep -o [ACGT] | sort | uniq -c > ${infasta.getSimpleName()}_numreps.txt
    """
}



process summary_nextflow {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path textfiles
    output:
        path "*.csv"
    """
    ## my solution
    python ${baseDir}/summary_nextflow.py *.txt summary
    ## alternative dabrowski with print command
    #python ${baseDir}/summary_nextflow.py *.txt > summary.csv
    """
}


/*
process cleanup {
    input:
        path textfiles
    
    """
    ls -d ${params.outdir} | rm - rf 
    """
}
*/

workflow {

    if(params.downloadurl != null && params.infile == null) {
        filein = downloadFile(Channel.from(params.downloadurl))
    } 
    else if(params.infile != null && params.downloadurl == null) {
        filein = Channel.fromPath(params.infile)
    } 
    else {
        print "Please provide --infile or --downloadurl to specify input"
        System.exit(0)
    } 
    countFiles(filein)
    splitspy=splitfilesPY(filein)
    splitslx=splitfileslx(filein)
    splitslxflat=splitslx.flatten()
    splitslxflat.view()
    countBases(splitslxflat)
    repeats=countRepeats(splitslxflat)
    repeats.view()
    repeats.collect().view()
    summary_nextflow(repeats.collect())
    //cleanup()
}
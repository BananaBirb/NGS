nextflow.enable.dsl=2

params.outdir=baseDir
params.tempdir = "${baseDir}/dloads"
params.inurl="https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam"
//params.infile= "${baseDir}/tests/test_seq1.sam"
//comments like this, bigger comment blocks with /* */ this does not work in process blocks!
// url for practicing with inurl
process downloadFile {
    storeDir params.tempdir
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    output:
        path "input.sam"

    """
    wget ${params.inurl} -O input.sam
    """
}


process splitsam {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path infile
    output:
        path 'sequence_*.fasta'

    // Alternative of splitting via command line tools instead of python script
    """
    cat ${infile} | grep -v "^@" | cut -f 1,10 --output-delimiter "," | sed -e 's/^/>/' | tr -s ',', '\n' > sequences.fasta; split -l 2 -d --additional-suffix ".fasta" sequences.fasta sequence_
    #python ${baseDir}/splitsam.py ${infile} sequence_
    """
}


process countstart {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path infile
    output:
        path "${infile.getSimpleName()}_startreps"

    """
    tail -l ${infile} | grep -o "ATG" | wc -l > ${infile.getSimpleName()}_startreps
    """
}



process countstop {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path infile
    output:
        path "${infile.getSimpleName()}_stopreps"
    
    """
    tail -l ${infile} | grep -o "T[GA][GA]" | sort | uniq -c > ${infile.getSimpleName()}_stopreps
    """
}

process summarize {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        path startcodons
        path stopcodons
    output:
        path "summary_sam.csv"

    """
    python ${baseDir}/summary_sam.py *_startreps *_stopreps
    
    """
}

workflow {
    
    if(params.inurl == null && params.infile != null) {
        samfile=Channel.fromPath(params.infile)
    }
    else if(params.inurl != null && params.infile != null) {
        samfile=Channel.fromPath(params.infile)
    }
    else if(params.infile == null && params.inurl != null) {
        samfile=downloadFile()
    }
    else {
        print("Error, no input. Either provide a file path or a url via --infile and --inurl")
        System.exit(1)
    }
    
    //samfile=downloadFile()
    splits=splitsam(samfile)
    countstart(splits.flatten())
    countstop(splits.flatten())
    //summarize(countstart,countstop)
}
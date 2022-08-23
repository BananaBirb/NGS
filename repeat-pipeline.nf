nextflow.enable.dsl=2

params.outdir=baseDir
params.tempdir = "${baseDir}/dloads"

//comments like this, bigger comment blocks with /* */ this does not work in process blocks!

process downloadFile {
    storeDir params.tempdir
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    output:
        path "batch1.fasta"

    """
    wget https://tinyurl.com/cqbatch1 -O batch1.fasta
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
    python /home/cq/Python/splitFasta.py ${infile} seq
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
        path 'numbases.txt'
    """
    tail -1 ${infasta} | wc -m > numbases.txt
    """
}

workflow {
    filein=downloadFile() 
    countFiles(filein)
    splitspy=splitfilesPY(filein)
    splitslx=splitfileslx(filein)
    splitslxflat=splitslx.flatten()
    splitslxflat.view()
    countBases(splitsxlflat)
}
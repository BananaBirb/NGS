nextflow.enable.dsl=2

params.temp="${baseDir}/cache"
params.outdir="${baseDir}/outdir"
params.accession="M21012"
process fetchrefseq {
    storeDir params.temp
    input:
        val infile
    output:
        path "${infile}.fasta"
    
    """
    wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${infile}&rettype=fasta&retmode=text" -O ${infile}.fasta
    """
}

process combineexpseqs {
    storeDir params.temp
    input:
        path infile
    output:
        path "${infile.getSimpleName()}_experiment.fasta"
    """
    cat ${baseDir}/seqs/*.fasta  ${infile} > ${infile.getSimpleName()}_experiment.fasta
    """
}

process mafft {
    container "https://depot.galaxyproject.org/singularity/mafft%3A7.505--hec16e2b_0"
    input:
        path infile
    output:
        path "${infile.getSimpleName()}_msa.fasta"
    """
    mafft --auto ${infile} > "${infile.getSimpleName()}_msa.fasta"
    """
}

process trimal {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    container "https://depot.galaxyproject.org/singularity/trimal%3A1.4.1--hc9558a2_4"
    input:
        path infile
    output:
        path "${infile.getSimpleName()}_trimal.html", emit: html
        path "${infile.getSimpleName()}_trimal.fasta", emit: fasta
    """
    trimal -in ${infile} -out ${infile.getSimpleName()}_trimal.fasta -htmlout ${infile.getSimpleName()}_trimal.html -automated1
    """
}

workflow{
    refin=fetchrefseq(Channel.from(params.accession))
    comboseqin=combineexpseqs(refin)
    cleanmsa=mafft(comboseqin)
    trimmsa=trimal(cleanmsa)
    }
process downloadFASTQ {
  input:
    val srr_accession_number

  output:
    path 'SRR[0-9]*_{1,2}.fastq'

  script:
    """
    prefetch ${srr_accession_number}
    fasterq-dump ${srr_accession_number}
    """
}

process downloadGenome {
  output:
    path 'GRCh38.fasta.gz'

  script:
    """
    curl $params.genome_download_url > 'GRCh38.fasta.gz'
    """
}

process fastQC {
  publishDir "results/fastqc/", mode: "copy"

  input:
    path srr_fastq

  output:
    path '*.html'

  script:
    """
    fastqc $srr_fastq
    """
}

workflow {
  Channel.fromPath(params.srr_accession_list).splitText() | first | downloadFASTQ | fastQC
  downloadGenome()
}

process downloadFASTQ {
  publishDir "data/fastq_reads/", mode: "copy"

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
  publishDir "data/genome/", mode: "copy"

  output:
    path 'GRCh38.fasta.gz'

  script:
    """
    curl $params.genome_download_url > 'GRCh38.fasta.gz'
    """
}

workflow {
  Channel.fromPath(params.srr_accession_list).splitText() | downloadFASTQ
  downloadGenome()
}

process downloadFASTQ {
  publishDir "data/fastq_reads/", mode: "copy"

  input:
    val srr_accession_file

  script:
  "prefetch $srr_accession_file"
}

process downloadGenome {
  publishDir "data/genome/", mode: "copy"

  output:
    path 'GRCh38.fasta.gz'

  script:
    """
    curl https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz > GRCh38.fasta.gz
    """
}

workflow {
  Channel.fromPath(params.srr_acc_file).splitText() | downloadFASTQ
  downloadGenome()
}

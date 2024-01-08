input_ch = channel.fromPath(params.srr_accession_list).splitText()

process downloadFASTQ {
  input:
    val srr_accession_number

  output:
    file "*.fastq"

  script:
    """
    prefetch ${srr_accession_number}
    fasterq-dump ${srr_accession_number}
    """
}

process downloadGenome {
  input:
    val genome_url

  output:
    path 'GRCh38.fasta.gz'

  script:
    """
    curl ${genome_url} > 'GRCh38.fasta.gz'
    """
}

process fastQC {
  publishDir "results/fastqc/", mode: "copy"

  input:
    path srr_fastq

  output:
    path '*.html'
    path '*.zip'

  script:
    """
    fastqc $srr_fastq
    """
}

workflow {
  srr_accession_numbers = channel.fromPath(params.srr_accession_list).splitText() | first 
  fastq = downloadFASTQ(srr_accession_numbers)
  fastq.view()

  genome = downloadGenome(params.genome_url)
}

input_ch = channel.fromPath(params.srr_accession_list).splitText()

process downloadFASTQ {
  input:
    val srr_accession_number

  output:
    path "*_1.fastq"
    path "*_2.fastq"

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
  publishDir "results/fastqc_raws/", mode: "copy"

  input:
    path fastq_1
    path fastq_2

  output:
    path '*_1_fastqc.html'
    path '*_2_fastqc.html'

  script:
    """
    fastqc ${fastq_1} ${fastq_2}
    """
}

process fastp {
  input:
    path '*_1.fastq'
    path '*_2.fastq'

  output:
    path '*_1T.fastq'
    path '*_2T.fastq'

  script:
    """
    fastp -i *_1.fastq -I *_2.fastq -o *_1T.fastq -O *_2T.fastq
    """
}

workflow {
  srr_accession_numbers = channel.fromPath(params.srr_accession_list).splitText() | first 
  (fastq_1, fastq_2) = downloadFASTQ(srr_accession_numbers)
  fastQC(fastq_1, fastq_2)

  (fastq_1t, fastq_2t) = fastp(fastq_1, fastq_2)
  // fastQC(fastq_1t, fastq_2t)

  genome = downloadGenome(params.genome_url)
}

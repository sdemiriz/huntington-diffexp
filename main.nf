
process downloadFASTQ {
  input:
    val srr_accession_number

  output:
    path "SRR*_{1,2}.fastq"

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
    path "GRCh38.fasta"

  script:
    """
    curl ${genome_url} --output GRCh38.fasta.gz
    gzip -d GRCh38.fasta.gz
    """
}

process downloadAnnotations {
  input:
    val annotations_url

  output:
    path "gencode_annotation.gtf"

  script:
    """
    curl ${annotations_url} --output gencode_annotation.gtf.gz
    gzip -d gencode_annotation.gtf.gz
    """
}

process fastQC {
  publishDir "results/fastqc_raws/", mode: "copy"

  input:
    tuple file(fastq_1), file(fastq_2)

  output:
    path "SRR*_{1,2}_fastqc.html"

  script:
    """
    fastqc ${fastq_1} ${fastq_2}
    """
}

process fastp {
  input:
    tuple file(fastq_1), file(fastq_2)

  output:
    path "SRR*_{1,2}.fastq.T"

  script:
    """
    fastp --in1 ${fastq_1} --in2 ${fastq_2} --out1 ${fastq_1}.T --out2 ${fastq_2}.T
    """
}

process starGenomeIndex {
  input:
    path genome
    path genome_annotations

  output:
    path "GRCh38.index"

  script:
    """
    STAR \
    --runThreadN 6 \
    --runMode genomeGenerate \
    --genomeDir GRCh38.index \
    --genomeFastaFiles ${genome} \
    --sjdbGTFfile ${genome_annotations} \
    --sjdbOverhang 99
    """
}

workflow {
  srr_accession_numbers = channel.fromPath(params.srr_accession_list).splitText().map{it.trim()} | first
  fastq = downloadFASTQ(srr_accession_numbers)
  genome = downloadGenome(params.genome_url)
  annotations = downloadAnnotations(params.genome_annotations_url)

  fastQC(fastq)
  fastp(fastq)

  index = starGenomeIndex(genome, annotations)
}

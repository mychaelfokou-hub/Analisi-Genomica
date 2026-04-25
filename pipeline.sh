# ==============================================================================
# PROGETTO DI GENOMICA - PIPELINE DI VARIANT CALLING E PRIORITIZZAZIONE
# Ereditarietà simulata: Autosomica Recessiva (AR)
# Autore: Mike Fokou
# ==============================================================================
# ISTRUZIONI: Cambia manualmente il valore "x" in "trio_x" nei nomi dei files sottostanti 
# con il numero del trio che vuoi riprodurre (es. trio_1, trio_2, ecc.)

# ------------------------------------------------------------------------------
# 0. PRECONFIGURAZIONE AMBIENTE (Link e Cartelle)
# ------------------------------------------------------------------------------
echo "Creazione link simbolici ai dati e file di riferimento..."
# Uso di -sf per forzare la creazione/aggiornamento senza errori se esistono già
ln -sf /home/BCG2026_exam/BCG2026_mikefokou cartella.dati
ln -sf /home/BCG2026_exam/chr20.fa .
ln -sf /home/BCG2026_exam/chr20.fa.fai .
ln -sf /home/BCG2026_exam/chr20.*.bt2 .
ln -sf /home/BCG2026_exam/chr20_ILMN_Exome_2.0_Plus_Panel.hg38_padded.bed .
ln -sf /home/BCG2026_exam/list_disorders.txt .
ln -sf /home/BCG2026_exam/trios.txt .

echo "Organizzazione delle cartelle per i case study..."
mkdir -p trio_1 trio_2 trio_3 trio_4 trio_5
for i in {1..5}; do 
    mkdir -p trio_$i/vcf trio_$i/fastqc_reports trio_$i/qualimap_reports
done

# ------------------------------------------------------------------------------
# 1. CONTROLLO QUALITA' DEL SEQUENZIAMENTO (FastQC)
#    CARTELLA IN CUI ESEGUIRE IL COMANDO: fastqc_reports
# ------------------------------------------------------------------------------
echo "Avvio FastQC per il controllo qualità delle reads grezze..."
fastqc ~/progetto/cartella.dati/trio_x/*.fq.gz -o ~/progetto/trio_x/fastqc_reports

# ------------------------------------------------------------------------------
# 2. ALLINEAMENTO AL GENOMA DI RIFERIMENTO (Bowtie2 & Samtools)
# ------------------------------------------------------------------------------
echo "Avvio allineamento e conversione in BAM ordinato..."

# Ciclo for per allineare i file fq dei 3 individui assegnando automaticamente i Read Groups
for f in HG00421 HG00422 HG00423; do
    # Definiamo il ruolo in base al codice HG
    if [ "$f" == "HG00421" ]; then SM="child_trio_x"; fi
    if [ "$f" == "HG00422" ]; then SM="father_trio_x"; fi
    if [ "$f" == "HG00423" ]; then SM="mother_trio_x"; fi
    
    echo "Processando $f come $SM..."
    
    bowtie2 -p 4 \
    -x /progetto/chr20 \
    -1 /progetto/cartella.dati/trio_x/${f}.targets_R1.fq.gz \
    -2 /progetto/cartella.dati/trio_x/${f}.targets_R2.fq.gz \
    --rg-id "$f" --rg "SM:$SM" | \
    samtools view -Sb - | \
    samtools sort -o ${SM}_sorted.bam
done

# ------------------------------------------------------------------------------
# 3. INDICIZZAZIONE DEI FILE BAM (Samtools)
# ------------------------------------------------------------------------------
echo "Indicizzazione dei file BAM..."
for file in *_sorted.bam; do 
    samtools index "$file"
done

# ------------------------------------------------------------------------------
# 4. CONTROLLO QUALITA' DELL'ALLINEAMENTO SULL'ESOMA (Qualimap & MultiQC)
#    CARTELLA IN CUI ESEGUIRE IL COMANDO: qualimap_reports
# ------------------------------------------------------------------------------
echo "Avvio Qualimap BamQC sulle regioni target..."
for s in child_trio_x father_trio_x mother_trio_x; do
    qualimap bamqc \
    -bam ../${s}_sorted.bam \
    --feature-file progetto/chr20_ILMN_Exome_2.0_Plus_Panel.hg38_padded.bed \
    -outdir QC_${s}
done

echo "Unificazione dei report con MultiQC..."
multiqc . -n trio_x_multiqc_report.html #comando da eseguire nella cartella trio_x

# ------------------------------------------------------------------------------
# 5. VARIANT CALLING CONGIUNTO (Freebayes)
# ------------------------------------------------------------------------------
echo "Avvio variant calling con Freebayes..."
freebayes -f ../../chr20.fa \
-m 20 -C 5 -Q 10 -q 10 --min-coverage 20 \
../child_trio_x_sorted.bam \
../father_trio_x_sorted.bam \
../mother_trio_x_sorted.bam \
> trio_x_variants.vcf

# ------------------------------------------------------------------------------
# 6. FILTRAGGIO SULLE REGIONI TARGET DELL'ESOMA (Bedtools)
#    CARTELLA IN CUI ESEGUIRE IL COMANDO: vcf
# ------------------------------------------------------------------------------
echo "Intersezione delle varianti con il file BED..."
bedtools intersect \
-a trio_x_variants.vcf \
-b ../../chr20_ILMN_Exome_2.0_Plus_Panel.hg38_padded.bed \
-header > trio_x_target.vcf

# ------------------------------------------------------------------------------
# 7. ANNOTAZIONE CLINICA E FUNZIONALE (VEP)
# ------------------------------------------------------------------------------
echo "Annotazione delle varianti con Ensembl VEP..."
vep -i trio_x_target.vcf \
-o trio_x_annotated.vcf \
--vcf --cache --offline \
--assembly GRCh38 \
--dir_cache /data/vep_cache \
--fasta /home/BCG2026_exam/chr20.fa \
--use_given_ref --mane --pick_allele \
--af --af_1kg --af_gnomade --max_af \
--sift b --polyphen b

# ------------------------------------------------------------------------------
# 8.a FILTRAGGIO PER MODELLI DI EREDITARIETÀ
# ------------------------------------------------------------------------------

# NOTA: L'ordine dei campioni nel VCF è fondamentale (es. 0=Mother, 1=Father, 2=Child)
grep "#CHROM" trio_x_annotated.vcf

# CASO A: Autosomica Recessiva (AR) - Es. Trio 1, 4, 5
# Il figlio è omozigote mutato (AA), entrambi i genitori sono eterozigoti portatori (RA)
bcftools view -i 'GT[2]="AA" && GT[0]="RA" && GT[1]="RA"' trio_x_annotated.vcf > trio_x_genotipo.vcf

# CASO B: Autosomica Dominante (AD) de novo - Es. Trio 3
# Il figlio è eterozigote (RA), entrambi i genitori sono omozigoti wild-type (RR)
bcftools view -i 'GT[2]="RA" && GT[0]="RR" && GT[1]="RR"' trio_x_annotated.vcf > trio_x_genotipo.vcf

# CASO C: Autosomica Dominante (AD) ereditata dal padre - Es. Trio 2
# Il figlio è eterozigote (RA), il padre è eterozigote (RA), la madre è wild-type (RR)
bcftools view -i 'GT[2]="RA" && GT[1]="RA" && GT[0]="RR"' trio_x_annotated.vcf > trio_x_genotipo.vcf

# ------------------------------------------------------------------------------
# 8.b FILTRAGGIO PER IMPATTO E FREQUENZA
# ------------------------------------------------------------------------------

echo "Filtraggio per impatto (HIGH/MODERATE) e frequenza allelica rara (MAX_AF < 0.0001)..."
filter_vep -i trio_x_genotipo.vcf -o trio_x_FINAL_CANDIDATES.vcf \
--filter "(IMPACT is HIGH or IMPACT is MODERATE) and (not MAX_AF or MAX_AF < 0.0001)"
# ------------------------------------------------------------------------------
# 9. RISULTATI FINALI E PRIORITIZZAZIONE
# ------------------------------------------------------------------------------
echo "Numero di varianti candidate finali:"
grep -v "#" trio_x_FINAL_CANDIDATES.vcf | wc -l

echo "Estrazione dettagli varianti (Geni, SIFT, PolyPhen):"
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/CSQ\n' trio_1_FINAL_CANDIDATES.vcf | \
column -s '|' -t | \
awk '{print "LOC:", $1, $2, "| REF/ALT:", $3">"$4, "| INFO:", $5, $6, $7, $8, $9, $10, $11, $12}'

echo "Analisi completata!"

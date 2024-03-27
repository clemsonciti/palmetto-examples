//Example calling bash script
params.init = "${baseDir}/scripts/test.sh"

process prepare_data {

        input:
        path init

        output:
        path "./moving_picture_tutorial"

        script:
        """
        sh $init
        """
}

//Example using Biocontainers
process init_qiime {

        input:
        path x

        output:
        path "./moving_picture_tutorial"

        script:
        """
        module use /software/containers/biocontainers
        module load modules/qiime2
        cd $x
        qiime tools import --type EMPSingleEndSequences --input-path emp-single-end-sequences --output-path emp-single-end-sequences.qza
        """
}

process demux {

        input:
        path x

        output:
        path "./moving_picture_tutorial"

        script:
        """
        module use /software/containers/biocontainers
        module load modules/qiime2
        cd $x
        qiime demux emp-single --i-seqs emp-single-end-sequences.qza --m-barcodes-file sample_metadata.tsv --m-barcodes-column barcode-sequence --o-per-sample-sequences demux.qza --o-error-correction-details demux-details.qza
        """
}

process denoise {

        input:
        path x

        output:
        path "./moving_picture_tutorial"

        script:
        """
        module use /software/containers/biocontainers
        module load modules/qiime2
        cd $x
        qiime dada2 denoise-single --i-demultiplexed-seqs demux.qza --p-trim-left 0 --p-trunc-len 120 --o-representative-sequences rep-seqs.qza --o-table table.qza --o-denoising-stats stats.qza
        """
}

process phylogeny {

        input:
        path x

        script:
        """
        module use /software/containers/biocontainers
        module load modules/qiime2
        cd $x
        qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs.qza --o-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza
        """
}

workflow{
        prepare_data(params.init)
        init_qiime(prepare_data.out)
        demux(init_qiime.out)
        denoise(demux.out)
        phylogeny(denoise.out)
}

